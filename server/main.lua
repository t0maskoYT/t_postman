RegisterServerEvent("t_postman:giveBox")
AddEventHandler('t_postman:giveBox', function ()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addInventoryItem(Config.addItemStock, 1)
end)

lib.callback.register('t_postman:rentCar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local test = xPlayer.getInventoryItem("money")
    if test.count >= 100 then
        xPlayer.removeInventoryItem("money", 100)
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_item_error',
            title = 'Nemáš 100$, aby sis to mohl půjčit!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = { color = '#909296' }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        return false
    end
end)

lib.callback.register('t_postman:backCar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isVehicleNearby = lib.callback.await('t_postman:checkVehicle', source, Config.car)
    if isVehicleNearby then
        xPlayer.addInventoryItem("money", 100)
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_vehicle_error',
            title = 'Auto není v dosahu!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = { color = '#909296' }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        return false
    end
end)

lib.callback.register('t_postman:done', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local pay = math.random(Config.Pay1, Config.Pay2)
    local item = Config.addItemStock
    local test = xPlayer.getInventoryItem(item)
    if test.count >= 1 then
        xPlayer.removeInventoryItem(Config.addItemStock, 1)
        xPlayer.addMoney(pay)
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_item_error',
            title = 'Nemáš balík!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = { color = '#909296' }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        return false
    end
end)

local spawnedNPCs = {}

-- Funkce pro spawn NPC
local function createNPC(identifier, model, x, y, z, heading, name)
    local hash = GetHashKey(model)
    --print("Pokus o spawn NPC: " .. identifier .. " s modelem " .. model .. " na [" .. x .. ", " .. y .. ", " .. z .. "]")

    -- Vytvoření NPC na serveru
    local npc = CreatePed(4, hash, x, y, z, heading, true, true) -- Síťová entita
    if not npc or not DoesEntityExist(npc) then
        -- --print("CHYBA: Nepodařilo se vytvořit NPC s identifikátorem " .. identifier .. " (model: " .. model .. ")")
        return
    end

    spawnedNPCs[identifier] = npc
    local netId = NetworkGetNetworkIdFromEntity(npc)

    -- Kontrola, zda má entita validní netId
    if netId == 0 then
        -- --print("CHYBA: NPC " .. identifier .. " nemá validní netId (možná chyba sítě)")
        DeleteEntity(npc)
        spawnedNPCs[identifier] = nil
        return
    end

    -- Synchronizace s klienty
    -- --print("Posílám sync pro NPC: " .. identifier .. " s netId: " .. netId)
    TriggerClientEvent('t_postman:syncNPC', -1, identifier, netId)
    Citizen.Wait(50) -- Krátké čekání pro zajištění, že klienti NPC zaregistrují
    -- --print("Posílám nastavení vlastností pro NPC: " .. identifier .. " s netId: " .. netId)
    TriggerClientEvent('t_postman:setNPCProperties', -1, netId)

    -- --print("NPC s identifikátorem " .. identifier .. " spawnuto na serveru (netId: " .. netId .. ")")
end

-- Funkce pro despawn NPC
local function despawnNPC(identifier)
    if spawnedNPCs[identifier] and DoesEntityExist(spawnedNPCs[identifier]) then
        local netId = NetworkGetNetworkIdFromEntity(spawnedNPCs[identifier])
        DeleteEntity(spawnedNPCs[identifier])
        spawnedNPCs[identifier] = nil
        TriggerClientEvent('t_postman:syncNPC', -1, identifier, nil)
        -- --print("NPC s identifikátorem " .. identifier .. " despawnuto")
    end
end

-- Event od klienta pro kontrolu vzdálenosti
RegisterNetEvent('t_postman:checkNPCDistance')
AddEventHandler('t_postman:checkNPCDistance', function(identifier, model, x, y, z, heading, name, inRange)
    if inRange then
        if not spawnedNPCs[identifier] or not DoesEntityExist(spawnedNPCs[identifier]) then
            createNPC(identifier, model, x, y, z, heading, name)
        end
    else
        local playersInRange = 0
        for _, playerId in ipairs(GetPlayers()) do
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector3(x, y, z) - playerCoords)
            if distance <= 35.0 then
                playersInRange = playersInRange + 1
            end
        end
        if playersInRange == 0 then
            despawnNPC(identifier)
        end
    end
end)

-- Inicializace při startu resource
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- --print("Resource " .. resourceName .. " startuje, NPC čekají na hráče v dosahu")
    end
end)

-- Cleanup při zastavení resource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for identifier, npc in pairs(spawnedNPCs) do
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end
        spawnedNPCs = {}
    end
end)