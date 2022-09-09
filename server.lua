local QBCore = exports['qb-core']:GetCoreObject()
local loaded = false

RegisterServerEvent('k-dealership:delveh', function(coords, hash)
    TriggerClientEvent('k-dealership:deletevics', -1, coords, hash)
end)

RegisterServerEvent('k-dealership:server:removezone', function(plate)
    TriggerClientEvent('k-dealership:removezone', -1, plate)
end)

RegisterServerEvent('k-dealership:owncar', function(vehicle, plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cid = player.PlayerData.citizenid
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        player.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        --'',
        0
    })
    --print("did this work?")
end)

RegisterServerEvent('k-dealership:server:pzcreator', function(carcoords, heading, plate, closestdealer, curVeh)
    TriggerClientEvent('k-dealership:pzcreator', -1, carcoords, heading, plate, closestdealer, curVeh)
end)

QBCore.Functions.CreateCallback('k-dealership:dealerConfig', function(source, cb)
    cb(Config.Dealerships)
end)

QBCore.Functions.CreateCallback('k-dealership:getloaded', function(source, cb)
    if not loaded then
        loaded = true
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('k-dealership:purchaseshop', function(name)
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid   
    TriggerEvent('k-dealership:changeshopstate', name)
    Config.Dealerships[name]["purchased"] = true
    MySQL.query('UPDATE dealerships SET citizenid = ? WHERE dealername = ?', {citizenid, name})     
    MySQL.query('UPDATE dealerships SET purchased = ? WHERE dealername = ?', {1, name})     
end)

RegisterServerEvent('k-dealership:storevehicle', function(plate, hash, vehProperties, bodyDamage, engineDamage, totalFuel, name) 
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local info = MySQL.query.await('SELECT * FROM dealership_cars WHERE vehicleplate = ?', {plate})
    if info ~= nil then        
       if not next(info) then
            MySQL.insert('INSERT INTO dealership_cars (`citizenid`, `hash`, `dealername`, `state`, `vehicleplate`, `fuel`, `bodydamage`, `enginedamage`, `vehicleprops`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {citizenid, hash, name, 1, plate, totalFuel, bodyDamage, engineDamage, json.encode(vehProperties)}, function() end)
        else
            MySQL.query('UPDATE dealership_cars SET dealername = ? WHERE vehicleplate = ?', {name, plate})    
            MySQL.query('UPDATE dealership_cars SET fuel = ? WHERE vehicleplate = ?', {totalFuel, plate})    
            MySQL.query('UPDATE dealership_cars SET bodydamage = ? WHERE vehicleplate = ?', {bodyDamage, plate})    
            MySQL.query('UPDATE dealership_cars SET enginedamage = ? WHERE vehicleplate = ?', {engineDamage, plate})    
            MySQL.query('UPDATE dealership_cars SET state = ? WHERE vehicleplate = ?', { true, plate})    
        end   
    else
        MySQL.Async.insert('INSERT INTO dealership_cars (`citizenid`, `hash`, `dealername, `fuel`, `bodydamage`, `enginedamage`, `state`, `vehicleplate`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {citizenid, hash, name, totalFuel, bodyDamage, engineDamage, 1, plate})
    end
end)

RegisterServerEvent('k-dealership:updatecarloc', function(entityid, plate, x, y, z, heading)
    --print('i worked"')
    MySQL.query('UPDATE dealership_cars SET entityid = ? WHERE vehicleplate = ?', {entityid, plate})
    MySQL.query('UPDATE dealership_cars SET x = ? WHERE vehicleplate = ?', {x, plate})   
    MySQL.query('UPDATE dealership_cars SET y = ? WHERE vehicleplate = ?', {y, plate}) 
    MySQL.query('UPDATE dealership_cars SET z = ? WHERE vehicleplate = ?', {z, plate}) 
    MySQL.query('UPDATE dealership_cars SET w = ? WHERE vehicleplate = ?', {heading, plate})   
    MySQL.query('UPDATE dealership_cars SET state = ? WHERE vehicleplate = ?', {3, plate}) 
    --print("hmmmm")  
end)

RegisterServerEvent('k-dealership:changecarstatestore', function(plate)
    MySQL.query('UPDATE dealership_cars SET state = ? WHERE vehicleplate = ?', {true, plate})     
end)

RegisterServerEvent('k-dealership:changecarstate', function(entityid, plate)
    MySQL.query('UPDATE dealership_cars SET state = ? WHERE vehicleplate = ?', {false, plate})  
    MySQL.query('UPDATE dealership_cars SET entityid = ? WHERE vehicleplate = ?', {entityid, plate})    
end)

RegisterServerEvent('k-dealership:setoutcar', function(entry, hash, name, plate, props, body, engine, fuel)
    local src = source
    MySQL.query('UPDATE dealership_cars SET price = ? WHERE vehicleplate = ?', {entry, plate})     
    TriggerClientEvent('k-dealership:placecar', source, hash, name, plate, body, engine, fuel)
end)

RegisterServerEvent('k-dealership:setprice', function(entry, plate)
    MySQL.query('UPDATE dealership_cars SET price = ? WHERE vehicleplate = ?', {entry, plate})     
end)

RegisterServerEvent('k-dealership:transfer', function(source, plate)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid    
    MySQL.query('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {citizenid, plate})     
end)

RegisterServerEvent('k-dealership:removestock', function(plate, name, price)
    local info = MySQL.query.await('SELECT * FROM dealerships WHERE dealername = ?', {name})
    local funds = table.unpack(info).funds
    local total = funds + price
    MySQL.query('UPDATE dealerships SET funds = ? WHERE dealername = ?', {total, name}) 
    MySQL.Async.execute('DELETE FROM dealership_cars WHERE vehicleplate = ?', {plate})    
end)

RegisterServerEvent('k-dealership:setfunds', function(source, input, type, funds, name)
    local info = MySQL.query.await('SELECT * FROM dealerships WHERE dealername = ?', {name})
    local funds = table.unpack(info).funds
    local src = source
    local entry = tonumber(input)
    local Player = QBCore.Functions.GetPlayer(src)
    if type == 'Withdraw' then
        local total = funds - entry
        if total >= 0 then
            MySQL.query('UPDATE dealerships SET funds = ? WHERE dealername = ?', {total, name}) 
            Player.Functions.AddMoney('bank', entry)
        end
    elseif type == 'Deposit' then
        if Player.PlayerData.money.bank >= entry then
            if Player.Functions.RemoveMoney('bank', entry) then
                local total = funds + entry
                MySQL.query('UPDATE dealerships SET funds = ? WHERE dealername = ?', {total, name}) 
            end
        end
    end
end)

QBCore.Functions.CreateCallback('k-dealership:makepurchase', function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    local cost = tonumber(price)
    if Player.PlayerData.money.bank >= cost then
        if Player.Functions.RemoveMoney('bank', cost) then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:getowner', function(source, cb, name) --do you own the dealership
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid    
    local info = MySQL.query.await('SELECT * FROM dealerships WHERE dealername = ?', {name})
    local ownerid = table.unpack(info).citizenid
    if ownerid == citizenid then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:dealershipinfo', function(source, cb, name)
    local info = MySQL.query.await('SELECT * FROM dealerships WHERE dealername = ?', {name})
    if info ~= nil then
        cb(info)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:gethash', function(source, cb, plate)
    local info = MySQL.query.await('SELECT * FROM dealership_cars WHERE vehicleplate = ?', {plate})
    if info ~= nil then
        local hash = table.unpack(info).hash
        cb(hash)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:entityid', function(source, cb, plate)
    local info = MySQL.query.await('SELECT * FROM dealership_cars WHERE vehicleplate = ?', {plate})
    if info ~= nil then
        local entityid = table.unpack(info).entityid
        cb(entityid)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:getowned', function(source, cb, name) -- is dealershippurchasable
    local info = MySQL.query.await('SELECT * FROM dealerships WHERE dealername = ?', {name})
    local owned = table.unpack(info).purchased
    local ownerid = table.unpack(info).citizenid
    if tostring(ownerid) ~= tostring(NULL) then
        Config.Dealerships[name]["purchased"] = true
        TriggerClientEvent('k-dealership:client:changeshopstate', -1, name)        
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:getname', function(source, cb, plate) -- is dealershippurchasable
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local info = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?',{plate})    
        cb(table.unpack(info).vehicle)
end)

QBCore.Functions.CreateCallback('k-dealership:getcars', function(source, cb, name, state) -- list of cars in the dealers garage
    local cars = MySQL.query.await('SELECT * FROM dealership_cars WHERE dealername = ? AND state = ?', {name, state})   
    cb(cars)
end)


QBCore.Functions.CreateCallback('k-dealership:getbank', function(source, cb)   
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    if bankBalance ~= nil then
        cb(bankBalance)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-dealership:vehicledata', function(source, cb, plate)
    local vehData = MySQL.query.await('SELECT * FROM dealership_cars WHERE vehicleplate = ?', {plate})   
        cb(vehData)
end)

QBCore.Functions.CreateCallback('k-dealership:spawnlotcars', function(source, cb, hash, coords, heading, plate)
    veh = CreateVehicle(hash,coords,heading,true,false) 
    SetVehicleNumberPlateText(veh, plate) 
        cb(veh)
end)