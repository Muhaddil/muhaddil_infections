if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = "esx"
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = "qb"
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = "esx"
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = "qb"
else
    print('===NO SUPPORTED FRAMEWORK FOUND===')
end

lib.locale()

local animTimers = {}
local playerDiseases = {}
local isFalling = false
local diseaseName = nil
local playerInjured = false
local disease = nil
local tiempoEnAgua = 0
local enAgua = false
local ContagionTimer = Config.ContagionTimer
local physicalEffects = {
    activeMovements = {},
    currentClipsets = {},
}
local activeEffects = {}
local currentLevels = {}

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

function SendNotification(msgtitle, msg, time, type)
    if not Config.ShowNotifications then
        return
    end

    if Config.UseOXNotifications then
        lib.notify({
            title = msgtitle,
            description = msg,
            showDuration = true,
            type = type,
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.75)',
                color = 'rgba(255, 255, 255, 1)',
                ['.description'] = {
                    color = '#909296',
                    backgroundColor = 'transparent'
                }
            }
        })
    else
        if Framework == 'qb' then
            QBCore.Functions.Notify(msg, type, time)
        elseif Framework == 'esx' then
            TriggerEvent('esx:showNotification', msg, type, time)
        end
    end
end

RegisterNetEvent("muhaddil_infections:SendNotification")
AddEventHandler("muhaddil_infections:SendNotification", function(msgtitle, msg, time, type)
    SendNotification(msgtitle, msg, time, type)
end)

