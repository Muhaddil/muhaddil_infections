Config = {}

Config.AdminGroups = { "god", "admin", "mod" } -- Only ESX

Config.InmuneJobs = {
    "ambulance"
}

Config.ContagionTimer = 1
Config.MinWaitTimeMinutes = 60 -- In minutes
Config.MaxWaitTimeMinutes = 120 -- In minutes
Config.WaterTime = 30 -- Time needed in seconds to be infected by cold from being in the water

Config.SymptomsDurations = {
    diarrea = 15000, -- 15 seconds
    vomito = 15000, -- 15 seconds
}

Config.EffectDuration = 30  -- Duration (in seconds) for which the disease effects last before stopping
Config.RandomTimeMin = 30   -- Minimum time (in seconds) for which the disease effects stop
Config.RandomTimeMax = 120  -- Maximum time (in seconds) for which the disease effects stop

-- Disease settings
-- Valid symptoms: "cansancio", "vision_borrosa", "calor_extremo", "mareo", "irritabilidad", "vomito", "diarrea", "dolor_cabeza", "estornudos"
Config.Enfermedades = {
    ["gripe"] = {  -- Flu
        symptoms = {"cansancio", "vision_borrosa"},  -- Fatigue, blurry vision
        duration = 600,  -- Duration in seconds
        contagio = 0.8,  -- Contagion rate (80%)
        rangoContagio = 10.0,  -- Contagion range
        cureItem = "medicina_gripe",  -- Cure item
        animaciones = {
            -- ["tos"] = {  -- Cough animation
            --     dict = "timetable@gardener@smoking_joint",
            --     anim = "idle_cough",
            --     delay = 20,
            -- }
        },
        efectos = {  -- Effects on player
            movimiento_lento = true,  -- Slow movement
            debilitado = true,  -- Weakened
        }
    },
    ["fiebre"] = {  -- Fever
        symptoms = {"calor_extremo", "cansancio"},  -- Extreme heat, fatigue
        duration = 900,  -- Duration in seconds
        contagio = 0.6,  -- Contagion rate (60%)
        rangoContagio = 8.0,  -- Contagion range
        cureItem = "medicina_fiebre",  -- Cure item
        animaciones = {
            ["calor_extremo"] = {  -- Extreme heat animation
                dict = "move_m@drunk@verydrunk",
                anim = "idle",
                delay = 30,
            }
        },
        efectos = {  -- Effects on player
            tambaleo = true,  -- Stumbling
            caida_involuntaria = true,  -- Involuntary fall
        }
    },
    ["dolor_cabeza"] = {  -- Headache
        symptoms = {"vision_borrosa", "mareo"},  -- Blurry vision, dizziness
        duration = 300,  -- Duration in seconds
        contagio = 0.5,  -- Contagion rate (50%)
        rangoContagio = 5.0,  -- Contagion range
        cureItem = "analgesico",  -- Cure item
        animaciones = {
            ["mareo"] = {  -- Dizziness animation
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 25,
            }
        },
        efectos = {  -- Effects on player
            vision_borrosa = true,  -- Blurry vision
        }
    },
    ["insomnio"] = {  -- Insomnia
        symptoms = {"cansancio", "irritabilidad"},  -- Fatigue, irritability
        duration = 1200,  -- Duration in seconds
        contagio = 0.8,  -- Contagion rate (80%)
        rangoContagio = 10.0,  -- Contagion range
        cureItem = "medicina_insomnio",  -- Cure item
        animaciones = {
            ["despertar"] = {  -- Waking up animation
                dict = "move_m@crazy",
                anim = "walk",
                delay = 60,
            }
        },
        efectos = {  -- Effects on player
            movimiento_lento = true,  -- Slow movement
        }
    },
    ["nauseas"] = {  -- Nausea
        symptoms = {"mareo", "vomito"},  -- Dizziness, vomiting
        duration = 800,  -- Duration in seconds
        contagio = 0.8,  -- Contagion rate (80%)
        rangoContagio = 10.0,  -- Contagion range
        cureItem = "medicina_nauseas",  -- Cure item
        animaciones = {
            ["vomito"] = {  -- Vomiting animation
                dict = "missheistpaletoscore1leadinout",
                anim = "trv_puking_leadout",
                delay = 45,
            }
        },
        efectos = {  -- Effects on player
            tambaleo = true,  -- Stumbling
        }
    },
    ["migrana"] = {  -- Migraine
        symptoms = {"dolor_cabeza", "vision_borrosa"},  -- Headache, blurry vision
        duration = 600,  -- Duration in seconds
        contagio = 0.0,  -- Contagion rate (0%)
        rangoContagio = 0.0,  -- No contagion
        cureItem = "medicina_migrana",  -- Cure item
        animaciones = {
            ["dolor_cabeza"] = {  -- Headache animation
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 30,
            }
        },
        efectos = {  -- Effects on player
            vision_borrosa = true,  -- Blurry vision
            debilitado = true,  -- Weakened
            tambaleo = true,  -- Stumbling
            caida_involuntaria = true,  -- Involuntary fall
        }
    },
    ["resfriado"] = {  -- Cold
        symptoms = {"tos", "estornudos"},  -- Coughing, sneezing
        duration = 600,  -- Duration in seconds
        contagio = 0.8,  -- Contagion rate (80%)
        rangoContagio = 10.0,  -- Contagion range
        cureItem = "medicina_resfriado",  -- Cure item
        animaciones = {
            ["estornudar"] = {  -- Sneezing animation
                dict = "timetable@gardener@smoking_joint",
                anim = "idle_cough",
                delay = 20,
            }
        },
        efectos = {  -- Effects on player
            debilitado = true,  -- Weakened
        }
    },
}

Config.TiempoChequeoContagio = 5  -- Time in seconds before checking for contagion
Config.FrameWork = 'auto'  -- Framework being used (auto, esx or qb)
Config.AutoRunSQL = true  -- Automatically runs the necessary SQL
Config.AutoVersionChecker = true  -- Automatically check for updates
Config.DebugMode = true  -- Debug mode (false = off)
Config.UseOXNotifications = true -- If the script uses the ox_libs notifications or framework ones
