if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
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

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

function SendNotification(msgtitle, msg, time, type)
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
        if Config.FrameWork == 'qb' then
            QBCore.Functions.Notify(msg, type, time)
        elseif Config.FrameWork == 'esx' then
            TriggerEvent('esx:showNotification', msg, type, time)
        end
    end
end

RegisterNetEvent("muhaddil_infections:SendNotification")
AddEventHandler("muhaddil_infections:SendNotification", function(msgtitle, msg, time, type)
    SendNotification(msgtitle, msg, time, type)
end)

function LoadAnimDict(dict)
    DebugPrint(locale('loadinganimdictionary') ..dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    DebugPrint(locale('loadedanimdict') ..dict)
end

local function GetRandomDisease()
    local diseases = {}
    for key, _ in pairs(Config.Enfermedades) do
        table.insert(diseases, key)
    end
    return diseases[math.random(#diseases)]
end

function EstaEnAgua()
    local playerPed = PlayerPedId()
    return IsEntityInWater(playerPed)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if EstaEnAgua() then
            tiempoEnAgua = tiempoEnAgua + 1
            enAgua = true
        else
            tiempoEnAgua = 0
            enAgua = false
        end

        if tiempoEnAgua >= Config.WaterTime and enAgua then
            local enfermedad = GetRandomDisease()
            TriggerServerEvent('infectarJugador', enfermedad)
            tiempoEnAgua = 0
        end
    end
end)

local function StartContagionTimer(playerId)
    Citizen.CreateThread(function()
        Citizen.Wait(Config.ContagionTimer)

        if playerInjured and disease then
            DebugPrint(locale('infectedwith') .. disease)
            TriggerServerEvent('infectarJugador', disease)
            disease = nil
        end
    end)
end

AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkEntityDamage" then
        local playerPed = PlayerPedId()
        if args[1] == playerPed then
            playerInjured = true
            DebugPrint('Jugador dañado')
            disease = GetRandomDisease()
            StartContagionTimer(PlayerId())
        end
    end
end)

AddEventHandler('playerSpawned', function()
    playerInjured = false
    disease = nil
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
                    if math.random() < 0.1 then
                        if not isFalling then
                            isFalling = true
                            ShakeGameplayCam("DRUNK_SHAKE", 1.0)
                            SetPedToRagdoll(PlayerPedId(), 5000, 5000, 0, false, false, false)
                            Citizen.Wait(10000)
                            isFalling = false
                        end
                    end
                    Citizen.Wait(10000)
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

                DebugPrint("Deteniendo efectos por " .. (randomWaitTime / 1000) .. " segundos.")
                TriggerEvent('RemoveAllEffects')

                Citizen.Wait(randomWaitTime)

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
                DebugPrint("Jugador " .. playerId .. " no está dentro del rango de contagio o no tiene la enfermedad activa.")
            end
        else
            DebugPrint("El jugador con ID " .. playerId .. " es el jugador local (ID: " .. PlayerId() .. "), no se verificará.")
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
end)

exports('CureAllDiseases', function(playerId)
    TriggerServerEvent('muhaddil_infections:CureAllDiseases', playerId)
end)

-- function CureAllDiseases(PlayerId)
--     TriggerServerEvent('muhaddil_infections:CureAllDiseases', PlayerId)
-- end

-- exports("CureAllDiseases", CureAllDiseases)
-- exports['muhaddil_infections']:CureAllDiseases(playerId)
-- exports['muhaddil_infections']:CureAllDiseases()