function LoadAnimDict(dict)
    DebugPrint(locale('loadinganimdictionary') .. dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    DebugPrint(locale('loadedanimdict') .. dict)
end

local excludedDiseases = {
    ["rotura_de_pierna"] = true,
}

local function GetRandomDisease()
    local diseases = {}
    exclusions = excludedDiseases or {}

    for key, _ in pairs(Config.Enfermedades) do
        if not exclusions[key] then
            table.insert(diseases, key)
        end
    end

    if #diseases == 0 then
        return nil
    end

    return diseases[math.random(#diseases)]
end


function EstaEnAgua()
    local playerPed = PlayerPedId()
    return IsEntityInWater(playerPed)
end

Citizen.CreateThread(function()
    while true do
        local playerId = PlayerId()
        Citizen.Wait(1000)

        DebugPrint(EstaEnAgua())
        DebugPrint('Tiempo en agua: ' .. tiempoEnAgua)

        if EstaEnAgua() then
            tiempoEnAgua = tiempoEnAgua + 10
            enAgua = true
        else
            tiempoEnAgua = 0
            enAgua = false
        end

        if tiempoEnAgua >= Config.WaterTime and enAgua then
            local enfermedad = GetRandomDisease()
            DebugPrint("Enfermedad seleccionada: " .. enfermedad)
            DebugPrint("Infectando al jugador con ID: " .. GetPlayerServerId(playerId))
            TriggerServerEvent('infectarJugador', GetPlayerServerId(playerId), enfermedad)
            tiempoEnAgua = 0
        end
    end
end)

Bones = {
    [31085] = 'HEAD',
    [31086] = 'HEAD',
    [39317] = 'HEAD',
    [57597] = 'BODY',
    [23553] = 'BODY',
    [24816] = 'BODY',
    [24817] = 'BODY',
    [24818] = 'BODY',
    [10706] = 'BODY',
    [64729] = 'BODY',
    [11816] = 'BODY',
    [45509] = 'LARM',
    [61163] = 'LARM',
    [18905] = 'LARM',
    [4089] = 'LARM',
    [4090] = 'LARM',
    [4137] = 'LARM',
    [4138] = 'LARM',
    [4153] = 'LARM',
    [4154] = 'LARM',
    [4169] = 'LARM',
    [4170] = 'LARM',
    [4185] = 'LARM',
    [4186] = 'LARM',
    [26610] = 'LARM',
    [26611] = 'LARM',
    [26612] = 'LARM',
    [26613] = 'LARM',
    [26614] = 'LARM',
    [58271] = 'LLEG',
    [63931] = 'LLEG',
    [2108] = 'LLEG',
    [14201] = 'LLEG',
    [40269] = 'RARM',
    [28252] = 'RARM',
    [57005] = 'RARM',
    [58866] = 'RARM',
    [58867] = 'RARM',
    [58868] = 'RARM',
    [58869] = 'RARM',
    [58870] = 'RARM',
    [64016] = 'RARM',
    [64017] = 'RARM',
    [64064] = 'RARM',
    [64065] = 'RARM',
    [64080] = 'RARM',
    [64081] = 'RARM',
    [64096] = 'RARM',
    [64097] = 'RARM',
    [64112] = 'RARM',
    [64113] = 'RARM',
    [36864] = 'RLEG',
    [51826] = 'RLEG',
    [20781] = 'RLEG',
    [52301] = 'RLEG',
}

local alreadyInfected = false

local function StartContagionTimer(playerId)
    if alreadyInfected then return end
    alreadyInfected = true

    Citizen.CreateThread(function()
        Citizen.Wait(ContagionTimer * 1000)

        if playerInjured and disease then
            DebugPrint(locale('infectedwith') .. disease)
            TriggerServerEvent('infectarJugador', GetPlayerServerId(playerId), disease)
            disease = nil
            ContagionTimer = Config.ContagionTimer
        end
    end)
end

AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkEntityDamage" then
        local playerPed = PlayerPedId()
        if args[1] == playerPed then
            playerInjured = true
            DebugPrint('Jugador dañado')
            local success, bone = GetPedLastDamageBone(playerPed)
            if success then
                if not alreadyInfected then
                    BleedingCooldown = false

                    if Bones[bone] == 'HEAD' or Bones[bone] == 'BODY' or Bones[bone] == 'LARM' or Bones[bone] == 'RARM' then
                        disease = GetRandomDisease()
                        StartContagionTimer(PlayerId())
                    elseif Bones[bone] == 'LLEG' or Bones[bone] == 'RLEG' then
                        disease = 'rotura de pierna'
                        ContagionTimer = 0
                        StartContagionTimer(PlayerId())
                    end
                else
                    DebugPrint("El jugador ya está infectado, no se reinfectará.")
                end
            end
        end
    end
end)

AddEventHandler('playerSpawned', function()
    playerInjured = false
    disease = nil
    alreadyInfected = false
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(500)
--         local playerPed = PlayerPedId()
--         if IsPedInjured(playerPed) then
--             playerInjured = true
--             disease = GetRandomDisease()
--             StartContagionTimer(PlayerId())
--         end
--     end
-- end)

RegisterNetEvent('ApplySymptoms')
AddEventHandler('ApplySymptoms', function(disease)
    diseaseName = disease
    local symptoms = Config.Enfermedades[disease].symptoms
    local animaciones = Config.Enfermedades[disease].animaciones
    local efectos = Config.Enfermedades[disease].efectos
    playerDiseases[disease] = true

    for _, symptom in ipairs(symptoms) do
        if symptom == "cansancio" then
            SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
        elseif symptom == "vision_borrosa" then
            StartScreenEffect("DrugsMichaelAliensFightIn", 0, true)
        elseif symptom == "dolor_cabeza" then
            StartScreenEffect("RampageOut", 0, true)
        elseif symptom == 'irritabilidad' then
            -- StartScreenEffect("ExplosionJosh3", 10, true)
            -- StartScreenEffect("DrugsDrivingIn", 10, true)
            StartScreenEffect("LostTimeDay", 10, true)
        elseif symptom == "calor_extremo" then
            StartScreenEffect("MP_job_load", 0, true)
        elseif symptom == "mareo" then
            StartScreenEffect("DrugsDrivingOut", 0, true)
        elseif symptom == "estornudos" then
            local playerPed = PlayerPedId()
            local particleDictionary = "cut_bigscr"
            local particleName = "cs_bigscr_beer_spray"
            RequestNamedPtfxAsset(particleDictionary)
            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                Citizen.Wait(1)
            end
            SetPtfxAssetNextCall(particleDictionary)
            local bone = GetPedBoneIndex(playerPed, 47495)
            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone,
                1.0, false, false, false)
            Citizen.Wait(1000)
            local effect2 = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0,
                bone, 1.0, false, false, false)
            Citizen.Wait(3500)
            StopParticleFxLooped(effect, 0)
            StopParticleFxLooped(effect2, 0)
        elseif symptom == "diarrea" then
            local playerPed = PlayerPedId()
            local particleDictionary = "scr_amb_chop"
            local particleName = "ent_anim_dog_poo"
            local animDict = "missfbi3ig_0"
            local animName = "shit_react_trev"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(1)
            end
            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            RequestNamedPtfxAsset(particleDictionary)
            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                Citizen.Wait(1)
            end
            SetPtfxAssetNextCall(particleDictionary)
            local bone = GetPedBoneIndex(playerPed, 11816)
            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, 0.0, 0.0, -0.2, -90.0, 0.0, 0.0, bone,
                1.0, false, false, false)
            Citizen.Wait(Config.SymptomsDurations["diarrea"])
            StopParticleFxLooped(effect, 0)
            RemoveAnimDict(animDict)
            ClearPedTasksImmediately(PlayerPedId())
        elseif symptom == "vomito" then
            local playerPed = PlayerPedId()
            local particleDictionary = "cut_paletoscore"
            local particleName = "cs_paleto_vomit"
            local animDict = "missheistpaletoscore1leadinout"
            local animName = "trv_puking_leadout"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(1)
            end
            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
            RequestNamedPtfxAsset(particleDictionary)
            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                Citizen.Wait(1)
            end
            SetPtfxAssetNextCall(particleDictionary)
            local bone = GetPedBoneIndex(playerPed, 47495)
            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone,
                1.0, false, false, false)
            Citizen.Wait(Config.SymptomsDurations["vomito"])
            StopParticleFxLooped(effect, 0)
            RemoveAnimDict(animDict)
            ClearPedTasksImmediately(PlayerPedId())
        end
    end

    for animName, animData in pairs(animaciones) do
        if not animTimers[animName] then
            animTimers[animName] = true
            Citizen.CreateThread(function()
                while playerDiseases[disease] do
                    LoadAnimDict(animData.dict)
                    TaskPlayAnim(PlayerPedId(), animData.dict, animData.anim, 8.0, -8.0, -1, 49, 1, false, false, false)
                    Citizen.Wait(animData.delay * 1000)
                end
                animTimers[animName] = nil
            end)
        end
    end

    if efectos then
        if efectos.movimiento_lento then
            Citizen.CreateThread(function()
                while playerDiseases[disease] do
                    SetPedMoveRateOverride(PlayerPedId(), 0.75)
                    Citizen.Wait(0)
                end
                SetPedMoveRateOverride(PlayerPedId(), 1.0)
            end)
        end

        if efectos.tambaleo then
            Citizen.CreateThread(function()
                RequestAnimSet("move_m@drunk@verydrunk")
                while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                    Citizen.Wait(100)
                end

                while playerDiseases[disease] do
                    SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", 1.0)
                    Citizen.Wait(1000)
                end

                ResetPedMovementClipset(PlayerPedId(), 1.0)
            end)
        end

        if efectos.caida_involuntaria then
            Citizen.CreateThread(function()
                while playerDiseases[disease] do
                    local playerPed = PlayerPedId()

                    if not isFalling then
                        local fallChance = 0.1

                        if IsPedSprinting(playerPed) then
                            fallChance = 0.7
                            DebugPrint('Sprinting')
                        elseif IsPedRunning(playerPed) then
                            fallChance = 0.4
                            DebugPrint('Running')
                        end

                        if math.random() < fallChance then
                            isFalling = true
                            ShakeGameplayCam("DRUNK_SHAKE", 1.0)
                            SetPedToRagdoll(playerPed, 3000, 3000, 0, false, false, false)
                            Citizen.Wait(5000)
                            isFalling = false
                        end
                    end

                    Citizen.Wait(5000)
                end
                StopGameplayCamShaking(true)
            end)
        end

        Citizen.CreateThread(function()
            while playerDiseases[disease] do
                local minValue = Config.RandomTimeMin * 1000
                local maxValue = Config.RandomTimeMax * 1000
                local randomWaitTime = math.random(minValue, maxValue)
                Citizen.Wait(Config.EffectDuration * 1000)

                if not disease == excludedDiseases then
                    DebugPrint("Deteniendo efectos por " .. (randomWaitTime / 1000) .. " segundos.")
                    TriggerEvent('RemoveAllEffects')
                    Citizen.Wait(randomWaitTime)
                end

                if playerDiseases[disease] then
                    DebugPrint("Reiniciando efectos.")
                    for _, symptom in ipairs(symptoms) do
                        if symptom == "cansancio" then
                            SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
                        elseif symptom == "vision_borrosa" then
                            StartScreenEffect("DrugsMichaelAliensFightIn", 0, true)
                        elseif symptom == "dolor_cabeza" then
                            StartScreenEffect("RampageOut", 0, true)
                        elseif symptom == 'irritabilidad' then
                            -- StartScreenEffect("ExplosionJosh3", 10, true)
                            -- StartScreenEffect("DrugsDrivingIn", 10, true)
                            StartScreenEffect("LostTimeDay", 10, true)
                        elseif symptom == "calor_extremo" then
                            StartScreenEffect("MP_job_load", 0, true)
                        elseif symptom == "mareo" then
                            StartScreenEffect("DrugsDrivingOut", 0, true)
                        elseif symptom == "estornudos" then
                            local playerPed = PlayerPedId()
                            local particleDictionary = "cut_bigscr"
                            local particleName = "cs_bigscr_beer_spray"
                            RequestNamedPtfxAsset(particleDictionary)
                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                Citizen.Wait(1)
                            end
                            SetPtfxAssetNextCall(particleDictionary)
                            local bone = GetPedBoneIndex(playerPed, 47495)
                            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0,
                                0.0, 20.0, bone,
                                1.0, false, false, false)
                            Citizen.Wait(1000)
                            local effect2 = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0,
                                0.0, 20.0,
                                bone, 1.0, false, false, false)
                            Citizen.Wait(3500)
                            StopParticleFxLooped(effect, 0)
                            StopParticleFxLooped(effect2, 0)
                        elseif symptom == "diarrea" then
                            local playerPed = PlayerPedId()
                            local particleDictionary = "scr_amb_chop"
                            local particleName = "ent_anim_dog_poo"
                            local animDict = "missfbi3ig_0"
                            local animName = "shit_react_trev"
                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Citizen.Wait(1)
                            end
                            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
                            RequestNamedPtfxAsset(particleDictionary)
                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                Citizen.Wait(1)
                            end
                            SetPtfxAssetNextCall(particleDictionary)
                            local bone = GetPedBoneIndex(playerPed, 11816)
                            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, 0.0, 0.0, -0.2, -90.0,
                                0.0, 0.0, bone,
                                1.0, false, false, false)
                            Citizen.Wait(Config.SymptomsDurations["diarrea"])
                            StopParticleFxLooped(effect, 0)
                            RemoveAnimDict(animDict)
                            ClearPedTasksImmediately(PlayerPedId())
                        elseif symptom == "vomito" then
                            local playerPed = PlayerPedId()
                            local particleDictionary = "cut_paletoscore"
                            local particleName = "cs_paleto_vomit"
                            local animDict = "missheistpaletoscore1leadinout"
                            local animName = "trv_puking_leadout"
                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Citizen.Wait(1)
                            end
                            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
                            RequestNamedPtfxAsset(particleDictionary)
                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                Citizen.Wait(1)
                            end
                            SetPtfxAssetNextCall(particleDictionary)
                            local bone = GetPedBoneIndex(playerPed, 47495)
                            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0,
                                0.0, 20.0, bone,
                                1.0, false, false, false)
                            Citizen.Wait(Config.SymptomsDurations["vomito"])
                            StopParticleFxLooped(effect, 0)
                            RemoveAnimDict(animDict)
                            ClearPedTasksImmediately(PlayerPedId())
                        end
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('RemoveAllEffects')
AddEventHandler('RemoveAllEffects', function()
    StopAllScreenEffects()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    ResetPedMovementClipset(PlayerPedId(), 1.0)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        return
    end
    ClearPedTasksImmediately(PlayerPedId())
    for animName, _ in pairs(animTimers) do
        if DoesEntityExist(PlayerPedId()) then
            ClearPedTasksImmediately(PlayerPedId())
        end
        animTimers[animName] = nil
    end
    SetPedMoveRateOverride(PlayerPedId(), 1.0)
    isFalling = false
    StopGameplayCamShaking(true)
    playerDiseases = {}
    local playerPed = PlayerPedId()
    RemoveAllParticleEffects(playerPed)
    disease = nil
    diseaseName = nil
    DebugPrint("Todos los síntomas y efectos han sido detenidos.")
end)

