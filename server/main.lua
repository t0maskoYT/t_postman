RegisterServerEvent("t_postman:giveBox")
AddEventHandler('t_postman:giveBox', function ()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    print("Check")
    xPlayer.addInventoryItem(Config.addItemStock, 1)
    print("Check2")
end)