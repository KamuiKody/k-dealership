local QBCore = exports['qb-core']:GetCoreObject()
local closestdealer = nil
local owner = false

CreateThread(function()
    while true do
    for k,v in pairs(Config.Dealerships) do
        local name = v.name
            QBCore.Functions.TriggerCallback('k-dealership:getowned', function(cb)
                if cb then
                    TriggerEvent('k-dealership:changeshopstate', name)
                    Config.Dealerships[name]["purchased"] = true
                else
                    Config.Dealerships[k].purchased = false
                --    local purchased = Config.Dealerships['Luxary']["purchased"]
                end
            end, name)
        end
    QBCore.Functions.TriggerCallback('k-dealership:dealerConfig', function(DealerConfig)
        Config.Dealerships = DealerConfig
    end)
    Wait(5000)
    end
end)

 RegisterNetEvent('k-dealership:deletevics', function(coords, hash)
     if Config.mojia then
         TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)
     end
     local x, y, z = table.unpack(coords)
     DeleteVehicle(GetClosestVehicle(x, y, z, 1.0, 0, 70))
end)

CreateThread(function()
    QBCore.Functions.TriggerCallback('k-dealership:getloaded', function(cb)
        if cb then
            Wait(math.random(1000,2000))
            for k,v in pairs(Config.Dealerships) do
                if v.purchased then
                    QBCore.Functions.TriggerCallback('k-dealership:getcars', function(cb)
                        for k,v in pairs(cb) do
                            Wait(math.random(100,2000))
                            local coords = vector3(tonumber(v.x),tonumber(v.y),tonumber(v.z))
                            TriggerServerEvent('k-dealership:delveh', coords, v.hash)
                            Wait(2500)
                            RequestModel(v.hash)
                            QBCore.Functions.TriggerCallback('k-dealership:spawnlotcars', function(veh)   
                                SetVehicleOnGroundProperly(veh)
                                local netid = NetworkGetNetworkIdFromEntity(veh)
                                SetNetworkIdCanMigrate(netid, true)
                                local plate = v.vehicleplate
                                if not Config.mojia then
                                    QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                                        QBCore.Functions.SetVehicleProperties(veh, properties)
                                    end, plate)
                                end
                                if tonumber(v.bodydamage) > 950 then
                                    body = 1000.0
                                else
                                    body = v.bodydamage
                                end
                                if tonumber(v.enginedamage) > 950 then
                                    engine = 1000.0
                                else
                                    engine = v.enginedamage
                                end
                                exports[Config.Fuel]:SetFuel(veh, v.fuel)
                                SetVehicleBodyHealth(veh, body)
                                SetVehicleEngineHealth(veh, engine) 
                                FreezeEntityPosition(veh, true)
                                SetVehicleEngineOn(veh, false, false)
                                TriggerServerEvent('k-dealership:server:pzcreator', coords, v.w, v.vehicleplate, v.dealername, netid)
                            end, v.hash, coords, tonumber(v.w), v.vehicleplate)
                        end
                    end, k, 3)
                end
            end
        else
            for k,v in pairs(Config.Dealerships) do
                if v.purchased then
                    QBCore.Functions.TriggerCallback('k-dealership:getcars', function(cb)
                        for k,v in pairs(cb) do
                            local coords = vector3(tonumber(v.x),tonumber(v.y),tonumber(v.z))
                            local x, y, z = table.unpack(coords)
                            TriggerServerEvent('k-dealership:server:pzcreator', coords, v.w, v.vehicleplate, v.dealername, GetClosestVehicle(x, y, z, 1.0, 0, 70))
                        end
                    end, k, 3)
                end
            end
        end   
    end)
end)

RegisterNetEvent('k-dealership:client:changeshopstate', function(name)
    TriggerEvent('k-dealership:changeshopstate', name)
end)