function RemoveAllParticleEffects(playerPed)
    local particleDictionaryList = {
        "cut_paletoscore",
        "scr_amb_chop",
    }

    for _, dictionary in ipairs(particleDictionaryList) do
        RemoveNamedPtfxAsset(dictionary)
    end
end

Citizen.CreateThread(function()
    while true do
        local minWaitTime = Config.MinWaitTimeMinutes * 60 * 1000
        local maxWaitTime = Config.MaxWaitTimeMinutes * 60 * 1000

        local randomWaitTime = math.random(minWaitTime, maxWaitTime)
        Citizen.Wait(randomWaitTime)

        if not playerInjured then
            local disease = GetRandomDisease()
            DebugPrint("El jugador ha contraído la enfermedad: " .. disease)
            TriggerEvent('ApplySymptoms', disease)
        end
    end
end)

RegisterNetEvent('PlayCureAnimation')
AddEventHandler('PlayCureAnimation', function()
    local playerPed = PlayerPedId()
    RequestAnimDict("mp_suicide")

    while not HasAnimDictLoaded("mp_suicide") do
        Citizen.Wait(100)
    end

    alreadyInfected = false

    TaskPlayAnim(playerPed, "mp_suicide", "pill", 8.0, -8.0, 3000, 49, 0, false, false, false)

    Citizen.Wait(3000)
end)

