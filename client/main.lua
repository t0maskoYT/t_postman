local spawnedNPCs = {}
local duty = false
local rentCar = false
local loadedCargo = 0
local targetedNPCs = {} -- Tabulka pro sledování, která NPC už mají target

-- Kontrola vzdálenosti a synchronizace NPC
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, npcData in ipairs(Config.npcs) do
            local distance = #(vector3(npcData.coords.x, npcData.coords.y, npcData.coords.z) - playerCoords)
            local inRange = distance <= 35.0

            TriggerServerEvent('t_postman:checkNPCDistance', npcData.identifier, npcData.model, npcData.coords.x, npcData.coords.y, npcData.coords.z, npcData.heading, npcData.name, inRange)

            if inRange and spawnedNPCs[npcData.identifier] and DoesEntityExist(spawnedNPCs[npcData.identifier]) then
                local npc = spawnedNPCs[npcData.identifier]
                if not targetedNPCs[npcData.identifier] then
                    exports.ox_target:addLocalEntity(npc, {
                        {
                            name = npcData.identifier,
                            event = npcData.identifier,
                            icon = "fa-solid fa-cube",
                            label = npcData.name or "Zákazník",
                            onSelect = function()
                                lib.registerContext({
                                    id = npcData.identifier,
                                    title = 'Pošťák - ' .. (npcData.name or "Zákazník"),
                                    options = npcData.options or {
                                        { title = 'Dát zásilku', icon = 'box', event = 'giveD' }
                                    }
                                })
                                lib.showContext(npcData.identifier)
                            end
                        }
                    })
                    targetedNPCs[npcData.identifier] = true
                    --print("Target přidán pro NPC: " .. npcData.identifier .. " (entity: " .. tostring(npc) .. ")")
                end
            elseif inRange and not spawnedNPCs[npcData.identifier] then
                --print("CHYBA: NPC " .. npcData.identifier .. " není synchronizováno, i když je v dosahu")
            end
        end

        Citizen.Wait(1000)
    end
end)

-- Synchronizace NPC od serveru
RegisterNetEvent('t_postman:syncNPC')
AddEventHandler('t_postman:syncNPC', function(identifier, npcNetId)
    if npcNetId then
        local npc = NetworkGetEntityFromNetworkId(npcNetId)
        if DoesEntityExist(npc) then
            spawnedNPCs[identifier] = npc
            --print("NPC " .. identifier .. " synchronizováno na klientovi (netId: " .. npcNetId .. ")")
            -- Ověření, zda je target potřeba přidat (pro jistotu)
            if not targetedNPCs[identifier] then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local npcCoords = GetEntityCoords(npc)
                local distance = #(playerCoords - npcCoords)
                if distance <= 35.0 then
                    exports.ox_target:addLocalEntity(npc, {
                        {
                            name = identifier,
                            event = identifier,
                            icon = "fa-solid fa-cube",
                            label = "Zákazník",
                            onSelect = function()
                                lib.registerContext({
                                    id = identifier,
                                    title = 'Pošťák - Zákazník',
                                    options = {{ title = 'Dát zásilku', icon = 'box', event = 'giveD' }}
                                })
                                lib.showContext(identifier)
                            end
                        }
                    })
                    targetedNPCs[identifier] = true
                    --print("Target přidán při synchronizaci pro NPC: " .. identifier)
                end
            end
        else
            --print("CHYBA: NPC " .. identifier .. " nenalezeno po synchronizaci (netId: " .. npcNetId .. ")")
            Citizen.Wait(500)
            npc = NetworkGetEntityFromNetworkId(npcNetId)
            if DoesEntityExist(npc) then
                spawnedNPCs[identifier] = npc
                --print("NPC " .. identifier .. " synchronizováno po čekání")
            end
        end
    else
        if spawnedNPCs[identifier] and DoesEntityExist(spawnedNPCs[identifier]) then
            exports.ox_target:removeLocalEntity(spawnedNPCs[identifier])
            targetedNPCs[identifier] = nil
            --print("Target odstraněn pro NPC: " .. identifier)
        end
        spawnedNPCs[identifier] = nil
        --print("NPC " .. identifier .. " odstraněno z klienta")
    end
end)

