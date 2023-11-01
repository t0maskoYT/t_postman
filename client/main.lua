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


AddEventHandler('spawnCar', function()
    CarSpawn()
    Stock()
end)

AddEventHandler('ownCar', function()
    Stock()
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