local function loadModel(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

function DrawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if not Config.Target then
            for k,v in pairs(Config.Dealerships) do
                local dist = #(pos - v.buylocation)
                if dist < 5 and not v.purchased then
                    local msg = "[E] Purchase ".. k .." for [$".. v.price .."]"
                    DrawText3D(v.buylocation, msg)
                    if dist < 5 then
                        if IsControlJustPressed(0, 38) then
                            QBCore.Functions.TriggerCallback('k-dealership:makepurchase', function(cb)
                                if cb then
                                    TriggerServerEvent('k-dealership:purchaseshop', k)
                                    QBCore.Functions.Notify('You purchased the shop.', 'success', 5000)
                                else
                                    QBCore.Functions.Notify('You don\'t have enough for this shop.', 'error', 5000)
                                end
                            end, v.price)
                        end
                    end
                end
            end            
        end
        if closestdealer ~= nil and IsPedInAnyVehicle(ped, false) then
            local curVeh = GetVehiclePedIsIn(ped)
            local coords = Config.Dealerships[closestdealer].center
            local carcoords = GetEntityCoords(curVeh)
            local heading = GetEntityHeading(curVeh)
            local plate = QBCore.Functions.GetPlate(curVeh)
            local dist = #(pos - coords)
            if dist < 60 then
                local x, y, z = table.unpack(carcoords)
                local vec = vector3(x,y,z + 0.7)
                DrawText3D(vec, tostring("[G] Park Vehicle on Lot"))
                if IsControlJustPressed(0, 47) then
                    -- TaskLeaveVehicle(ped, curVeh, 0)
                    FreezeEntityPosition(curVeh, true)
                    TriggerServerEvent('k-dealership:updatecarloc', curVeh, plate, x, y, z, heading)
                   -- print("i did it")
                    TriggerServerEvent('k-dealership:server:pzcreator', carcoords, heading, plate, closestdealer, curVeh)
                    TaskLeaveVehicle(ped, curVeh, 0)
                    if Config.mojia then
                        TriggerServerEvent('MojiaGarages:server:updateVehicleState', 3, plate, closestdealer)
                    else
                        TriggerServerEvent('qb-garage:server:updateVehicle', 3, 100.0, 1000.0, 1000.0, plate, closestdealer, "public")
                    end
                    closestdealer = nil
                end
            end
        end
    end
end)

CreateThread(function()
    if not Config.Target then
        while true do
            Wait(0)
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            for k,v in pairs(Config.Dealerships) do
                local menu = #(pos - v.menu)
                if v.purchased then
                    if menu < 1.5 then
                        DrawText3D(v.menu, tostring("[E] Management"))
                        if IsControlJustPressed(0, 38) then
                            QBCore.Functions.TriggerCallback('k-dealership:getowner', function(cb)
                                if cb then
                                    QBCore.Functions.TriggerCallback('k-dealership:dealershipinfo', function(info)
                                        if info ~= nil then
                                            TriggerEvent('k-dealership:managementmenu', info)
                                        end
                                    end, k)
                                end
                            end, k)
                        end
                    end                 
                end
            end
        end
    end
end)

CreateThread(function()
    if Config.Target then
        for k,v in pairs(Config.Dealerships) do
            Wait(0)
            if v.purchased then
                exports['qb-target']:AddBoxZone(k, v.menu, 2.0, 2.0, { 
                    name=k,
                    heading = 0,
                    debugPoly=false,
                        }, { 
                        options = {
                            { 
                            event = "k-dealership:management", 
                            icon = "fas fa-car", 
                            label = "Management Menu",
                            }, 
                        },
                          distance = 3.0
                    })
                    exports['qb-target']:AddBoxZone(k, v.storage, 2.0, 2.0, { 
                        name=k,
                        heading = 0,
                        debugPoly=false,
                            }, { 
                            options = {
                                { 
                                event = "k-dealership:storeit", 
                                icon = "fas fa-car", 
                                label = "Store Vehicle",
                                }, 
                            },
                              distance = 3.0
                        })
                else
                    exports['qb-target']:AddBoxZone(k, v.buylocation, 2.0, 2.0, { 
                        name=k,
                        heading = 0,
                        debugPoly=false,
                            }, { 
                            options = {
                                { 
                                event = "k-dealership:buyshop", 
                                icon = "fas fa-car", 
                                label = "Buy Dealership: $"..v.price,
                                menu = v.menu,
                                storage = v.storage,
                                price = v.price,
                                name = k
                                }, 
                            },
                              distance = 3.0
                        })
            end
        end
    end

end)