local infectedPlayers = {}

function CheckNearbyPlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if not diseaseName then
        return
    end

    local rangoContagio = Config.Enfermedades[diseaseName] and Config.Enfermedades[diseaseName].rangoContagio
    local nearbyPlayers = lib.getNearbyPlayers(playerCoords, rangoContagio, false)
    DebugPrint("Jugadores cercanos: " .. #nearbyPlayers)

    for _, player in ipairs(nearbyPlayers) do
        local playerId = player.id
        local targetPed = player.ped
        local targetCoords = player.coords
        local distance = #(playerCoords - targetCoords)

        DebugPrint("Verificando jugador con ID: " .. playerId)
        DebugPrint("Distancia entre jugador y objetivo: " .. distance)

        if playerId ~= PlayerId() then
            if distance < Config.Enfermedades[diseaseName].rangoContagio and playerDiseases[diseaseName] then
                if not infectedPlayers[playerId] then
                    infectedPlayers[playerId] = true
                    TriggerServerEvent('infectarJugador', GetPlayerServerId(playerId), diseaseName)
                    DebugPrint("Jugador " .. playerId .. " ha sido contagiado por " .. diseaseName)
                else
                    DebugPrint("Jugador " .. playerId .. " ya está infectado.")
                end
            else
                DebugPrint("Jugador " ..
                    playerId .. " no está dentro del rango de contagio o no tiene la enfermedad activa.")
            end
        else
            DebugPrint("El jugador con ID " ..
                playerId .. " es el jugador local (ID: " .. PlayerId() .. "), no se verificará.")
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        CheckNearbyPlayers()
    end
end)