-- Nastavení vlastností NPC na klientovi
RegisterNetEvent('t_postman:setNPCProperties')
AddEventHandler('t_postman:setNPCProperties', function(netId)
    local npc = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(npc) then
        SetEntityInvincible(npc, true)
        SetEntityAsMissionEntity(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
        --print("Vlastnosti nastaveny pro NPC s netId: " .. netId)
    else
        --print("CHYBA: NPC s netId " .. netId .. " nenalezeno, čekám...")
        Citizen.Wait(500)
        npc = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(npc) then
            SetEntityInvincible(npc, true)
            SetEntityAsMissionEntity(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, true)
            --print("Vlastnosti nastaveny po čekání pro NPC s netId: " .. netId)
        else
            --print("CHYBA: NPC s netId " .. netId .. " stále nenalezeno")
        end
    end
end)

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
    lib.callback('t_postman:rentCar', false, function(success)
        if success then
            duty = true
            local ModelHash = Config.car
            if not IsModelInCdimage(ModelHash) then return end
            RequestModel(ModelHash)
            while not HasModelLoaded(ModelHash) do
                Wait(0)
            end
            local Vehicle = CreateVehicle(ModelHash, Config.carSpawnCords.x, Config.carSpawnCords.y, Config.carSpawnCords.z, Config.carSpawnCrodsh, true, false)
            SetModelAsNoLongerNeeded(ModelHash)
            Stock()
        else
            duty = false
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
    if duty == true then
        if loadedCargo <= 0 then
            local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'normal'}, {'w', 'a', 's', 'd'})
            if success then
                lib.notify({
                    title = 'Začal si nákládat balíky',
                    type = 'success'
                })
                loadedCargo = loadedCargo + 1
                if lib.progressCircle({ duration = 5000, position = 'bottom', canCancel = true }) then
                    lib.notify({
                        title = 'Náklad byl naložen',
                        description = 'Jdi na GPS! GPS byla nastavena',
                        type = 'success'
                    })
                    TriggerServerEvent('t_postman:giveBox')
                    local customerNPCs = {"npc1", "npc2", "npc3", "npc4", "npc5", "npc6", "npc7", "npc8", "npc9", "npc10", "npc11", "npc12", "npc13", "npc14"}
                    local randomIndex = math.random(1, 14)
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
        else
            lib.notify({
                title = 'Nepovedlo se ti naložit náklad!',
                description = 'Nemůžeš mít více jak 1 balík najednou!',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Služba',
            description = 'Ještě nejsi ve službě!',
            type = 'error'
        })
    end
end

function dGive()
    if duty == true then
        lib.callback('t_postman:done', false, function(success)
            if success then
                if duty == true then
                    SetNPCWaypoint("stocko")
                    lib.notify({
                        title = 'Jeď do skladu!',
                        description = 'Můžeš jet pro další zásilku! GPS byla nastavena.',
                        type = 'success'
                    })
                end
                loadedCargo = loadedCargo - 1
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

for _, npcIdentifier in ipairs({"npc1", "npc2", "npc3", "npc4", "npc5", "npc6", "npc7", "npc8", "npc9", "npc10", "npc11", "npc12", "npc13", "npc14"}) do
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
    rentCar = true
end)

AddEventHandler('cargoLoad', function()
    loadCargo()
end)

AddEventHandler('giveD', function()
    dGive()
end)

AddEventHandler('logout', function()
    if duty == false then
        lib.notify({
            title = 'Služba',
            description = 'Ještě nejsi ve službě!',
            type = 'error'
        })
    else
        duty = false
        if rentCar == true then
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

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for identifier, npc in pairs(spawnedNPCs) do
            if DoesEntityExist(npc) then
                exports.ox_target:removeLocalEntity(npc)
            end
        end
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
                return true
            end
        end
    end
    return false
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
    local modelHash = GetHashKey(modelName)
    return CheckVehicleInRadius(modelHash, 15.0)
end)

function ReturnCar()
    lib.callback('t_postman:backCar', false, function(success)
        if success then
            local modelHash = GetHashKey(Config.car)
            DeleteVehicleInRadius(modelHash, 15.0)
        end
    end)
end