RegisterNetEvent("k-dealership:storeit", function()
    for k,v in pairs(Config.Dealerships) do
        if #(GetEntityCoords(PlayerPedId()) - v.center) < 60 then
    QBCore.Functions.TriggerCallback('k-dealership:getowner', function(cb)
        if cb then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local curVeh = GetVehiclePedIsIn(ped)
            local plate = QBCore.Functions.GetPlate(curVeh)
            if Config.mojia then
                QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
                    if owned then
                            local bodyDamage = math.floor(GetVehicleBodyHealth(curVeh)* 1)
                            local engineDamage = math.floor(GetVehicleEngineHealth(curVeh)* 1)
                            local totalFuel = exports[Config.Fuel]:GetFuel(curVeh)
                            local vehProperties = QBCore.Functions.GetVehicleProperties(curVeh)
                            local plate = QBCore.Functions.GetPlate(curVeh) 
                            QBCore.Functions.TriggerCallback('k-dealership:getname', function(name)
                                    TriggerServerEvent('k-dealership:storevehicle', plate, name, {vehProperties}, bodyDamage, engineDamage, totalFuel, closestdealer)
                                    QBCore.Functions.DeleteVehicle(curVeh)
                                    TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate) 
                                    TriggerServerEvent('MojiaGarages:server:updateVehicleState', 3, plate, closestdealer)
                                    QBCore.Functions.Notify('You stored the vehicle.', 'success', 5000)
                                    closestdealer = nil
                            end, plate)
                    else
                        QBCore.Functions.Notify('You don\'t own this vehicle.', 'error', 5000)
                    end
                end, plate)
            else
                QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned, owed)
                    if owned then
                        local bodyDamage = math.floor(GetVehicleBodyHealth(curVeh)* 1)
                        local engineDamage = math.floor(GetVehicleEngineHealth(curVeh)* 1)
                        local totalFuel = exports[Config.Fuel]:GetFuel(curVeh)
                        local vehProperties = QBCore.Functions.GetVehicleProperties(curVeh)
                        local plate = QBCore.Functions.GetPlate(curVeh)
                        QBCore.Functions.TriggerCallback('k-dealership:getname', function(name)
                                TriggerServerEvent('k-dealership:storevehicle', plate, name, {vehProperties}, bodyDamage, engineDamage, totalFuel, k)
                                TriggerServerEvent('qb-garage:server:updateVehicle', 3, totalFuel, engineDamage, bodyDamage, plate, k, "public")
                               
                                -- DeleteEntity(curVeh)
                                QBCore.Functions.DeleteVehicle(curVeh)
                                QBCore.Functions.Notify('You stored the vehicle.', 'success', 5000)
                                closestdealer = nil
                        end, plate)
                    else
                        QBCore.Functions.Notify('You don\'t own this vehicle.', 'error', 5000)
                    end
                end, plate)
            end
        end
    end, k)
end
end 
end) 

RegisterNetEvent("k-dealership:buyshop", function(data)
    local price = data.price
    local storage = data.storage
    local menu = data.menu
    local name = data.name
    exports['qb-target']:RemoveZone(name)
    QBCore.Functions.TriggerCallback('k-dealership:makepurchase', function(cb)
        if cb then
            TriggerServerEvent('k-dealership:purchaseshop', k)
            Config.Dealerships[k].purchased = true
            exports['qb-target']:AddBoxZone(k, menu, 2.0, 2.0, { 
                name=k,
                heading = 0,
                debugPoly=false,
                    }, { 
                    options = {
                        { 
                        event = "k-dealership:management", 
                        icon = "fas fa-car", 
                        label = "Management Menu",
                        }, 
                    },
                      distance = 3.0
                })
                exports['qb-target']:AddBoxZone(k, storage, 2.0, 2.0, { 
                    name=k,
                    heading = 0,
                    debugPoly=false,
                        }, { 
                        options = {
                            { 
                            event = "k-dealership:storeit", 
                            icon = "fas fa-car", 
                            label = "Store Vehicle",
                            }, 
                        },
                          distance = 3.0
                    })
            QBCore.Functions.Notify('You purchased the shop.', 'success', 5000)
        else
            QBCore.Functions.Notify('You don\'t have enough for this shop.', 'error', 5000)
        end
    end, price)
end)