RegisterNetEvent('cureAllDiseases')
AddEventHandler('cureAllDiseases', function(PlayerId)
    exports['muhaddil_infections']:CureAllDiseases(PlayerId)
    alreadyInfected = false
end)

exports('CureAllDiseases', function(playerId)
    TriggerServerEvent('muhaddil_infections:CureAllDiseases', playerId)
    alreadyInfected = false
end)

if Framework == 'esx' then
    AddEventHandler('brutal_ambulancejob:revive', function()
        local PlayerId = PlayerId()
        local playerServerID = GetPlayerServerId(PlayerId)
        exports['muhaddil_infections']:CureAllDiseases(playerServerID)
        alreadyInfected = false
    end)
elseif Framework == 'qb' then
    AddEventHandler('hospital:client:Revive', function()
        local PlayerId = PlayerId()
        local playerServerID = GetPlayerServerId(PlayerId)
        exports['muhaddil_infections']:CureAllDiseases(playerServerID)
        alreadyInfected = false
    end)
end

-- function CureAllDiseases(PlayerId)
--     TriggerServerEvent('muhaddil_infections:CureAllDiseases', PlayerId)
-- end

-- exports("CureAllDiseases", CureAllDiseases)
-- exports['muhaddil_infections']:CureAllDiseases(playerId) -- ServerSide ID
-- exports['muhaddil_infections']:CureAllDiseases()


