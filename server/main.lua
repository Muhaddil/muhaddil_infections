if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        FrameWork = 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        FrameWork = 'qb'
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    FrameWork = 'esx'
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    FrameWork = 'qb'
else
    print('===NO SUPPORTED FRAMEWORK FOUND===')
end

lib.locale()

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

local playerDiseases = {}

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(5000)

        if FrameWork == "esx" then
            for _, playerId in ipairs(GetPlayers()) do
                LoadPlayerDiseases(playerId)
            end
        elseif FrameWork == "qb" then
            for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
                LoadPlayerDiseases(playerId)
            end
        end
    end
end)

function LoadPlayerDiseases(playerId)
    local identifier = nil

    if FrameWork == "esx" then
        local Player = ESX.GetPlayerFromId(playerId)
        if Player then
            identifier = Player.getIdentifier()
        end
    elseif FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            identifier = Player.PlayerData.license
        end
    end

    if identifier then
        MySQL.Async.fetchAll('SELECT disease FROM player_diseases WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(results)
            for _, result in ipairs(results) do
                playerDiseases[identifier] = result.disease
                TriggerClientEvent('ApplySymptoms', playerId, result.disease)
                DebugPrint("Cargada la enfermedad: " .. result.disease .. " para el jugador " .. playerId)
            end
        end)
    else
        DebugPrint("No se pudo obtener el identificador para el jugador " .. playerId)
    end
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
    local identifier = nil

    if FrameWork == "esx" then
        local Player = ESX.GetPlayerFromId(playerId)
        if Player then
            identifier = Player.getIdentifier()
            DebugPrint("Identificador: " .. identifier)
        end
    elseif FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            identifier = Player.PlayerData.license
        end
    end

    DebugPrint("Guardando enfermedad " .. disease .. " para el jugador " .. playerId)

    if identifier then
        MySQL.Async.execute(
        'INSERT INTO player_diseases (identifier, disease) VALUES (@identifier, @disease)', {
            ['@identifier'] = identifier,
            ['@disease'] = disease
        }, function(affectedRows)
            if affectedRows > 0 then
                DebugPrint("Inserción exitosa")
            else
                DebugPrint("Error en la inserción")
            end
        end)
    else
        DebugPrint("No se pudo obtener el identificador para el jugador " .. playerId)
    end
end

exports("SavePlayerDiseases", SavePlayerDiseases)

function RemovePlayerDisease(playerId)
    local identifier = nil

    if FrameWork == "esx" then
        local Player = ESX.GetPlayerFromId(playerId)
        if Player then
            identifier = Player.getIdentifier()
        end
    elseif FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            identifier = Player.PlayerData.license
        end
    end

    if identifier then
        MySQL.Async.execute('DELETE FROM player_diseases WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        })
    else
        DebugPrint("No se pudo obtener el identificador para el jugador " .. playerId)
    end
end

exports("RemovePlayerDisease", RemovePlayerDisease)

lib.callback.register('checkPlayerImmune', function(playerId)
    local job = nil

    if FrameWork == "esx" then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        job = xPlayer.job.name
    elseif FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        job = Player.PlayerData.job.name
    end

    for _, immuneJob in ipairs(Config.InmuneJobs) do
        if job == immuneJob then
            return true
        end
    end

    return false
end)

function InfectPlayer(playerId, disease)
    DebugPrint("Infectando jugador " .. playerId .. " con " .. disease)
    SavePlayerDisease(playerId, disease)
    if playerDiseases[playerId] then
        local message = locale('infection_already', playerDiseases[playerId])
        local title = locale('system')
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
        return
    end

    playerDiseases[playerId] = disease
    local message = locale('infection_message', disease)
    local title = locale('system')
    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')

    TriggerClientEvent('ApplySymptoms', playerId, disease)

    -- Citizen.CreateThread(function()
    --     Citizen.Wait(Config.Enfermedades[disease].duration * 1000)
    --     CurePlayer(playerId)
    -- end)
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
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
            "Has sido infectado con " .. disease, 3000, 'info')

        Citizen.CreateThread(function()
            Citizen.Wait(Config.Enfermedades[disease].duration * 1000)
            CurePlayer(playerId)
        end)
    else
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, 'Sistema',
            "Ya estás infectado con " .. playerDiseases[playerId], 3000, 'info')
    end