RegisterNetEvent("k-dealership:management", function()
    for k,v in pairs(Config.Dealerships) do
        if #(GetEntityCoords(PlayerPedId()) - v.center) < 60 then
    QBCore.Functions.TriggerCallback('k-dealership:getowner', function(cb)
        if cb then
        
            QBCore.Functions.TriggerCallback('k-dealership:dealershipinfo', function(info)
                if info ~= nil then
                    TriggerEvent('k-dealership:managementmenu', info)
                end
            end, k)
        end
    end, k)
end
end
end)

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if not Config.Target then
            for k,v in pairs(Config.Dealerships) do
                local park = #(pos - v.storage)
                if v.purchased then        
                    if park < 5 then
                        if IsPedInAnyVehicle(ped, false) then     
                            DrawText3D(v.storage, tostring("[E] Store Vehicle"))  
                            if IsControlJustPressed(0, 38) then   
                                QBCore.Functions.TriggerCallback('k-dealership:getowner', function(cb)
                                    if cb then
                                        local curVeh = GetVehiclePedIsIn(ped)
                                        local plate = QBCore.Functions.GetPlate(curVeh)
                                        if Config.mojia then
                                            QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
                                                if owned then                                            
                                                    local bodyDamage = math.floor(GetVehicleBodyHealth(curVeh)* 1)
                                                    local engineDamage = math.floor(GetVehicleEngineHealth(curVeh)* 1)
                                                    local totalFuel = exports[Config.Fuel]:GetFuel(curVeh)
                                                    local vehProperties = QBCore.Functions.GetVehicleProperties(curVeh)
                                                    local plate = QBCore.Functions.GetPlate(curVeh)                                                
                                                    QBCore.Functions.TriggerCallback('k-dealership:getname', function(name)
                                                        TriggerServerEvent('k-dealership:storevehicle', plate, name, {vehProperties}, bodyDamage, engineDamage, totalFuel, k)
                                                        QBCore.Functions.DeleteVehicle(curVeh)
                                                        TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, k)
                                                        TriggerServerEvent('MojiaGarages:server:removeOutsideVehicles', plate)                                                                                                             
                                                        QBCore.Functions.Notify('You stored the vehicle.', 'success', 5000)
                                                        closestdealer = nil
                                                    end, plate)
                                                else
                                                    QBCore.Functions.Notify('You don\'t own this vehicle.', 'error', 5000)
                                                end
                                            end, plate)
                                        else
                                            QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned, owed)
                                                if owned then                                            
                                                    local bodyDamage = math.floor(GetVehicleBodyHealth(curVeh)* 1)
                                                    local engineDamage = math.floor(GetVehicleEngineHealth(curVeh)* 1)
                                                    local totalFuel = exports[Config.Fuel]:GetFuel(curVeh)
                                                    local vehProperties = QBCore.Functions.GetVehicleProperties(curVeh)
                                                    local plate = QBCore.Functions.GetPlate(curVeh)                                                
                                                    QBCore.Functions.TriggerCallback('k-dealership:getname', function(name)
                                                        TriggerServerEvent('k-dealership:storevehicle', plate, name, {vehProperties}, bodyDamage, engineDamage, totalFuel, k)
                                                        TriggerServerEvent('qb-garage:server:updateVehicle', 1, totalFuel, engineDamage, bodyDamage, plate, v.name, "public")
                                                        -- DeleteEntity(curVeh)
                                                        QBCore.Functions.DeleteVehicle(curVeh)
                                                        QBCore.Functions.Notify('You stored the vehicle.', 'success', 5000)
                                                        closestdealer = nil
                                                    end, plate)
                                                else
                                                    QBCore.Functions.Notify('You don\'t own this vehicle.', 'error', 5000)
                                                end
                                            end, plate)
                                        end
                                    end
                                end, k)
                            end
                        end
                    end
                    
                end
            end
        end
    end
end)





RegisterNetEvent('k-dealership:managementmenu', function(info)
    local data = table.unpack(info)
    local mgmtoptions = {
        {
            header = "| ".. data.dealername .." |",
            txt = "Shop Funds: $".. data.funds,
            isMenuHeader = true
        },
        {
            header = "Request Car",
            params = {
                event = 'k-dealership:carcat',
                args = {
                    name = data.dealername,
                    funds = data.funds
                    }
                }
            },
        {
            header = "Test Drive",
            params = {
                event = "k-dealership:testdrive",
                args = {
                    name = data.dealername,
                    funds = data.funds
                    }
                }
            },    
        { 
            header = "Put Car Out",
            params = {
                event = "k-dealership:setupsale",
                args = {
                    name = data.dealername,
                    funds = data.funds
                    }
                }
            },
            { 
                header = "Deposit Funds",
                txt = "Bank Transfer",
                params = {
                    event = "k-dealership:funds",
                    args = {
                        type = 'Deposit',
                        name = data.dealername,
                        funds = data.funds
                        }
                    }
            },
            { 
                header = "Withdraw Funds",
                txt = "Bank Transfer",
                params = {
                    event = "k-dealership:funds",
                    args = {
                        type = 'Withdraw',
                        name = data.dealername,
                        funds = data.funds
                   }
                }
            }
        }  
    exports['qb-menu']:openMenu(mgmtoptions)
end)

