Config = {}

Config.AdminGroups = { "god", "admin", "mod" } -- Only ESX

Config.InmuneJobs = {
    "ambulance"
}

Config.ContagionTimer = 300     -- Time in seconds before checking for contagion
Config.MinWaitTimeMinutes = 60  -- In minutes
Config.MaxWaitTimeMinutes = 120 -- In minutes
Config.WaterTime = 30           -- Time needed in seconds to be infected by cold from being in the water

Config.SymptomsDurations = {
    diarrea = 15000, -- 15 seconds
    vomito = 15000,  -- 15 seconds
}

Config.EffectDuration = 30 -- Duration (in seconds) for which the disease effects last before stopping
Config.RandomTimeMin = 30  -- Minimum time (in seconds) for which the disease effects stop
Config.RandomTimeMax = 120 -- Maximum time (in seconds) for which the disease effects stop

-- Disease settings
-- Valid symptoms: "cansancio", "vision_borrosa", "calor_extremo", "mareo", "irritabilidad", "vomito", "diarrea", "dolor_cabeza", "estornudos"
Config.Enfermedades = {
    ["gripe"] = {                                     -- Flu
        symptoms = { "cansancio", "vision_borrosa" }, -- Fatigue, blurry vision
        duration = 600,                               -- Duration in seconds
        contagio = 0.8,                               -- Contagion rate (80%)
        rangoContagio = 10.0,                         -- Contagion range
        cureItem = "medicina_gripe",                  -- Cure item
        animaciones = {
            -- ["tos"] = {  -- Cough animation
            --     dict = "timetable@gardener@smoking_joint",
            --     anim = "idle_cough",
            --     delay = 20,
            -- }
        },
        efectos = {                  -- Effects on player
            movimiento_lento = true, -- Slow movement
            debilitado = true,       -- Weakened
        }
    },
    ["fiebre"] = {                                   -- Fever
        symptoms = { "calor_extremo", "cansancio" }, -- Extreme heat, fatigue
        duration = 900,                              -- Duration in seconds
        contagio = 0.6,                              -- Contagion rate (60%)
        rangoContagio = 8.0,                         -- Contagion range
        cureItem = "medicina_fiebre",                -- Cure item
        animaciones = {
            ["calor_extremo"] = {                    -- Extreme heat animation
                dict = "move_m@drunk@verydrunk",
                anim = "idle",
                delay = 30,
            }
        },
        efectos = {                    -- Effects on player
            tambaleo = true,           -- Stumbling
            caida_involuntaria = true, -- Involuntary fall
        }
    },
    ["dolor_cabeza"] = {                          -- Headache
        symptoms = { "vision_borrosa", "mareo" }, -- Blurry vision, dizziness
        duration = 300,                           -- Duration in seconds
        contagio = 0.5,                           -- Contagion rate (50%)
        rangoContagio = 5.0,                      -- Contagion range
        cureItem = "analgesico",                  -- Cure item
        animaciones = {
            ["mareo"] = {                         -- Dizziness animation
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 25,
            }
        },
        efectos = {                -- Effects on player
            vision_borrosa = true, -- Blurry vision
        }
    },
    ["insomnio"] = {                                 -- Insomnia
        symptoms = { "cansancio", "irritabilidad" }, -- Fatigue, irritability
        duration = 1200,                             -- Duration in seconds
        contagio = 0.8,                              -- Contagion rate (80%)
        rangoContagio = 10.0,                        -- Contagion range
        cureItem = "medicina_insomnio",              -- Cure item
        animaciones = {
            ["despertar"] = {                        -- Waking up animation
                dict = "move_m@crazy",
                anim = "walk",
                delay = 60,
            }
        },
        efectos = {                  -- Effects on player
            movimiento_lento = true, -- Slow movement
        }
    },
    ["nauseas"] = {                       -- Nausea
        symptoms = { "mareo", "vomito" }, -- Dizziness, vomiting
        duration = 800,                   -- Duration in seconds
        contagio = 0.8,                   -- Contagion rate (80%)
        rangoContagio = 10.0,             -- Contagion range
        cureItem = "medicina_nauseas",    -- Cure item
        animaciones = {
            ["vomito"] = {                -- Vomiting animation
                dict = "missheistpaletoscore1leadinout",
                anim = "trv_puking_leadout",
                delay = 45,
            }
        },
        efectos = {          -- Effects on player
            tambaleo = true, -- Stumbling
        }
    },
    ["migrana"] = {                                      -- Migraine
        symptoms = { "dolor_cabeza", "vision_borrosa" }, -- Headache, blurry vision
        duration = 600,                                  -- Duration in seconds
        contagio = 0.0,                                  -- Contagion rate (0%)
        rangoContagio = 0.0,                             -- No contagion
        cureItem = "medicina_migrana",                   -- Cure item
        animaciones = {
            ["dolor_cabeza"] = {                         -- Headache animation
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 30,
            }
        },
        efectos = {                    -- Effects on player
            vision_borrosa = true,     -- Blurry vision
            debilitado = true,         -- Weakened
            tambaleo = true,           -- Stumbling
            caida_involuntaria = true, -- Involuntary fall
        }
    },
    ["resfriado"] = {                       -- Cold
        symptoms = { "tos", "estornudos" }, -- Coughing, sneezing
        duration = 600,                     -- Duration in seconds
        contagio = 0.8,                     -- Contagion rate (80%)
        rangoContagio = 10.0,               -- Contagion range
        cureItem = "medicina_resfriado",    -- Cure item
        animaciones = {
            ["estornudar"] = {              -- Sneezing animation
                dict = "timetable@gardener@smoking_joint",
                anim = "idle_cough",
                delay = 20,
            }
        },
        efectos = {            -- Effects on player
            debilitado = true, -- Weakened
        }
    },
    ["rotura de pierna"] = {                  -- Broken leg
        symptoms = { "cansancio", "mareos" }, -- Fatigue, dizziness
        duration = 600,                       -- Duration in seconds
        contagio = 0.8,                       -- Contagion rate (80%)
        rangoContagio = 0.0,                  -- Contagion range
        cureItem = "ferula_pierna",           -- Cure item
        animaciones = {},
        efectos = {                           -- Effects on player
            debilitado = true,                -- Weakened
            caida_involuntaria = true,        -- Involuntary fall
            tambaleo = true,                  -- Stumbling
        }
    },
}

