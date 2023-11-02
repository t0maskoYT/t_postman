local npcc1 = false
local npcc2 = false
local npcc3 = false




------------------------
----------BLIP----------
------------------------

Citizen.CreateThread(function ()
    if Config.blip == true then
        blipp = CreateBlip(Config.blipc.x, Config.blipc.y, Config.blipc.z, Config.blipSprite, 11, Config.blipName)
    end
end)

Citizen.CreateThread(function ()
    SpawnNPC()
end)

------------------------
-------SPAWN-NPC--------
------------------------

function SpawnNPC()
    local peds = {
        { type=4, model=Config.npc}
    }

    for k, v in pairs(peds) do
        local hash = GetHashKey(v.model)
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        --- SPAWN NPC---
        startNPC = CreatePed(v.type, hash, Config.blipc.x, Config.blipc.y, Config.blipc.z -1, Config.bliph, true, true)

        SetEntityInvincible(startNPC, true)
        SetEntityAsMissionEntity(startNPC, true)
        SetBlockingOfNonTemporaryEvents(startNPC, true)
        FreezeEntityPosition(startNPC, true)
    end
end

function SpawnNPC()
    local peds = {
        { type=4, model=Config.stockNPC}
    }

    for k, v in pairs(peds) do
        local hash = GetHashKey(v.model)
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        --- SPAWN NPC---
        startNPC = CreatePed(v.type, hash, Config.stock.x, Config.stock.y, Config.stock.z -1, Config.stockHeading, true, true)

        SetEntityInvincible(startNPC, true)
        SetEntityAsMissionEntity(startNPC, true)
        SetBlockingOfNonTemporaryEvents(startNPC, true)
        FreezeEntityPosition(startNPC, true)
    end
end

------------------------
-------ORDER-NPC--------
------------------------

function Npc1()
    local peds = {
        { type=4, model=Config.npc}
    }

    for k, v in pairs(peds) do
        local hash = GetHashKey(v.model)
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        --- SPAWN NPC---
        Npc1 = CreatePed(v.type, hash, Config.order1.x, Config.order1.y, Config.order1.z -1, Config.order1h, true, true)
        npcc1 = true


        SetEntityInvincible(Npc1, true)
        SetEntityAsMissionEntity(Npc1, true)
        SetBlockingOfNonTemporaryEvents(Npc1, true)
        FreezeEntityPosition(Npc1, true)
    end
end

function Npc2()
    local peds = {
        { type=4, model=Config.npc}
    }

    for k, v in pairs(peds) do
        local hash = GetHashKey(v.model)
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        --- SPAWN NPC---
        Npc2 = CreatePed(v.type, hash, Config.order2.x, Config.order2.y, Config.order2.z -1, Config.order2h, true, true)
        npcc2 = true

        SetEntityInvincible(Npc2, true)
        SetEntityAsMissionEntity(Npc2, true)
        SetBlockingOfNonTemporaryEvents(Npc2, true)
        FreezeEntityPosition(Npc2, true)
    end
end

function Npc3()
    local peds = {
        { type=4, model=Config.npc}
    }

    for k, v in pairs(peds) do
        local hash = GetHashKey(v.model)
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(1)
        end

        --- SPAWN NPC---
        Npc3 = CreatePed(v.type, hash, Config.order3.x, Config.order3.y, Config.order3.z -1, Config.order3h, true, true)
        npcc3 = true

        SetEntityInvincible(Npc3, true)
        SetEntityAsMissionEntity(Npc3, true)
        SetBlockingOfNonTemporaryEvents(Npc3, true)
        FreezeEntityPosition(Npc3, true)
    end
end


------------------------
-------BLIP CREATE------
------------------------

function CreateBlip(x, y, z, sprite, color, name)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    SetBlipDisplay(blip, 6)
    return blip
end

------------------------
        --------
------------------------

function CarSpawn()
    local ModelHash = Config.car -- Use Compile-time hashes to get the hash of this model
    if not IsModelInCdimage(ModelHash) then return end
    RequestModel(ModelHash) -- Request the model
    while not HasModelLoaded(ModelHash) do -- Waits for the model to load
      Wait(0)
    end
    local MyPed = PlayerPedId()
    local Vehicle = CreateVehicle(ModelHash, Config.carSpawnCords.x, Config.carSpawnCords.y, Config.carSpawnCords.z, Config.carSpawnCrodsh, true, false) -- Spawns a networked vehicle on your current coords
    SetModelAsNoLongerNeeded(ModelHash)
end

function Stock()
    SetNewWaypoint(Config.stock.x, Config.stock.y)
    lib.notify({
        title = 'Go to stock!',
        description = 'GPS has been set.',
        type = 'success'
    })
end

function loadCargo()
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
    lib.notify({
        title = 'You started loading cargo ',
        type = 'success'
    })
    if lib.progressCircle({
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
    }) then     
        lib.notify({
        title = 'Cargo has been loaded',
        type = 'success'
    })
    else     
        lib.notify({
            id = 'some_identifier',
            title = 'Cargo loading was stopped',
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
    end
    print("Check")
    TriggerServerEvent('t_postman:giveBox')
    print("Check1")
    gps = math.random(Config.random)
    print(gps)
    if gps == 1 then
        SetNewWaypoint(Config.order1.x, Config.order1.y)
        Npc1()
    end
    if gps == 2 then
        SetNewWaypoint(Config.order2.x, Config.order2.y)
        Npc2()
    end
    if gps == 3 then
        SetNewWaypoint(Config.order3.x, Config.order3.y)
        Npc3()
    end
    
    
    
end


AddEventHandler('spawnCar', function()
    CarSpawn()
    Stock()
end)

AddEventHandler('ownCar', function()
    Stock()
end)

AddEventHandler('cargoLoad', function ()
    loadCargo()
end)

RegisterNetEvent('postman_start_menu', function (arg)
    lib.registerContext({
        id = 'postman_start_menu',
        title = 'POSTMAN',
        options = {
            {
                title = 'CHOICE CAR'
            },
            {
                title = 'MY OWN CAR',
                description = ' I have got my own car!',
                icon = 'car',
                event = 'ownCar',
            },
            {
                title = 'RENT A CAR',
                description = 'Please can You rent me a car?',
                icon = 'car',
                event = 'spawnCar',
            },
        
        }
    })
    lib.showContext('postman_start_menu')
end)

RegisterNetEvent('stocko', function (arg)
    lib.registerContext({
        id = 'stocko',
        title = 'POSTMAN',
        options = {
            {
                title = 'STOCK'
            },
            {
                title = 'Load cargo',
                icon = 'box',
                event = 'cargoLoad',
            },
        
        }
    })
    lib.showContext('stocko')
end)




exports.ox_target:addBoxZone({
    coords = vector3(-28.1362, -99.4197, 57.3443),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'postman_start_menu',
            event = 'postman_start_menu',
            icon = 'fa-solid fa-cube',
            label = 'Be a postman',
        }
    }
})

exports.ox_target:addBoxZone({
    coords = vector3(142.6951, -3111.6631, 5.8963),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'stocko',
            event = 'stocko',
            icon = 'fa-solid fa-cube',
            label = 'Talk with storekeeper',
        }
    }
})