RegisterNetEvent('k-dealership:carcat', function(data)
    local catoptions = {
        {
            header = "| ".. data.name .." |",
            txt = "Shop Funds: $".. data.funds,
            isMenuHeader = true
        }     
    }   
    for k,v in pairs(Config.Shops['Categories']) do
        catoptions[#catoptions + 1] = {
            header = v,
            params = {
                event = "k-dealership:carchoose",
                args = {
                    cat = v,
                    name = data.name,
                    funds = data.funds
                    }
                }

        }
    end
    exports['qb-menu']:openMenu(catoptions)
end)

RegisterNetEvent('k-dealership:carchoose', function(data)
    QBCore.Functions.TriggerCallback('k-dealership:getbank', function(cb)
        local cat = data.cat
        local act = tonumber(data.funds)
        local caroptions = {
            {
                header = "| ".. data.name .." |",
                txt = "Shop Funds: $".. data.funds,
                isMenuHeader = true
            }     
        }   
        for k,v in pairs(QBCore.Shared.Vehicles) do
            if QBCore.Shared.Vehicles[k]["category"] == cat then
                local cost = math.floor(math.random(math.floor(v.price * 0.6), math.floor(v.price * 0.8)) * 1)
                if cost <= cb then
                caroptions[#caroptions + 1] = {
                    header = v.model,
                    txt = 'Cost: $'.. cost,
                    params = {
                        event = "k-dealership:choosecar",
                        args = {
                            price = cost,
                            hash = v.hash,
                            name = data.name,
                            funds = data.funds,
                            k = k
                            }
                        }

                    }
                end
            end
        end
        exports['qb-menu']:openMenu(caroptions)
    end)
end)

RegisterNetEvent('k-dealership:choosecar', function(data)
    local src = source
    local ped = PlayerPedId()
    local locationset = Config.CarSpawn
    local location = locationset[math.random(1,#locationset)]
    local coords = location.coords    
    local heading = location.heading
    local hash = data.hash
    while not HasModelLoaded(hash) do Wait(0) RequestModel(hash) end
    veh = CreateVehicle(hash,coords,heading,true,true)    
    SetVehicleNumberPlateText(veh, QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2))
    exports[Config.Fuel]:SetFuel(veh, 100)
    SetEntityAsMissionEntity(veh, true, true)
    carsBlip = AddBlipForCoord(coords)
    SetBlipRoute(carsBlip, true)
    while carsBlip ~= nil do
        Wait(0)
        dist = #(GetEntityCoords((PlayerPedId())) - coords)
        if dist < 2 then 
            local price = data.price
            DrawText3D(coords, '[E] Purchase Vehicle for $'.. price ..'!')
            if dist < 2 then
                if IsControlJustReleased(0, 38) then                                             
                    QBCore.Functions.TriggerCallback('k-dealership:makepurchase', function(cb)
                        if cb then    
                            local plate = GetVehicleNumberPlateText(veh)           
                            --TaskWarpPedIntoVehicle(ped, veh, -1)
                            TriggerEvent("vehiclekeys:client:SetOwner", plate)
                            if Config.mojia then                                
                                -- TriggerServerEvent('k-dealership:owncar', veh, plate)
                                TriggerServerEvent('k-dealership:owncar', data.k, plate)
                                -- TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, plate)
                                QBCore.Functions.Notify('You purchased the vehicle.', 'success', 5000)
                            else
                                TriggerServerEvent('k-dealership:owncar', data.k, plate)
                            end
                        else
                            QBCore.Functions.Notify('You don\'t have enough for this vehicle.', 'error', 5000)
                        end
                    end, price)                             
                    RemoveBlip(carsBlip)
                    carsBlip = nil
                end
            end
        end
    end
end)

RegisterNetEvent('k-dealership:testdrive', function(data)
    QBCore.Functions.TriggerCallback('k-dealership:getcars', function(cb)
        if cb ~= nil then
            local cars = {
                {
                    header = "| ".. data.name.." |",
                    txt = "Shop Funds: $".. data.funds,
                    isMenuHeader = true
                }     
            } 
            for k,v in pairs(cb) do
               if tonumber(v.state) == 1 then
                cars[#cars + 1] = {
                    header = v.hash,
                    params = {
                        event = "k-dealership:testcar",
                        args = {
                            dealer = v.dealername,
                            hash = v.hash,
                            props = v.vehicleprops,
                            plate = v.vehicleplate,
                            body = v.bodydamage,
                            engine = v.enginedamge,
                            fuel = v.fuel
                        }
                    }                    
                }
                end
            end
            exports['qb-menu']:openMenu(cars)
        end
    end, data.name, 1)
end)