Config.TiempoChequeoContagio = 5 -- Time in seconds before checking for contagion
Config.FrameWork = 'auto'        -- Framework being used (auto, esx or qb)
Config.AutoRunSQL = false        -- Automatically runs the necessary SQL
Config.AutoVersionChecker = true -- Automatically check for updates
Config.DebugMode = true          -- Debug mode (false = off)
Config.UseOXNotifications = true -- If the script uses the ox_libs notifications or framework ones
Config.ShowNotifications = true  -- Show notifications (false = off)

Config.EnableAddictions = true -- Enable addiction system

Config.AddictionPresets = {
    ['tabaco'] = {
        items = {'cigarette', 'cigar', 'vape'},
        effects = {
            {
                level = 20, 
                type = 'shake',
                intensity = 0.3,
                description = "Temblor leve en las manos"
            },
            {
                level = 50, 
                type = 'cough', 
                chance = 1,
                interval = 120,
                description = "Ataques de tos ocasionales"
            },
            {
                level = 80,
                type = 'stamina',
                modifier = 0.8,
                description = "Dificultad para respirar"
            }
        }
    },
    ['alcohol'] = {
        items = {'beer', 'whiskey', 'vodka'},
        effects = {
            {
                level = 30,
                type = 'blur',
                intensity = 0.5,
                description = "Visión ligeramente borrosa"
            },
            {
                level = 60,
                type = 'movement',
                clipset = 'MOVE_M@DRUNK@VERYDRUNK',
                description = "Movimiento ebrio"
            },
            {
                level = 80,
                type = 'timecycle',
                modifier = 'Drunk',
                description = "Efecto de borrachera intensa"
            }
        }
    },
    ['marihuana'] = {
        items = {'weed', 'joint', 'edible'},
        effects = {
            {
                level = 25,
                type = 'timecycle',
                modifier = 'drug_flying_01',
                description = "Colores más vibrantes"
            },
            {
                level = 50,
                type = 'screenfx',
                effect = 'DrugsMichaelAliensFight',
                description = "Efectos visuales psicodélicos"
            },
            {
                level = 75,
                type = 'reaction',
                modifier = 0.6,
                description = "Reflejos disminuidos"
            },
            {
                level = 75,
                type = 'ragdoll',
                triggerOnMovement = true,
                chance = 2.2,
                description = "Desmayos repentinos"
            }
        }
    },
    ['cocaina'] = {
        items = {'coke', 'crack'},
        effects = {
            {
                level = 20,
                type = 'shake',
                intensity = 0.3,
                description = "Temblores intensos"
            },
            {
                level = 45,
                type = 'timecycle',
                modifier = 'MP_Corona_switch',
                description = "Visión hiper-enfocada"
            },
            {
                level = 70,
                type = 'heartbeat',
                interval = 30,
                description = "Palpitaciones cardíacas"
            },
            {
                level = 75,
                type = 'ragdoll',
                triggerOnMovement = true,
                chance = 2.2,
                description = "Desmayos repentinos"
            }
        }
    },
    ['opioides'] = {
        items = {'heroin', 'oxy', 'fentanyl'},
        effects = {
            {
                level = 15,
                type = 'timecycle',
                modifier = 'DeathFailMPIn',
                description = "Visión nublada"
            },
            {
                level = 40,
                type = 'movement',
                clipset = 'move_heist_lester',
                description = "Movimientos lentos"
            },
            {
                level = 65,
                type = 'hallucinations',
                chance = 0.4,
                description = "Alucinaciones auditivas"
            }
        }
    },
    ['estimulantes'] = {
        items = {'meth', 'adderall'},
        effects = {
            {
                level = 25,
                type = 'shake',
                intensity = 0.4,
                description = "Temblor incontrolable"
            },
            {
                level = 50,
                type = 'speed',
                modifier = 1.3,
                description = "Movimiento acelerado"
            },
            {
                level = 75,
                type = 'screenfx',
                effect = 'RaceTurbo',
                description = "Efecto de velocidad extrema"
            }
        }
    },
    ['lsd'] = {
        items = {'lsd', 'acid'},
        effects = {
            {
                level = 20,
                type = 'timecycle',
                modifier = 'ArenaEMP',
                description = "Distorsión cromática"
            },
            {
                level = 50,
                type = 'hallucinations',
                chance = 0.6,
                description = "Alucinaciones visuales"
            },
            {
                level = 60,
                type = 'movement',
                clipset = 'move_m@depressed@a',
                description = "Movimientos letárgicos"
            },
            {
                level = 80,
                type = 'screenfx',
                effect = 'DMT_flight',
                description = "Efecto psicodélico intenso"
            }
        }
    },
    ['benzodiacepinas'] = {
        items = {'xanax', 'valium'},
        effects = {
            {
                level = 30,
                type = 'blur',
                intensity = 0.7,
                description = "Visión muy borrosa"
            },
            {
                level = 60,
                type = 'movement',
                clipset = 'move_m@depressed@a',
                description = "Movimientos letárgicos"
            },
            {
                level = 90,
                type = 'blackout',
                chance = 0.2,
                description = "Desmayos repentinos"
            }
        }
    }
}

Config.AddictionRecovery = {
    base_reduction = 0.15,       -- Reducción base por tratamiento (15%)
    exponent = 1.8,              -- Dificultad exponencial
    max_level = 100,             -- Nivel máximo de adicción
    cooldown = 60,               -- Minutos entre tratamientos
    min_reduction = 5,           -- Reducción mínima absoluta
    max_reduction = 25           -- Reducción máxima absoluta
}