end)

function CurePlayer(playerId)
    if playerDiseases[playerId] then
        RemovePlayerDisease(playerId)
    end
    playerDiseases[playerId] = nil
    TriggerClientEvent('RemoveAllEffects', playerId)
    local message = locale('cure_message')
    local title = locale('system')
    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
end

exports("CurePlayer", CurePlayer)

if FrameWork == 'esx' then
    RegisterCommand('infectar', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            local playerGroup = xPlayer.getGroup()

            if table.contains(Config.AdminGroups, playerGroup) then
                local playerId = source
                local disease = args[1]
                local title = locale('system')

                if Config.Enfermedades[disease] then
                    InfectPlayer(playerId, disease)
                    local message = locale('infection_message', disease)
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
                else
                    local message = locale('infection_error')
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'error')
                end
            else
                local message = locale('no_permission')
                TriggerClientEvent('muhaddil_infections:SendNotification', source, title, message, 3000, 'error')
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
                local title = locale('system')

                if disease and item == Config.Enfermedades[disease].cureItem then
                    CurePlayer(playerId)
                else
                    local message = locale('cure_error')
                    TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'error')
                end
            else
                local message = locale('no_permission')
                TriggerClientEvent('muhaddil_infections:SendNotification', source, title, message, 3000, 'error')
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
    if FrameWork == "esx" then
        ESX.RegisterUsableItem(cureItem, function(source)
            HandleCureUsage(source, cureItem)
        end)
    elseif FrameWork == "qb" then
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

    local title = locale('system')

    if disease and playerDiseases[playerId] == disease then
        TriggerClientEvent('PlayCureAnimation', playerId)

        Citizen.Wait(3000)

        CurePlayer(playerId)
        local message = locale('cure_usage_message', cureItem)
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
    else
        local message = locale('cure_error_message')
        TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'error')
    end
end

for _, disease in pairs(Config.Enfermedades) do
    local cureItem = disease.cureItem
    if cureItem then
        RegisterCureItem(cureItem)
    end
end

exports('CureAllDiseasesAnim', function(playerId)
    if not playerId then
        playerId = source
    end

    local title = locale('system')

    if playerDiseases[playerId] then
        CurePlayer(playerId)

        TriggerClientEvent('PlayCureAnimation', playerId)

        Citizen.Wait(3000)

        -- local message = locale('cure_all_message')
        -- TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
    -- else
    --     local message = locale('no_disease_to_cure')
    --     TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'error')
    end
end)

exports('CureAllDiseases', function(playerId)
    if not playerId then
        playerId = source
    end

    local title = locale('system')

    if playerDiseases[playerId] then
        CurePlayer(playerId)

        -- local message = locale('cure_all_message')
        -- TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'info')
    -- else
    --     local message = locale('no_disease_to_cure')
    --     TriggerClientEvent('muhaddil_infections:SendNotification', playerId, title, message, 3000, 'error')
    end
end)

RegisterNetEvent('muhaddil_infections:CureAllDiseases')
AddEventHandler('muhaddil_infections:CureAllDiseases', function(playerId)
    exports['muhaddil_infections']:CureAllDiseases(playerId)
end)

RegisterCommand('curarAll', function (source, args, rawCommand)
    exports['muhaddil_infections']:CureAllDiseases(source)
    TriggerClientEvent('muhaddil_infections:SendNotification', source, '', 'Has sido curado de todas tus enfermedades', 3000, 'info')
end, true)

-- exports['muhaddil_infections']:CureAllDiseases(playerId)
-- exports['muhaddil_infections']:CureAllDiseases()
