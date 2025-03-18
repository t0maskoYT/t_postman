local spawnedNPCs = {}
local duty = false
local rentCar = false

------------------------
-------SPAWN-NPC--------
------------------------

function SpawnNPC(identifier, model, x, y, z, heading, name)
    -- Funkce pro spawn jednoho NPC
    local function createNPC()
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(10)
        end

        local npc = CreatePed(4, hash, x, y, z - 1, heading, true, true)
        if not npc then
            print("CHYBA: Nepodařilo se vytvořit NPC s identifikátorem " .. identifier)
            return
        end

        SetEntityInvincible(npc, true)
        SetEntityAsMissionEntity(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)

        spawnedNPCs[identifier] = npc

        exports.ox_target:addLocalEntity(npc, {
            {
                name = identifier,
                event = identifier,
                icon = "fa-solid fa-cube",
                label = name or "Zákazník"
            }
        })

        -- print("NPC s identifikátorem " .. identifier .. " spawnuto na " .. x .. ", " .. y .. ", " .. z)
    end

    -- Funkce pro despawn NPC
    local function despawnNPC()
        if spawnedNPCs[identifier] and DoesEntityExist(spawnedNPCs[identifier]) then
            exports.ox_target:removeLocalEntity(spawnedNPCs[identifier])
            DeleteEntity(spawnedNPCs[identifier])
            spawnedNPCs[identifier] = nil
            -- print("NPC s identifikátorem " .. identifier .. " bylo odstraněno.")
        end
    end

    -- Vlákno pro kontrolu vzdálenosti
    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector3(x, y, z) - playerCoords)

            if distance <= 20.0 then
                if not spawnedNPCs[identifier] or not DoesEntityExist(spawnedNPCs[identifier]) then
                    createNPC()
                end
            else
                despawnNPC()
            end

            Citizen.Wait(1000)
        end
    end)
end

------------------------
-------ORDER-NPC--------
------------------------

function SpawnCustomer(identifier, coords, heading)
    SpawnNPC(identifier, Config.npc or "a_m_y_busicas_01", coords.x, coords.y, coords.z, heading, "Zákazník")
end

-- Spuštění spawnování pro všechny NPC z Configu
Citizen.CreateThread(function()
    for _, npcData in ipairs(Config.npcs) do
        SpawnNPC(npcData.identifier, npcData.model, npcData.coords.x, npcData.coords.y, npcData.coords.z, npcData.heading, npcData.name)
    end
end)

------------------------
-------BLIP CREATE------
------------------------

Citizen.CreateThread(function()
    if Config.blip then
        local blipp = CreateBlip(Config.blipc.x, Config.blipc.y, Config.blipc.z, Config.blipSprite, 11, Config.blipName)
        -- print("Klient: Blip vytvořen na " .. Config.blipc.x .. ", " .. Config.blipc.y .. ", " .. Config.blipc.z)
    end
end)

function CreateBlip(x, y, z, sprite, color, name)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, Config.blipScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    SetBlipDisplay(blip, 6)
    return blip
end

------------------------
-------FUNKCE-----------
------------------------

function SetNPCWaypoint(npcIdentifier)
    for _, npcData in pairs(Config.npcs) do
        if npcData.identifier == npcIdentifier then
            SetNewWaypoint(npcData.coords.x, npcData.coords.y)
            lib.notify({
                title = 'Waypoint nastaven!',
                description = 'Cíl: ' .. npcData.name,
                type = 'success'
            })
            return
        end
    end
    lib.notify({
        title = 'Chyba',
        description = 'NPC s tímto identifikátorem nebylo nalezeno!',
        type = 'error'
    })
end


function CarSpawn()
    -- print("Spouštím CarSpawn, volám server...")
    lib.callback('t_postman:rentCar', false, function(success)
        -- print("Odpověď od serveru: success = " .. tostring(success))
        if success then
            print("Server řekl ano, spawnuju auto...")
            local ModelHash = Config.car
            if not IsModelInCdimage(ModelHash) then 
                -- print("Model " .. ModelHash .. " není v CD image, končím.")
                return 
            end
            RequestModel(ModelHash)
            while not HasModelLoaded(ModelHash) do
                Wait(0)
            end
            local Vehicle = CreateVehicle(ModelHash, Config.carSpawnCords.x, Config.carSpawnCords.y, Config.carSpawnCords.z, Config.carSpawnCrodsh, true, false)
            -- if Vehicle then
            --     print("Auto spawnuto na " .. Config.carSpawnCords.x .. ", " .. Config.carSpawnCords.y .. ", " .. Config.carSpawnCords.z)
            -- else
            --     print("CHYBA: Auto se nepodařilo spawnout!")
            -- end
            SetModelAsNoLongerNeeded(ModelHash)
            Stock() -- Stock() je uvnitř if success, spustí se jen při úspěchu
        else
            print("Server řekl ne, auto se nespawne.")
            -- Tady Stock() není, takže se nespustí
        end
    end)
end

function Stock()
    duty = true
    SetNPCWaypoint("stocko")
    lib.notify({
        title = 'Jeď do skladu!',
        description = 'GPS byla nastavena!',
        type = 'success'
    })
end

function loadCargo()
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'normal'}, {'w', 'a', 's', 'd'})
    if success then
        lib.notify({
            title = 'Začal si nákládat balíky',
            type = 'success'
        })
        if lib.progressCircle({ duration = 5000, position = 'bottom', canCancel = true }) then
            lib.notify({
                title = 'Náklad byl naložen',
                description = 'Jdi na GPS! GPS byla nastavena',
                type = 'success'
            })
            TriggerServerEvent('t_postman:giveBox')

            local customerNPCs = {"npc1", "npc2", "npc3"}
            local randomIndex = math.random(1, 3)
            local selectedNPC = customerNPCs[randomIndex]
            
            SetNPCWaypoint(selectedNPC)
        else
            lib.notify({
                title = 'Nakládání bylo zrušeno',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Nepovedlo se ti naložit náklad!',
            type = 'error'
        })
    end