RegisterNetEvent('k-dealership:testcar', function(data)
    local plate = data.plate
    local dealer = data.dealer
    local body = data.body
    local engine = data.engine
    for k,v in pairs(Config.Dealerships) do
        if k == dealer then
            local spawn = Config.Dealerships[dealer].exteriorspawn
            local hash = GetHashKey(data.hash)
            while not HasModelLoaded(hash) do Wait(0) RequestModel(hash) end
            if Config.mojia then
                veh = CreateVehicle(hash,spawn,v.exteriorheading,true,true)
                if tonumber(body) > 950 then
                    body = 1000.0
                end
                if tonumber(engine) > 950 then
                    engine = 1000.0
                end
                exports[Config.Fuel]:SetFuel(veh, data.fuel)
                SetVehicleBodyHealth(veh, body + 7)
                SetVehicleEngineHealth(veh, engine + 7)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, data.plate, dealer)
                -- TriggerEvent("vehiclekeys:client:SetOwner", plate)
                TriggerEvent("vehiclekeys:client:SetOwner",  QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            else
                QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                    veh = CreateVehicle(hash,spawn,v.exteriorheading,true,true)
                    QBCore.Functions.SetVehicleProperties(veh, properties)
                    if body == nil then
                        body = 1000.0
                    elseif tonumber(body) > 950 then
                        body = 1000.0
                    end
                    if engine == nil then
                        engine = 1000.0
                    elseif tonumber(engine) > 950 then
                        engine = 1000.0
                    end
                    exports[Config.Fuel]:SetFuel(veh, data.fuel)
                    SetVehicleBodyHealth(veh, body)
                    SetVehicleEngineHealth(veh, engine)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                    TriggerServerEvent('qb-garage:server:updateVehicle', 3, data.fuel, engine, body, data.plate, dealer, "public")
                    -- TriggerEvent("vehiclekeys:client:SetOwner", plate)
                    TriggerEvent("vehiclekeys:client:SetOwner",  QBCore.Functions.GetPlate(veh))
                    SetVehicleEngineOn(veh, true, true)
                end, plate)
            end
        end
    end    
    TriggerServerEvent('k-dealership:changecarstate', veh, plate)
end)


RegisterNetEvent('k-dealership:setupsale', function(data)
    local name = data.name
    QBCore.Functions.TriggerCallback('k-dealership:getcars', function(cb)
       if not next(cb) then
       end
        if cb ~= {} then
            if cb ~= false then
            local cars = {
                {
                    header = "| ".. name .." |",
                    txt = "Shop Funds: $".. data.funds,
                    isMenuHeader = true
                }     
            } 
            for k,v in pairs(cb) do
                cars[#cars + 1] = {
                    header = v.hash,
                    params = {
                        event = "k-dealership:saleprice",
                        args = {
                            dealer = v.dealername,
                            hash = v.hash,
                            props = v.vehicleprops,
                            plate = v.vehicleplate,
                            body = v.bodydamage,
                            engine = v.enginedamage,
                            fuel = v.fuel
                        }
                    }                    
                }
            end
            exports['qb-menu']:openMenu(cars)
        else
            QBCore.Functions.Notify('You dont have any cars.', 'error', 5000)
        end
    end
    end, name, 1)
end)

