OX Inventory
['medicina_gripe'] = { close = false, stack = true, description = "Medicamento para tratar la gripe.", weight = 50, label = "Medicina Gripe" },
['medicina_fiebre'] = { close = false, stack = true, description = "Medicamento para reducir la fiebre.", weight = 50, label = "Medicina Fiebre" },
['analgesico'] = { close = false, stack = true, description = "Medicamento para aliviar el dolor.", weight = 50, label = "Analgésico" },
['medicina_insomnio'] = { close = false, stack = true, description = "Medicamento para tratar el insomnio.", weight = 50, label = "Medicina Insomnio" },
['medicina_nauseas'] = { close = false, stack = true, description = "Medicamento para aliviar las náuseas.", weight = 50, label = "Medicina Náuseas" },
['medicina_migrana'] = { close = false, stack = true, description = "Medicamento para aliviar la migraña.", weight = 50, label = "Medicina Migraña" },
['medicina_resfriado'] = { close = false, stack = true, description = "Medicamento para tratar el resfriado.", weight = 50, label = "Medicina Resfriado" },

ESX
INSERT INTO `items` (`name`, `label`, `limit`) VALUES
('medicina_gripe', 'Medicina Gripe', 10),
('medicina_fiebre', 'Medicina Fiebre', 10),
('analgesico', 'Analgésico', 10),
('medicina_insomnio', 'Medicina Insomnio', 10),
('medicina_nauseas', 'Medicamento para Náuseas', 10),
('medicina_migrana', 'Medicamento para Migraña', 10),
('medicina_resfriado', 'Medicina para Resfriado', 10);


QBCore
    ['medicina_gripe'] = {
        name = 'medicina_gripe',
        label = 'Medicina Gripe',
        weight = 50,
        type = 'item',
        image = 'medicina_gripe.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para tratar la gripe'
    },
    ['medicina_fiebre'] = {
        name = 'medicina_fiebre',
        label = 'Medicina Fiebre',
        weight = 50,
        type = 'item',
        image = 'medicina_fiebre.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para reducir la fiebre'
    },
    ['analgesico'] = {
        name = 'analgesico',
        label = 'Analgésico',
        weight = 50,
        type = 'item',
        image = 'analgesico.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para aliviar el dolor'
    },
    ['medicina_insomnio'] = {
        name = 'medicina_insomnio',
        label = 'Medicina Insomnio',
        weight = 50,
        type = 'item',
        image = 'medicina_insomnio.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para tratar el insomnio'
    },
    ['medicina_nauseas'] = {
        name = 'medicina_nauseas',
        label = 'Medicamento para Náuseas',
        weight = 50,
        type = 'item',
        image = 'medicina_nauseas.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para aliviar las náuseas'
    },
    ['medicina_migrana'] = {
        name = 'medicina_migrana',
        label = 'Medicamento para Migraña',
        weight = 50,
        type = 'item',
        image = 'medicina_migrana.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para aliviar la migraña'
    },
    ['medicina_resfriado'] = {
        name = 'medicina_resfriado',
        label = 'Medicina para Resfriado',
        weight = 50,
        type = 'item',
        image = 'medicina_resfriado.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Medicamento para tratar el resfriado'
    },