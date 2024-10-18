local playerDiseases = {}

function LoadPlayerDiseases(playerId)
    MySQL.Async.fetchAll('SELECT disease FROM player_diseases WHERE player_id = @playerId', {
        ['@playerId'] = playerId
    }, function(results)
        for _, result in ipairs(results) do
            playerDiseases[playerId] = result.disease
            TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Cargaste la enfermedad: " .. result.disease } })
            TriggerClientEvent('ApplySymptoms', playerId, result.disease)
        end
    end)
end

function SavePlayerDisease(playerId, disease)
    MySQL.Async.execute('INSERT INTO player_diseases (player_id, disease) VALUES (@playerId, @disease)', {
        ['@playerId'] = playerId,
        ['@disease'] = disease
    })
end

function RemovePlayerDisease(playerId)
    MySQL.Async.execute('DELETE FROM player_diseases WHERE player_id = @playerId', {
        ['@playerId'] = playerId
    })
end

if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function CheckContagion(playerId, disease)
    local players = GetPlayers()
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

    for _, targetId in pairs(players) do
        if targetId ~= playerId then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local distance = #(playerCoords - targetCoords)

            if distance <= Config.Enfermedades[disease].rangoContagio then
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
        TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "Ya estás infectado con " .. playerDiseases[playerId] } })
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
        TriggerClientEvent('chat:addMessage', playerId, { args = { "Sistema", "No tienes la medicina correcta o no estás enfermo." } })
    end
end, false)
