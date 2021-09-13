ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('bixbi_core:removeItem')
AddEventHandler('bixbi_core:removeItem', function(item, count)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem(item, count)
end)

RegisterServerEvent('bixbi_core:AddToInstance')
AddEventHandler('bixbi_core:AddToInstance', function(source, instanceId)
  SetPlayerRoutingBucket(source, instanceId)
end)

RegisterServerEvent('bixbi_core:RemoveFromInstance')
AddEventHandler('bixbi_core:RemoveFromInstance', function(source)
  if (GetPlayerRoutingBucket(source) ~= 0) then TriggerEvent('bixbi_core:AddToInstance', source, 0) end
end)

ESX.RegisterServerCallback('bixbi_core:itemCount', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local itemCount = xPlayer.getInventoryItem(item).count
  cb(itemCount)
end)

ESX.RegisterServerCallback('bixbi_core:canHoldItem', function(source, cb, item, count)
  local xPlayer = ESX.GetPlayerFromId(source)
  local canHold = xPlayer.canCarryItem(item, count)
  cb(canHold)
end)

ESX.RegisterServerCallback('bixbi_core:illegalTaskBlacklist', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local result = false
  if (Config.IllegalTaskBlacklist[xPlayer.job.name]) then
    result = true
  end
  cb(result)
end)

AddEventHandler('onResourceStart', function(resourceName)
  if ( string.find(resourceName, "bixbi_") ) then
    TriggerEvent('bixbi_core:VersionCheck', resourceName, GetResourceMetadata(resourceName, 'version'), GetResourceMetadata(resourceName, 'versioncheck'))
  end
end)

RegisterServerEvent('bixbi_core:VersionCheck')
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
      Citizen.Wait(60000 * 60)
    end
  end)
end)