RegisterNetEvent('k-dealership:saleprice', function(data)
    -- local ped = PlayerPedId()
    local hash = data.hash   
    local name = data.dealer
    local plate = data.plate
    local props = data.props
    local body = data.body
    local engine = data.engine
    local fuel = data.fuel
    local dialog = exports['qb-input']:ShowInput({
        header = hash .."  Price",
        submitText = "submit",
        inputs = {
            {
                text = "Amount",
                name = "Amount",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog ~= nil then
        entry = (dialog['Amount'])
        TriggerServerEvent('k-dealership:setoutcar', entry, hash, name, plate, props, body, engine, fuel)
        -- TaskWarpPedIntoVehicle(ped, hash, -1)
        -- TriggerEvent("vehiclekeys:client:SetOwner",  QBCore.Functions.GetPlate(hash))
    else
        QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
    end
end)

RegisterNetEvent('k-dealership:placecar', function(hash, name, plate, body, engine, fuel)
    local ped = PlayerPedId()
    for k,v in pairs(Config.Dealerships) do
        if k == name then
        if Config.mojia then
            while not HasModelLoaded(hash) do Wait(0) RequestModel(hash) end
                veh = CreateVehicle(hash,v.interiorspawn,v.interiorheading,true,true)
                plate = SetVehicleNumberPlateText(veh, plate)
                SetVehicleOnGroundProperly(veh)
                closestdealer = name
                if tonumber(body) > 950 then
                    body = 1000.0
                end
                if tonumber(engine) > 950 then
                    engine = 1000.0
                end
                exports[Config.Fuel]:SetFuel(veh, fuel)
                SetVehicleBodyHealth(veh, body)
                SetVehicleEngineHealth(veh, engine)
                TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, name)
                -- TriggerEvent("vehiclekeys:client:SetOwner", plate)
                TaskWarpPedIntoVehicle(ped, veh, -1)
                TriggerEvent("vehiclekeys:client:SetOwner",  QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, false, false)
            else
            QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                while not HasModelLoaded(hash) do Wait(0) RequestModel(hash) end
                veh = CreateVehicle(hash,v.interiorspawn,v.interiorheading,true,true)
                SetVehicleOnGroundProperly(veh)
                closestdealer = name
                --print(closestdealer)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                if tonumber(body) > 950 then
                    body = 1000.0
                end
                if tonumber(engine) > 950 then
                    engine = 1000.0
                end
                exports[Config.Fuel]:SetFuel(veh, fuel)
                SetVehicleBodyHealth(veh, body)
                SetVehicleEngineHealth(veh, engine)
                TriggerServerEvent('qb-garage:server:updateVehicle', 0, fuel, engine, body, plate, name, "public")
                TriggerEvent("vehiclekeys:client:SetOwner",  QBCore.Functions.GetPlate(veh))
                -- TriggerEvent("vehiclekeys:client:SetOwner", plate)
                SetVehicleEngineOn(veh, false, false)
            end, plate)
        end
        end
    end    
    TriggerServerEvent('k-dealership:changecarstate', veh, plate)
end)

RegisterNetEvent('k-dealership:pzcreator', function(coords, heading, plate, name, veh)
    local x, y, z = table.unpack(coords)
    QBCore.Functions.TriggerCallback('k-dealership:getcars', function(entityid)
        exports['qb-target']:AddBoxZone(plate, vector3(x, y, z-1.0), 2.5, 2.5, { 
        name=plate,
        heading = 0,
        debugPoly=false,
        minZ= z-1.5, 
        maxZ= z+1.5, 
            }, { 
            options = {
                { 
                event = "k-dealership:carmenu", 
                icon = "fas fa-car", 
                label = "Vehicle Menu",
                x = x,
                y = y,
                z = z,
                plate = plate,
                name = name,
                entity = entityid,
                veh = veh
                }, 
            },
              distance = 2.0
        })
    end, plate)
end)

RegisterNetEvent('k-dealership:carmenu', function(data)
    local name = data.name
    local plate = data.plate
    local car = data.veh
    local entityid = data.entity
    QBCore.Functions.TriggerCallback('k-dealership:vehicledata', function(vehData)
        if vehData ~= nil then
            local price = table.unpack(vehData).price
            local hash = table.unpack(vehData).hash            
            QBCore.Functions.TriggerCallback('k-dealership:getowner', function(cb)
                if cb then
            local purchase = {
                {
                    header = "| ".. name .." |",
                    txt = hash .." for $".. price,
                    isMenuHeader = true
                } ,    
                        {
                        header = "Move ".. hash,
                        params = {
                            event = "k-dealership:movecar",
                            args = {
                                hash = hash,
                                name = name,
                                plate = plate,
                                price = price,
                                coords = vector3(data.x,data.y,data.z),
                                entity = entityid,
                                car = car
                            }
                        }
                    },
                    {
                        header = "Change Price of ".. hash .." Price: $".. price,
                        params = {
                            event = "k-dealership:changeprice",
                            args = {
                                plate = plate,
                                price = price,
                                car = car
                            }
                        }
                    }
            }
            exports['qb-menu']:openMenu(purchase)
            else
                    local purchase = {
                {
                    header = "| ".. name .." |",
                    txt = hash .." for $".. price,
                    isMenuHeader = true
                } ,    
                 {
                        header = "Buy ".. hash .." for $".. price,
                        params = {
                            event = "k-dealership:buycar",
                            args = {
                                hash = hash,
                                name = name,
                                plate = plate,
                                price = price,
                                entity = entityid,
                                car = car
                            }
                        }
                    }
            }   
                exports['qb-menu']:openMenu(purchase)
                end
            end, name)
        end
    end, plate)
end)

RegisterNetEvent('k-dealership:movecar', function(data)
    local ped = PlayerPedId()
    local entityid = NetworkGetEntityFromNetworkId(data.entity)
    local hash = GetHashKey(data.hash)
    local x, y, z = table.unpack(data.coords)
    local pos = GetEntityCoords(ped)
    local veh = GetClosestVehicle(x, y, z, 5.0, 0, 0)
    if entityid > 0 then
        car = GetVehicleIndexFromEntityIndex(entityid)
    else
        car = GetVehicleIndexFromEntityIndex(data.car)
    end
    local plate = data.plate
    --TaskWarpPedIntoVehicle(ped, car, -1)
    FreezeEntityPosition(car, false)
    Wait(100)
    closestdealer = data.name
    --print(closestdealer)
    TriggerServerEvent('k-dealership:changecarstate', car, plate)
    if Config.mojia then
        TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, plate, closestdealer)
    else
        TriggerServerEvent('qb-garage:server:updateVehicle', 0, 100.0, 1000.0, 1000.0, plate, closestdealer, "public")
    end
    TriggerServerEvent('k-dealership:server:removezone', data.plate)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end)

RegisterNetEvent('k-dealership:removezone', function(plate)
    exports['qb-target']:RemoveZone(plate)
end)

RegisterNetEvent('k-dealership:changeprice', function(data)
    local plate = data.plate
    local dialog = exports['qb-input']:ShowInput({
        header = "| Change Price |",
        submitText = "submit",
        inputs = {
            {
                text = "Amount",
                name = "Amount",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog ~= nil then
        entry = (dialog['Amount'])
        TriggerServerEvent('k-dealership:setprice', entry, plate)
    else
        QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
    end
end)

RegisterNetEvent('k-dealership:buycar', function(data)
    QBCore.Functions.TriggerCallback('k-dealership:makepurchase', function(cb)
        if cb then
            local ped = PlayerPedId()
            -- local pos = GetEntityCoords(ped)
            local veh = data.car            
            local Player = QBCore.Functions.GetPlayerData()
            local source = Player.source
            -- SetEntityAsMissionEntity(veh, true, true)
            local plate = data.plate         
            Wait(5)
            TriggerServerEvent('k-dealership:transfer', source, plate)
            TriggerEvent("vehiclekeys:client:SetOwner", plate) -- new 
            TriggerServerEvent('k-dealership:removestock', plate, data.name, data.price)
            TriggerServerEvent('k-dealership:server:removezone', plate)
            if Config.mojia then
                TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, plate, "public")
            else
                TriggerServerEvent('qb-garage:server:updateVehicle', 0, 100.0, 1000.0, 1000.0, plate, closestdealer, "public")
            end
            QBCore.Functions.Notify('You purchased the vehicle.', 'success', 5000)
        else
            QBCore.Functions.Notify('You don\'t have enough for this vehicle.', 'error', 5000)
        end
    end, data.price) 
end)  

RegisterNetEvent('k-dealership:funds', function(data)
    local type = data.type
    local name = data.name
    local funds = data.funds
    local dialog = exports['qb-input']:ShowInput({
        header = type .." Funds | $".. funds,
        submitText = "submit",
        inputs = {
            {
                text = "Amount",
                name = "Amount",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog ~= nil then
        entry = (dialog['Amount'])
        local Player = QBCore.Functions.GetPlayerData()
        local source = Player.source
        TriggerServerEvent('k-dealership:setfunds', source, entry, type, funds, name)
    else
        QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
    end
end)

-- Blips
CreateThread(function()
	for _, info in pairs(Config.BlipLocations) do
		if Config.Blips then
	   		info.blip = AddBlipForCoord(info.x, info.y, info.z)
	   		SetBlipSprite(info.blip, info.id)
	   		SetBlipDisplay(info.blip, 4)
	   		SetBlipScale(info.blip, 0.7)	
	   		SetBlipColour(info.blip, info.colour)
	   		SetBlipAsShortRange(info.blip, true)
	   		BeginTextCommandSetBlipName("STRING")
	   		AddTextComponentString(info.title)
	   		EndTextCommandSetBlipName(info.blip)
	 	end
   	end	
end)