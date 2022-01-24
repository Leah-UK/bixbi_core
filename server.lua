ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[---------------------------------------------------
Remove Item
--]]---------------------------------------------------
function removeItem(src, item, count, metadata)
    if (src == nil) then src = source end
    if (src == nil) then return end

    if (Config.OxInventory) then
        exports.ox_inventory:RemoveItem(src, item, count, metadata)
    else 
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(item, count)
    end
end
exports('removeItem', removeItem)
RegisterServerEvent('bixbi_core:removeItem')
AddEventHandler('bixbi_core:removeItem', function(src, item, count, metadata)
    removeItem(src, item, count, metadata)
end)
--[[---------------------------------------------------
Add Item
--]]---------------------------------------------------
function addItem(source, item, count, metadata)
    if (source == nil) then return end
    if (Config.OxInventory) then
        local Inventory = exports.ox_inventory
        local canCarryItem = Inventory:CanCarryItem(source, item, count)
        if (canCarryItem) then
            Inventory:AddItem(source, item, count, metadata)
            return true
        else
            TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You cannot carry this item')
            return false
        end
    else
        if (xPlayer.canCarryItem(item, count)) then
            xPlayer.addInventoryItem(item, count)
            return true
        else
            TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You cannot carry this item')
            return false
        end
    end
end
exports('addItem', addItem)
AddEventHandler('bixbi_core:addItem', function(item, count)
    return addItem(source, item, count)
end)
--[[---------------------------------------------------
Item Count
--]]---------------------------------------------------
function itemCount(source, item, metadata)
    if (source == nil) then return end
    if (Config.OxInventory) then
        local itemCount = exports.ox_inventory:Search(source, 'count', item, metadata)
        if (itemCount == nil) then itemCount = 0 end
		return itemCount
	else
		local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getInventoryItem(item).count
	end
end
exports('sv_itemCount', itemCount)
ESX.RegisterServerCallback('bixbi_core:itemCountCb', function(source, cb, item, metadata)
    cb(itemCount(source, item, metadata))
end)
RegisterServerEvent('bixbi_core:sv_itemCount')
AddEventHandler('bixbi_core:sv_itemCount', function(source, item, metadata)
    return itemCount(source, item, metadata)
end)
--[[---------------------------------------------------
Can Hold Item
--]]---------------------------------------------------
function canHoldItem(source, item, count)
    if (source == nil) then return end
    if (Config.OxInventory) then
		return exports.ox_inventory:CanCarryItem(source, item, count)
	else
		local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.canCarryItem(item, count)
	end
end
exports('sv_canHoldItem', canHoldItem)
ESX.RegisterServerCallback('bixbi_core:canHoldItem', function(source, cb, item, count)
    cb(canHoldItem(source, item, count))
end)
RegisterServerEvent('bixbi_core:sv_canHoldItem')
AddEventHandler('bixbi_core:sv_canHoldItem', function(source, item, count)
    return canHoldItem(source, item, count)
end)

--[[---------------------------------------------------
Instances
--]]---------------------------------------------------
RegisterServerEvent('bixbi_core:AddToInstance')
AddEventHandler('bixbi_core:AddToInstance', function(source, instanceId)
    SetPlayerRoutingBucket(source, instanceId)
        if (instanceId == 0) then return end
    SetRoutingBucketEntityLockdownMode(instanceId, 'strict')
    SetRoutingBucketPopulationEnabled(instanceId, false)
end)

RegisterServerEvent('bixbi_core:RemoveFromInstance')
AddEventHandler('bixbi_core:RemoveFromInstance', function(source)
    if (GetPlayerRoutingBucket(source) ~= 0) then TriggerEvent('bixbi_core:AddToInstance', source, 0) end
end)

--[[---------------------------------------------------
Misc
--]]---------------------------------------------------
ESX.RegisterServerCallback('bixbi_core:illegalTaskBlacklist', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    -- var = check (and) true (or) false
    local result = Config.IllegalTaskBlacklist[xPlayer.job.name] == true and true or false
    cb(result)
end)

ESX.RegisterServerCallback('bixbi_core:jobCount', function(source, cb, job)
    cb(#ESX.GetExtendedPlayers('job', job))
end)

AddEventHandler('onResourceStart', function(resourceName)
    if ( string.find(resourceName, "bixbi_") ) then
        TriggerEvent('bixbi_core:VersionCheck', resourceName, GetResourceMetadata(resourceName, 'version'), GetResourceMetadata(resourceName, 'versioncheck'))
    end
end)

AddEventHandler('bixbi_core:VersionCheck', function(resourceName, currentVersion, url)
  if (currentVersion == nil or url == nil) then return end
  Citizen.Wait(10000)
  CreateThread(function()
    local latestVersion = nil
    local outdated = '^3[' .. resourceName .. ']^7 - You can upgrade to ^2v%s^7 (currently using ^1v%s^7)'
    while Config.VersionChecks do
      Citizen.Wait(1000)
      PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then print("Returned error code:" .. tostring(errorCode)) else
          local data, version = tostring(resultData)
          for line in data:gmatch("([^\n]*)\n?") do
            if line:find('^version ') then version = line:sub(10, (line:len(line) - 1)) break end
          end         
          latestVersion = version
          if latestVersion then 
            if currentVersion ~= latestVersion then
              print(outdated:format(latestVersion, currentVersion))
            end
          end
        end
      end)
      Citizen.Wait(60000 * 120)
    end
  end)
end)

AddEventHandler('bixbi_core:VersionCheck', function(resourceName, currentVersion, url)
    if (currentVersion == nil or url == nil) then return end
    CreateThread(function()
        Citizen.Wait(10000)

        local latestVersion = nil
        local outdated = '^3[' .. resourceName .. ']^7 - You can upgrade to ^2v%s^7 (currently using ^1v%s^7)'
        PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then print("Returned error code:" .. tostring(errorCode)) else
                local data, version = tostring(resultData)
                for line in data:gmatch("([^\n]*)\n?") do
                    if line:find('^version ') then version = line:sub(10, (line:len(line) - 1)) break end
                end         
                latestVersion = version
                if latestVersion and currentVersion ~= latestVersion then 
                    print(outdated:format(latestVersion, currentVersion))
                end
            end
        end)
    end)
end)