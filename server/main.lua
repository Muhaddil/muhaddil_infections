local playerDiseases = {}

function LoadPlayerDiseases(playerId)
    MySQL.Async.fetchAll('SELECT disease FROM player_diseases WHERE player_id = @playerId', {
        ['@playerId'] = playerId
    }, function(results)
        for _, result in ipairs(results) do
            playerDiseases[playerId] = result.disease
            TriggerClientEvent('chat:addMessage', playerId,
                { args = { "Sistema", "Cargaste la enfermedad: " .. result.disease } })
            TriggerClientEvent('ApplySymptoms', playerId, result.disease)
        end
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

function IsPlayerImmune(playerId)
    local job = nil

    if Config.FrameWork == "esx" then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        job = xPlayer.job.name
    elseif Config.FrameWork == "qb" then
        local Player = QBCore.Functions.GetPlayer(playerId)
        job = Player.PlayerData.job.name
    end

    for _, immuneJob in ipairs(Config.InmuneJobs) do
        if job == immuneJob then
            return true
        end
    end

    return false
end

function CheckContagion(playerId, disease)
    local players = GetPlayers()
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

    for _, targetId in pairs(players) do
        if targetId ~= playerId then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local distance = #(playerCoords - targetCoords)

            if distance <= Config.Enfermedades[disease].rangoContagio and not IsPlayerImmune(targetId) then
                if math.random() < Config.Enfermedades[disease].contagio then
                    if not playerDiseases[targetId] then
                        InfectPlayer(targetId, disease)
                    end
                end
            end
        end
    end
end

function InfectPlayer(playerId, disease)
    if playerDiseases[playerId] then
        TriggerClientEvent('chat:addMessage', playerId,
            { args = { "Sistema", "Ya estás infectado con " .. playerDiseases[playerId] } })
        return
    end

    playerDiseases[playerId] = disease
    SavePlayerDisease(playerId, disease)
    TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Has sido infectado con " .. disease } })
    TriggerClientEvent('ApplySymptoms', playerId, disease)

    Citizen.CreateThread(function()
        Citizen.Wait(Config.Enfermedades[disease].duration * 1000)
        CurePlayer(playerId)
    end)

    Citizen.CreateThread(function()
        while playerDiseases[playerId] do
            Citizen.Wait(Config.TiempoChequeoContagio * 1000)
            CheckContagion(playerId, disease)
        end
    end)
end

exports("InfectPlayer", InfectPlayer)

RegisterNetEvent('infectarJugador')
AddEventHandler('infectarJugador', function(disease)
    local playerId = source
    if Config.Enfermedades[disease] then
        InfectPlayer(playerId, disease)
    else
        TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Esa enfermedad no existe." } })
    end
end)

function CurePlayer(playerId)
    if playerDiseases[playerId] then
        RemovePlayerDisease(playerId)
    end
    playerDiseases[playerId] = nil
    TriggerClientEvent('RemoveAllEffects', playerId)
    TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Te has curado." } })
end

exports("CurePlayer", CurePlayer)

RegisterCommand('infectar', function(source, args, rawCommand)
    local playerId = source
    local disease = args[1]

    if Config.Enfermedades[disease] then
        InfectPlayer(playerId, disease)
    else
        TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Esa enfermedad no existe." } })
    end
end, false)

RegisterCommand('curar', function(source, args, rawCommand)
    local playerId = source
    local item = args[1]
    local disease = playerDiseases[playerId]

    if disease and item == Config.Enfermedades[disease].cureItem then
        CurePlayer(playerId)
    else
        TriggerClientEvent('chat:addMessage', playerId,
            { args = { "Sistema", "No tienes la medicina correcta o no estás enfermo." } })
    end
end, false)

-- Función para registrar items utilizables
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

-- Manejar la lógica de uso del item
function HandleCureUsage(playerId, cureItem)
    local disease = nil

    -- Verifica si el jugador tiene alguna enfermedad
    for d, details in pairs(Config.Enfermedades) do
        if details.cureItem == cureItem then
            disease = d
            break
        end
    end

    if disease and playerDiseases[playerId] == disease then
        -- Envía un evento al cliente para reproducir la animación
        TriggerClientEvent('PlayCureAnimation', playerId)

        -- Espera un tiempo para permitir que la animación se reproduzca
        Citizen.Wait(3000)  -- Asegúrate de que este tiempo sea suficiente

        -- Cura al jugador
        CurePlayer(playerId)
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { "Sistema", "Has usado " .. cureItem .. " y te has curado." }
        })
    else
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { "Sistema", "No estás enfermo o el item no es correcto." }
        })
    end
end

-- Registrar todos los items de cura
for _, disease in pairs(Config.Enfermedades) do
    local cureItem = disease.cureItem
    if cureItem then
        RegisterCureItem(cureItem)
    end
end
