local playerDiseases = {}

if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.FrameWork == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

local animTimers = {}
local isFalling = false

function LoadAnimDict(dict)
    print("Intentando cargar el diccionario de animaciones: " .. dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    print("Diccionario de animaciones cargado: " .. dict)
end

local playerInjured = false 
local disease = nil

local function GetRandomDisease()
    local diseases = {}
    for key, _ in pairs(Config.Enfermedades) do
        table.insert(diseases, key)
    end
    return diseases[math.random(#diseases)]
end

local function StartContagionTimer(playerId)
    Citizen.CreateThread(function()
        Citizen.Wait(60000)

        if playerInjured and disease then
            print('Jugador infectado con ' .. disease)
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
            print('Jugador dañado')
            disease = GetRandomDisease()
            StartContagionTimer(PlayerId())
        end
    end
end)

AddEventHandler('playerSpawned', function()
    playerInjured = false
    disease = nil
    print('Jugador reapareció, estado de lesión reiniciado')
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
    local symptoms = Config.Enfermedades[disease].symptoms
    local animaciones = Config.Enfermedades[disease].animaciones
    local efectos = Config.Enfermedades[disease].efectos
    playerDiseases[disease] = true

    for _, symptom in ipairs(symptoms) do
        if symptom == "cansancio" then
            SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
        elseif symptom == "vision_borrosa" then
            StartScreenEffect("DrugsMichaelAliensFightIn", 0, true)
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
            local effect = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone, 1.0, false, false, false)
            Citizen.Wait(1000)
            local effect2 = StartParticleFxLoopedOnPedBone(particleName, playerPed, -0.1, 0.5, 0.5, -90.0, 0.0, 20.0, bone, 1.0, false, false, false)
            Citizen.Wait(3500)
            StopParticleFxLooped(effect, 0)
            StopParticleFxLooped(effect2, 0)
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
                local randomWaitTime = math.random(30000, 120000)
                Citizen.Wait(30000)

                print("Deteniendo efectos por " .. (randomWaitTime / 1000) .. " segundos.")
                TriggerEvent('RemoveAllEffects')

                Citizen.Wait(randomWaitTime)

                if playerDiseases[disease] then
                    print("Reiniciando efectos.")
                    for _, symptom in ipairs(symptoms) do
                        if symptom == "cansancio" then
                            SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
                        elseif symptom == "vision_borrosa" then
                            StartScreenEffect("DrugsMichaelAliensFightIn", 0, true)
                        elseif symptom == "calor_extremo" then
                            StartScreenEffect("MP_job_load", 0, true)
                        elseif symptom == "mareo" then
                            StartScreenEffect("DrugsDrivingOut", 0, true)
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

    for animName, _ in pairs(animTimers) do
        ClearPedTasks(PlayerPedId())
        animTimers[animName] = nil
    end

    SetPedMoveRateOverride(PlayerPedId(), 1.0)
    isFalling = false

    StopGameplayCamShaking(true)

    playerDiseases = {}
end)
