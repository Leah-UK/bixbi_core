ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function(xPlayer)
	while (ESX == nil) do
        Citizen.Wait(100)
    end
	
    PlayerData = xPlayer
	FreezeEntityPosition(PlayerPedId(), false)
	TriggerServerEvent('bixbi_core:RemoveFromInstance', GetPlayerServerId(PlayerId()))
end)

AddEventHandler('esx:onPlayerSpawn', function()
	local playerPed = PlayerPedId()
	if GetEntityHealth(playerPed) ~=  200 then
		SetEntityMaxHealth(playerPed, 200)
		SetEntityHealth(playerPed, 200)
	end
	TriggerServerEvent('bixbi_core:RemoveFromInstance', GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent('bixbi_core:Notify')
AddEventHandler('bixbi_core:Notify', function(type, msg, duration)
	Notify(type, msg, duration)
end)
function Notify(type, msg, duration)
	if (duration == nil) then duration = 5000 end
	if Config.NotifyType == "t-notify" then
		if type == '' or type == nil then type = 'info' end
		exports['t-notify']:Alert({style = type, message = string.gsub(msg, '(~[rbgypcmuonshw]~)', '')})
	elseif Config.NotifyType == "mythic_notify" then
		if type == '' or type == nil then type = 'inform' end
		exports['mythic_notify']:DoCustomHudText(type, string.gsub(msg, '(~[rbgypcmuonshw]~)', ''), duration)
	else
		ESX.ShowNotification(msg)
	end
end

RegisterNetEvent('bixbi_core:Loading')
AddEventHandler('bixbi_core:Loading', function(time, text)
	Loading(time, text)
end)
function Loading(time, text)
	if Config.LoadingType == "pogress" then
		exports['pogressBar']:drawBar(time, text)
	elseif Config.LoadingType == "mythic" then
		exports['mythic_progbar']:Progress({
			name = string.gsub(text, "%s+", ""),
			duration = time,
			label = text,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = false,
			},
		}, function()
		end)
	else
		-- Do nothing.
	end
end

function playAnim(ped, animDict, animName, duration, emoteMoving, playbackRate)
	local movingType = 49
	if (emoteMoving == nil) then 
		movingType = 49
	elseif (emoteMoving == false) then
		movingType = 0
	end
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do 
      Citizen.Wait(0) 
    end

	local playbackSpeed = playbackRate or 0
    -- TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, movingType, 1, false, false, false)
	TaskPlayAnim(ped, animDict, animName, 2.0, 2.0, duration, movingType, playbackSpeed, false, false, false)
    RemoveAnimDict(animDict)
end

function addProp(ped, prop1, bone, off1, off2, off3, rot1, rot2, rot3, timer)
	local x,y,z = table.unpack(GetEntityCoords(ped))
  
	if not HasModelLoaded(prop1) then
	  LoadPropDict(prop1)
	end
  
	prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop1)
	Citizen.Wait(timer)
	DeleteEntity(prop)
  end

function itemCount(item)
	if (Config.LindenInventory) then
		return exports['linden_inventory']:CountItems(item)[item]
	elseif (Config.OxInventory) then
		return exports['ox_inventory']:InventorySearch(2, item)
	else
		ESX.TriggerServerCallback('bixbi_core:itemCount', function(itemCount) 
			return itemCount
		end, item)
	end
end