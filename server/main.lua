if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Config.FrameWork = 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Config.FrameWork = 'qb'
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('===NO SUPPORTED FRAMEWORK FOUND===')
end

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

local playerDiseases = {}

function LoadPlayerDiseases(playerId)
    MySQL.Async.fetchAll('SELECT disease FROM player_diseases WHERE player_id = @playerId', {
        ['@playerId'] = playerId
    }, function(results)
        for _, result in ipairs(results) do
            playerDiseases[playerId] = result.disease
            TriggerClientEvent('ApplySymptoms', playerId, result.disease)
            DebugPrint("Cargada la enfermedad: " .. result.disease.. " para el jugador "..playerId)
        end
    end)
end

if GetResourceState('es_extended') == 'started' then
    AddEventHandler('esx:playerLoaded', function(source)
        local playerId = source
        LoadPlayerDiseases(playerId)
    end)
end

if GetResourceState('qb-core') == 'started' then
    AddEventHandler('QBCore:Server:PlayerLoaded', function(source)
        local playerId = source
        LoadPlayerDiseases(playerId)
    end)
end

exports("LoadPlayerDiseases", LoadPlayerDiseases)

function SavePlayerDisease(playerId, disease)
    MySQL.Async.execute('INSERT INTO player_diseases (player_id, disease) VALUES (@playerId, @disease)', {
        ['@playerId'] = playerId,
        ['@disease'] = disease
    })
end

exports("SavePlayerDisease", SavePlayerDisease)

function RemovePlayerDisease(playerId)
    MySQL.Async.execute('DELETE FROM player_diseases WHERE player_id = @playerId', {
        ['@playerId'] = playerId
    })
end

exports("RemovePlayerDisease", RemovePlayerDisease)

if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

lib.callback.register('checkPlayerImmune', function(playerId)
    local job = nil

    -- Verificar el framework y obtener el trabajo del jugador
    if Config.FrameWork == "esx" then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        job = xPlayer.job.name
    elseif Config.FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        job = Player.PlayerData.job.name
    end

    -- Comprobar si el trabajo del jugador es inmune
    for _, immuneJob in ipairs(Config.InmuneJobs) do
        if job == immuneJob then
            return true  -- Si está inmune, devolvemos true
        end
    end

    return false  -- Si no está inmune, devolvemos false
end)

function InfectPlayer(playerId, disease)
    if playerDiseases[playerId] then
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
            "Ya estás infectado con " .. playerDiseases[playerId], 3000, 'info')
        return
    end

    playerDiseases[playerId] = disease
    SavePlayerDisease(playerId, disease)
    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', "Has sido infectado con " .. disease,
        3000, 'info')

    TriggerClientEvent('ApplySymptoms', playerId, disease)

    Citizen.CreateThread(function()
        Citizen.Wait(Config.Enfermedades[disease].duration * 1000)
        CurePlayer(playerId)
    end)
end

exports("InfectPlayer", InfectPlayer)
-- exports["muhaddil_infections"]:InfectPlayer(playerId, "nombre_de_enfermedad")

RegisterNetEvent('infectarJugador')
AddEventHandler('infectarJugador', function(playerID, disease)
    local playerId = playerID or source
    
    if not playerDiseases[playerId] then
        playerDiseases[playerId] = disease
        SavePlayerDisease(playerId, disease)
        TriggerClientEvent('ApplySymptoms', playerId, disease)
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', "Has sido infectado con " .. disease, 3000, 'info')

        Citizen.CreateThread(function()
            Citizen.Wait(Config.Enfermedades[disease].duration * 1000)
            CurePlayer(playerId)
        end)
    else
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', "Ya estás infectado con " .. playerDiseases[playerId], 3000, 'info')
    end
end)

function CurePlayer(playerId)
    if playerDiseases[playerId] then
        RemovePlayerDisease(playerId)
    end
    playerDiseases[playerId] = nil
    TriggerClientEvent('RemoveAllEffects', playerId)
    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', 'Te has curado.', 3000, 'info')
end

exports("CurePlayer", CurePlayer)

if Config.FrameWork == 'esx' then
    RegisterCommand('infectar', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            local playerGroup = xPlayer.getGroup()

            if table.contains(Config.AdminGroups, playerGroup) then
                local playerId = source
                local disease = args[1]

                if Config.Enfermedades[disease] then
                    InfectPlayer(playerId, disease)
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
                        'Has sido infectado con la enfermedad: ' .. disease, 3000, 'info')
                else
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
                        'Esa enfermedad no existe.', 3000, 'error')
                end
            else
                TriggerClientEvent('muhaddil_infections:SendNotification', source, 'Sistema',
                    'No tienes permiso para usar este comando.', 3000, 'error')
            end
        else
            print("Error: No se pudo obtener el objeto xPlayer.")
        end
    end, false)

    RegisterCommand('curar', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            local playerGroup = xPlayer.getGroup()

            if table.contains(Config.AdminGroups, playerGroup) then
                local playerId = source
                local item = args[1]
                local disease = playerDiseases[playerId]

                if disease and item == Config.Enfermedades[disease].cureItem then
                    CurePlayer(playerId)
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
                        'Has sido curado de todas tus enfermedades.', 3000, 'info')
                else
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
                        'No tienes la medicina correcta o no estás enfermo.', 3000, 'error')
                end
            else
                TriggerClientEvent('muhaddil_infections:SendNotification', source, 'Sistema',
                    'No tienes permiso para usar este comando.', 3000, 'error')
            end
        else
            print("Error: No se pudo obtener el objeto xPlayer.")
        end
    end, false)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function RegisterCureItem(cureItem)
    if Config.FrameWork == "esx" then
        ESX.RegisterUsableItem(cureItem, function(source)
            HandleCureUsage(source, cureItem)
        end)
    elseif Config.FrameWork == "qb" then
        QBCore.Functions.CreateUseableItem(cureItem, function(source)
            HandleCureUsage(source, cureItem)
        end)
    end
end

function HandleCureUsage(playerId, cureItem)
    local disease = nil

    for d, details in pairs(Config.Enfermedades) do
        if details.cureItem == cureItem then
            disease = d
            break
        end
    end

    if disease and playerDiseases[playerId] == disease then
        TriggerClientEvent('PlayCureAnimation', playerId)

        Citizen.Wait(3000)

        CurePlayer(playerId)
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
            'Has usado ' .. cureItem .. ' y te has curado.', 3000, 'info')
    else
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
            'No estás enfermo o el item no es correcto.', 3000, 'error')
    end
end

for _, disease in pairs(Config.Enfermedades) do
    local cureItem = disease.cureItem
    if cureItem then
        RegisterCureItem(cureItem)
    end
end

exports('CureAllDiseases', function(playerId)
    if not playerId then
        playerId = source
    end

    if playerDiseases[playerId] then
        CurePlayer(playerId)

        TriggerClientEvent('PlayCureAnimation', playerId)
        
        Citizen.Wait(3000)
        
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', 
            'Has sido curado de todas tus enfermedades.', 3000, 'info')
    else
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema', 
            'No tienes enfermedades que curar.', 3000, 'error')
    end
end)

RegisterNetEvent('muhaddil_infections:CureAllDiseases')
AddEventHandler('muhaddil_infections:CureAllDiseases', function(playerId)
    exports['muhaddil_infections']:CureAllDiseases(playerId)
end)

-- exports['muhaddil_infections']:CureAllDiseases(playerId)
-- exports['muhaddil_infections']:CureAllDiseases()
