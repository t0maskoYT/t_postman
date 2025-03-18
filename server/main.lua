RegisterServerEvent("t_postman:giveBox")
AddEventHandler('t_postman:giveBox', function ()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addInventoryItem(Config.addItemStock, 1)
    -- xPlayer.removeInventory(Config.rentCar)
end)

lib.callback.register('t_postman:rentCar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local test = xPlayer.getInventoryItem("money")
    -- print("Hráč " .. source .. " má " .. tostring(test.count) .. " peněz")
    if test.count >= 100 then
        xPlayer.removeInventoryItem("money", 100)
        -- print("Hráč " .. source .. " zaplatil 100 peněz za půjčení auta")
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_item_error',
            title = 'Nemáš dostatek peněz, aby sis to mohl půjčit!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        -- print("Hráč " .. source .. " nemá dost peněz na půjčení auta")
        return false
    end
end)

lib.callback.register('t_postman:backCar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local test = xPlayer.getInventoryItem("money")

    local isVehicleNearby = lib.callback.await('t_postman:checkVehicle', source, Config.car) -- Posíláme název modelu, ne hash

    if isVehicleNearby then
        xPlayer.addInventoryItem("money", 100)
        return true
    else
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_vehicle_error',
            title = 'Auto není v dosahu 40 jednotek!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
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
    -- print("Penize: Hráč " .. source .. " má " .. tostring(test.count) .. " ks předmětu " .. item)

    if test.count >= 1 then
        xPlayer.removeInventoryItem(Config.addItemStock, 1)
        xPlayer.addMoney(pay)
        -- print("Hráč " .. source .. " dostal " .. pay .. " peněz")
        return true -- Úspěch, klient může pokračovat
    else
        -- Posíláme notifikaci klientovi
        TriggerClientEvent('ox_lib:notify', source, {
            id = 'no_item_error',
            title = 'Nemáš balík!',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        -- print("Hráč " .. source .. " nemá balík nebo není ve službě")
        return false -- Neúspěch, klient nepokračuje
    end
end)