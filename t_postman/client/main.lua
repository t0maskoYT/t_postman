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

    local playerCoords = GetEntityCoords(playerPed)

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