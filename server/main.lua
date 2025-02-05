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
local addictionLevels = {}
local addictionDecayTime = 300

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

local recoveryCooldowns = {}
local treatmentProgress = {}

-- Helper functions
local function GetPlayer(source)
    if FrameWork == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif FrameWork == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
    return nil
end

local function GetCitizenID(player)
    if FrameWork == 'qb' then
        return player.PlayerData.citizenid
    elseif FrameWork == 'esx' then
        return player.identifier
    end
    return nil
end

-- Obtener nivel de adicción
exports('GetAddictionLevel', function(source, item)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return 0 end
    
    local citizenid = GetCitizenID(Player)
    local result = MySQL.query.await('SELECT level FROM addictions WHERE citizenid = ? AND item = ?', {citizenid, item})
    
    return result[1] and result[1].level or 0
end)

-- Cargar adicciones al conectar
RegisterNetEvent('addiction:load', function()
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end
    
    local citizenid = GetCitizenID(Player)
    local addictions = {}
    
    local result = MySQL.query.await('SELECT item, level FROM addictions WHERE citizenid = ?', {citizenid})
    for _, row in ipairs(result) do
        addictions[row.item] = row.level
    end
    
    TriggerClientEvent('addiction:update', src, addictions)
end)

-- Uso de ítem
RegisterNetEvent('addiction:useItem', function(item)
    local src = source
    exports['muhaddil_infections']:IncreaseAddiction(src, item, 10)
end)

RegisterCommand('sumarAdiccion', function (source, args, rawCommand)
    exports['muhaddil_infections']:IncreaseAddiction(source, args[1], tonumber(args[2]))
end, true)

-- Export para aumentar adicción
exports('IncreaseAddiction', function(source, item, amount)
    local Player = GetPlayer(source)
    if not Player then return false end
    
    local citizenid = GetCitizenID(Player)
    local currentLevel = exports['muhaddil_infections']:GetAddictionLevel(source, item)
    local newLevel = math.min(currentLevel + (amount or 10), Config.AddictionRecovery.max_level)
    
    MySQL.insert('INSERT INTO addictions (citizenid, item, level) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE level = ?', {
        citizenid, item, newLevel, newLevel
    })
    
    TriggerClientEvent('addiction:update', source, exports['muhaddil_infections']:GetPlayerAddictions(citizenid))
    return true
end)

-- Función de recuperación
RegisterNetEvent('addiction:recover', function(item)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    local citizenid = GetCitizenID(Player)
    local currentLevel = exports['addictions']:GetAddictionLevel(src, item)
    
    if citizenid == nil or currentLevel == 0 then
        TriggerClientEvent('muhaddil_infections:SendNotification', src, '' , 'No tienes adicción a este ítem')
        return
    end

    -- Verificar cooldown
    if recoveryCooldowns[citizenid] and recoveryCooldowns[citizenid][item] then
        if os.time() < recoveryCooldowns[citizenid][item] then
            TriggerClientEvent('addiction:notify', src, 'Debes esperar '..GetCooldownText(recoveryCooldowns[citizenid][item])..' para otro tratamiento')
            return
        end
    end

    -- Calcular reducción progresiva
    local reduction = CalculateProgressiveReduction(currentLevel)
    local newLevel = math.max(currentLevel - reduction, 0)
    
    -- Actualizar progreso
    treatmentProgress[citizenid] = treatmentProgress[citizenid] or {}
    treatmentProgress[citizenid][item] = (treatmentProgress[citizenid][item] or 0) + reduction

    -- Si se supera el 75% de reducción, reiniciar progreso
    if treatmentProgress[citizenid][item] >= currentLevel * 0.75 then
        newLevel = 0
        treatmentProgress[citizenid][item] = nil
        TriggerClientEvent('addiction:notify', src, '¡Desintoxicación completa!')
    else
        -- Actualizar base de datos
        MySQL.update('UPDATE addictions SET level = ? WHERE citizenid = ? AND item = ?', 
            {newLevel, citizenid, item})
        
        -- Establecer cooldown
        SetCooldown(citizenid, item)
        TriggerClientEvent('addiction:notify', src, string.format('Reducción de adicción: -%d%%, Nivel actual: %d', 
            math.floor((reduction/currentLevel)*100), newLevel))
    end

    TriggerClientEvent('addiction:update', src, exports['addictions']:GetPlayerAddictions(citizenid))
end)

-- Función para calcular reducción progresiva
function CalculateProgressiveReduction(currentLevel)
    local cfg = Config.AddictionRecovery
    local reduction = cfg.base_reduction * math.round(currentLevel / cfg.max_level, cfg.exponent) * currentLevel
    return math.max(math.min(reduction, cfg.max_reduction), cfg.min_reduction)
end

-- Sistema de cooldown
function SetCooldown(citizenid, item)
    recoveryCooldowns[citizenid] = recoveryCooldowns[citizenid] or {}
    recoveryCooldowns[citizenid][item] = os.time() + (Config.AddictionRecovery.cooldown * 60)
end

function GetCooldownText(cooldownTime)
    local remaining = cooldownTime - os.time()
    if remaining > 3600 then
        return string.format("%d horas", math.floor(remaining/3600))
    else
        return string.format("%d minutos", math.ceil(remaining/60))
    end
end

-- Obtener todas las adicciones
exports('GetPlayerAddictions', function(citizenid)
    local result = MySQL.query.await('SELECT item, level FROM addictions WHERE citizenid = ?', {citizenid})
    local addictions = {}
    
    for _, row in ipairs(result) do
        addictions[row.item] = row.level
    end
    
    return addictions
end)