end

function dGive()
    -- print("Spouštím dGive, volám server...")
    if duty == true then
        lib.callback('t_postman:done', false, function(success)
            -- print("Odpověď od serveru: success = " .. tostring(success))
            if success then
                if duty == true then -- Zachováme podmínku duty
                    SetNPCWaypoint("stocko")
                    lib.notify({
                        title = 'Jeď do skladu!',
                        description = 'Můžeš jet pro další zásilku! GPS byla nastavena.',
                        type = 'success'
                    })
                end
            else
                -- print("Server řekl ne, žádný waypoint ani notifikace.")
                -- Tady se nic neděje, notifikaci posílá server
            end
        end)
    else
        lib.notify({
            title = 'Mimo službu',
            description = 'Jsi mimo službu!',
            type = 'error'
        })
    end
end

-- Příjem notifikace od serveru
RegisterNetEvent('ox_lib:notify')
AddEventHandler('ox_lib:notify', function(data)
    lib.notify(data)
end)

------------------------
------ EVENTY ----------
------------------------

RegisterNetEvent('postman_start_menu')
AddEventHandler('postman_start_menu', function()
    lib.registerContext({
        id = 'postman_start_menu',
        title = 'Pošťák',
        options = {
            { title = 'Vlastní vozidlo', description = 'Použiju vlastní vozidlo!', icon = 'car', event = 'ownCar' },
            { title = 'Půjčit vozidlo', description = 'Půjčím si vozidlo!', icon = 'car', event = 'spawnCar' },
            { title = 'Jít ze služby', description = 'Odlásit se ze služby', icon = 'xmark', event = 'logout' }
        }
    })
    lib.showContext('postman_start_menu')
end)

RegisterNetEvent('stocko')
AddEventHandler('stocko', function()
    lib.registerContext({
        id = 'stocko',
        title = 'Skladník',
        options = { { title = 'Naložit zásilku', icon = 'box', event = 'cargoLoad' } }
    })
    lib.showContext('stocko')
end)

for _, npcIdentifier in ipairs({"npc1", "npc2", "npc3"}) do
    RegisterNetEvent(npcIdentifier)
    AddEventHandler(npcIdentifier, function()
        lib.registerContext({
            id = npcIdentifier,
            title = 'Pošťák',
            options = { 
                { title = 'Dát zásilku', icon = 'box', event = 'giveD' } 
            }
        })
        lib.showContext(npcIdentifier)
    end)
end

AddEventHandler('spawnCar', function()
    CarSpawn()
    duty = true
    rentCar = true
end)

AddEventHandler('ownCar', function()
    Stock()
    duty = true
end)

AddEventHandler('cargoLoad', function()
    loadCargo()
end)

AddEventHandler('giveD', function()
    dGive()
end)

AddEventHandler('logout', function()
    if duty == false  then
        lib.notify({
            title = 'Služba',
            description = 'Ještě nejsi ve službě!',
            type = 'error'
        })
    else
        duty = false
        if rentCar == true then
                -- print("Odpověď od serveru: success = " .. tostring(success))
                lib.notify({
                    title = 'Mimo službu',
                    description = 'Právě jsi mimo službu a byla ti vrácena záloha za vozidlo!',
                    type = 'success'
                })
            ReturnCar()
        else
            lib.notify({
                title = 'Mimo službu',
                description = 'Právě jsi mimo službu!',
                type = 'success'
            }) 
        end
    end
end)

------------------------
------ ČIŠTĚNÍ --------
------------------------

-- Čištění všech NPC při restartu scriptu
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- print("Script " .. resourceName .. " se zastavuje, mažu všechny NPC.")
        for identifier, npc in pairs(spawnedNPCs) do
            if DoesEntityExist(npc) then
                exports.ox_target:removeLocalEntity(npc)
                DeleteEntity(npc)
                -- print("Smazáno NPC s identifikátorem " .. identifier)
            end
        end
        spawnedNPCs = {} -- Vyprázdníme tabulku
    end
end)

function DeleteVehicleInRadius(modelHash, radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        if distance <= radius and GetEntityModel(vehicle) == modelHash then
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
                print("Smazáno vozidlo " .. modelHash .. " v radiusu " .. radius .. " jednotek")
                return true -- Něco jsme smazali
            end
        end
    end
    return false -- Nic jsme nenašli
end

function CheckVehicleInRadius(modelHash, radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local vehicles = GetGamePool('CVehicle')
    
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        local vehicleModel = GetEntityModel(vehicle)
        
        if distance <= radius and vehicleModel == modelHash then
            if DoesEntityExist(vehicle) then
                return true
            end
        end
    end
    return false
end

lib.callback.register('t_postman:checkVehicle', function(modelName)
    local modelHash = GetHashKey(modelName) -- Předpokládáme, že modelName je string (např. "burrito3")
    return CheckVehicleInRadius(modelHash, 40.0)
end)

function DeleteVehicleInRadius(modelHash, radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        if distance <= radius and GetEntityModel(vehicle) == modelHash then
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
                return true
            end
        end
    end
    return false
end

function ReturnCar()
    lib.callback('t_postman:backCar', false, function(success)
        if success then
            local modelHash = GetHashKey(Config.car)
            DeleteVehicleInRadius(modelHash, 40.0)
        else
            print("Server řekl ne, auto se nemaže.")
        end
    end)
end
