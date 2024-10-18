Config = {}

-- Configuración de las enfermedades
Config.Enfermedades = {
    ["gripe"] = {
        symptoms = {"cansancio", "vision_borrosa"},
        duration = 600,
        contagio = 0.8,
        rangoContagio = 10.0,
        cureItem = "medicina_gripe",
        animaciones = {
            ["tos"] = {
                dict = "timetable@gardener@smoking_joint",
                anim = "idle_cough",
                delay = 20,
            }
        },
        efectos = {
            movimiento_lento = true,
            debilitado = true,
        }
    },
    ["fiebre"] = {
        symptoms = {"calor_extremo", "cansancio"},
        duration = 900,
        contagio = 0.6,
        rangoContagio = 8.0,
        cureItem = "medicina_fiebre",
        animaciones = {
            ["calor_extremo"] = {
                dict = "move_m@drunk@verydrunk",
                anim = "idle",
                delay = 30,
            }
        },
        efectos = {
            tambaleo = true,
            caida_involuntaria = true,
        }
    },
    ["dolor_cabeza"] = {
        symptoms = {"vision_borrosa", "mareo"},
        duration = 300,
        contagio = 0.5,
        rangoContagio = 5.0,
        cureItem = "analgesico",
        animaciones = {
            ["mareo"] = {
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 25,
            }
        },
        efectos = {
            vision_borrosa = true,
        }
    },
    ["insomnio"] = {
        symptoms = {"cansancio", "irritabilidad"},
        duration = 1200,
        contagio = 0.8,
        rangoContagio = 10.0,
        cureItem = "medicina_insomnio",
        animaciones = {
            ["despertar"] = {
                dict = "move_m@crazy",
                anim = "walk",
                delay = 60,
            }
        },
        efectos = {
            movimiento_lento = true,
        }
    },
    ["nauseas"] = {
        symptoms = {"mareo", "vomito"},
        duration = 800,
        contagio = 0.8,
        rangoContagio = 10.0,
        cureItem = "medicina_nauseas",
        animaciones = {
            ["vomito"] = {
                dict = "missheistpaletoscore1leadinout",
                anim = "trv_puking_leadout",
                delay = 45,
            }
        },
        efectos = {
            tambaleo = true,
        }
    },
    ["migrana"] = {
        symptoms = {"dolor_cabeza", "vision_borrosa"},
        duration = 600,
        contagio = 0.0,
        rangoContagio = 0.0,
        cureItem = "medicina_migrana",
        animaciones = {
            ["dolor_cabeza"] = {
                dict = "missfam5_yoga",
                anim = "f_getup_lamar",
                delay = 30,
            }
        },
        efectos = {
            vision_borrosa = true,
            debilitado = true,
            tambaleo = true,
            caida_involuntaria = true,
        }
    },
    ["resfriado"] = {
        symptoms = {"tos", "estornudos"},
        duration = 600,
        contagio = 0.8,
        rangoContagio = 10.0,
        cureItem = "medicina_resfriado",
        animaciones = {
            ["estornudar"] = {
                dict = "timetable@gardener@smoking_joint",
                anim = "idle_cough",
                delay = 20,
            }
        },
        efectos = {
            debilitado = true,
        }
    },
}

-- Tiempo de espera en segundos antes de verificar el contagio
Config.TiempoChequeoContagio = 5

Config.FrameWork = 'esx'
Config.AutoRunSQL = true
Config.AutoVersionChecker = true