if Config.EnableAddictions then

    local function contains(table, element)
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
        return false
    end

    function UpdateEffects()
        for i = #activeEffects, 1, -1 do
            local effect = activeEffects[i]
            if not IsEffectActiveForClipset(effect.clipset) then
                table.remove(activeEffects, i)
            end
        end

        for item, level in pairs(currentLevels) do
            local preset = GetPresetForItem(item)
            if preset then
                for _, effect in ipairs(preset.effects) do
                    if level >= effect.level then
                        ApplyEffect(effect)
                        ApplyPhysicalEffect(effect)
                        table.insert(activeEffects, effect)
                    end
                end
            end
        end
    end

    function ApplyEffect(effect)
        Citizen.CreateThread(function()
            while contains(activeEffects, effect) do
                if effect.type == 'shake' then
                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', effect.intensity)
                elseif effect.type == 'timecycle' then
                    SetTimecycleModifier(effect.modifier)
                    SetTimecycleModifierStrength(1.0)
                elseif effect.type == 'movement' then
                    if not IsPedUsingAnyScenario(PlayerPedId()) then
                        SetPedMovementClipset(PlayerPedId(), effect.clipset, 1.0)
                    end
                elseif effect.type == 'screenfx' then
                    AnimpostfxPlay(effect.effect, 0, true)
                    Citizen.Wait(3000)
                    AnimpostfxStop(effect.effect)
                elseif effect.type == 'blur' then
                    TriggerScreenblurFadeIn(1000)
                    Citizen.Wait(5000)
                    TriggerScreenblurFadeOut(1000)
                elseif effect.type == 'hallucinations' then
                    if math.random() < effect.chance then
                        PlaySoundFrontend(-1, "Bed", "WastedSounds", true)
                        Citizen.Wait(2000)
                    end
                elseif effect.type == 'heartbeat' then
                    StartScreenEffect('DeathFailMPDark', 0, true)
                    Citizen.Wait(1000)
                    StopScreenEffect('DeathFailMPDark')
                elseif effect.type == 'blackout' then
                    if math.random() < effect.chance then
                        SetPedToRagdoll(PlayerPedId(), 5000, 5000, 0, true, true, false)
                    end
                end

                Citizen.Wait(effect.interval or 1000)
            end

            ClearTimecycleModifier()
            ResetPedMovementClipset(PlayerPedId(), 0.25)
            StopAllScreenEffects()
        end)
    end

    function ApplyPhysicalEffect(effect)
        local playerPed = PlayerPedId()

        if effect.type == 'cough' then
            Citizen.CreateThread(function()
                if math.random() < effect.chance then
                    while effect.type == 'cough' do
                        LoadAnimDict('timetable@gardener@smoking_joint')
                        TaskPlayAnim(PlayerPedId(), 'timetable@gardener@smoking_joint', 'idle_cough', 8.0, -8.0, -1, 49,
                            1,
                            false, false, false)
                        Citizen.Wait(6 * 1000)
                        SetRunSprintMultiplierForPlayer(PlayerId(), 0.7)
                    end
                end
            end)

        elseif effect.type == 'movement' then
            if not physicalEffects.currentClipsets[effect.clipset] then
                RequestAnimSet(effect.clipset)
                while not HasAnimSetLoaded(effect.clipset) do
                    Citizen.Wait(10)
                end

                SetPedMovementClipset(playerPed, effect.clipset, 1.0)
                SetRunSprintMultiplierForPlayer(PlayerId(), effect.speedMultiplier or 1.0)
                physicalEffects.currentClipsets[effect.clipset] = true
            end

        elseif effect.type == 'ragdoll' then
            Citizen.CreateThread(function()
                while effect.type == 'ragdoll' do
                    if effect.triggerOnMovement and IsPedRunning(playerPed) or effect.triggerOnMovement and not IsPedRunning(playerPed) then
                        if math.random() < effect.chance then
                            SetPedToRagdoll(playerPed, 2000, 5000, 0, true, true, false)
                            print('Ragdoll')
                            Citizen.Wait(30 * 1000)
                        end
                    end
                end
            end)

        elseif effect.type == 'blackout' then
            if math.random() < effect.chance then
                SetPedToRagdoll(playerPed, effect.duration, effect.duration, 0, true, true, false)
                StartScreenEffect('DeathFailMPDark', 0, true)
                Citizen.Wait(effect.duration)
                StopScreenEffect('DeathFailMPDark')
            end
            
        elseif effect.type == 'tremors' then
            Citizen.CreateThread(function()
                while effect.active do
                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', effect.intensity)
                    ApplyForceToEntity(playerPed, 1,
                        math.random(-effect.intensity, effect.intensity),
                        math.random(-effect.intensity, effect.intensity),
                        0.0, 0.0, 0.0, 0.0, true, true, true, false, true)
                    Citizen.Wait(effect.interval)
                end
            end)
        end
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)

            for clipset, _ in pairs(physicalEffects.currentClipsets) do
                if not IsEffectActiveForClipset(clipset) then
                    ResetPedMovementClipset(PlayerPedId(), 0.25)
                    physicalEffects.currentClipsets[clipset] = nil
                end
            end

            SetPlayerStamina(PlayerId(), 0.0)
        end
    end)

    function IsEffectActiveForClipset(clipset)
        for _, effect in pairs(activeEffects) do
            if effect.type == 'movement' and effect.clipset == clipset then
                return true
            end
        end
        return false
    end

    function GetPresetForItem(item)
        for presetName, preset in pairs(Config.AddictionPresets) do
            if contains(preset.items, item) then
                return preset
            end
        end
        return nil
    end

    RegisterNetEvent('addiction:update', function(levels)
        currentLevels = levels
        UpdateEffects()
    end)

    Citizen.CreateThread(function()
        while true do
            TriggerServerEvent('addiction:load')
            Citizen.Wait(1000 * 60)
        end
    end)

    RegisterNetEvent('addiction:startTreatment')
    AddEventHandler('addiction:startTreatment', function(data)
        TriggerServerEvent('addiction:recover', data.item)
    end)

    exports('StopAllEffects', function()
        StopAllEffects()
    end)

    function StopAllEffects()
        activeEffects = {}

        ResetPedMovementClipset(PlayerPedId(), 0.25)
        physicalEffects = {
            activeMovements = {},
            currentClipsets = {},
        }

        ClearTimecycleModifier()
        StopAllScreenEffects()

        SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)

        ResetPedMovementClipset(PlayerPedId(), 0.25)
    end

    RegisterCommand('stopEffects', function(source, args, rawCommand)
        exports['muhaddil_infections']:StopAllEffects()
    end, false)

end