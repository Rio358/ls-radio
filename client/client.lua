local PlayerData = {}
local plyState = LocalPlayer.state
local radioMenu = false
function enableRadio(enable)
	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(true)
	radioMenu = enable
	
	SendNUIMessage({
		type = "enableui",
		enable = enable
	})
end

RegisterNUICallback('volup', function(data, cb)
	local volume = exports["pma-voice"]:getRadioVolume() * 100
	local newvol = volume + 10
	if volume < 90 then
		exports["pma-voice"]:setRadioVolume(newvol)
		exports.mythic_notify:SendAlert('inform','Radio increased to ' .. newvol )
	end
	cb('ok')
end)

RegisterNUICallback('voldown', function(data, cb)
	local volume = exports["pma-voice"]:getRadioVolume() * 100
	local newvol = volume- 10
	if volume > 10 then
		exports["pma-voice"]:setRadioVolume(newvol)
		exports.mythic_notify:SendAlert('inform','Radio decreased to ' .. newvol )
	end
	cb('ok')
end)

RegisterNUICallback('joinRadio', function(data, cb)
	local _source = source
	local PlayerData = ESX.GetPlayerData(_source)
	local playerName = GetPlayerName(PlayerId())
	
	if tonumber(data.channel) then
		if tonumber(data.channel) <= Config.RestrictedChannels then
			if (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'fire') then
				exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
				exports["pma-voice"]:setRadioChannel(tonumber(data.channel))
				exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. ' MHz </b>')
			elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'fire') then
				exports['mythic_notify']:SendAlert('error', Config.messages['restricted_channel_error'])
			end
		end
		if tonumber(data.channel) > Config.RestrictedChannels then
			exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
			exports["pma-voice"]:setRadioChannel(tonumber(data.channel))
			print('success?' .. tonumber(data.channel))
			exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. ' MHz </b>')
		end
	else
		exports['mythic_notify']:SendAlert('error', Config.messages['you_on_radio'] .. data.channel .. ' MHz </b>')
	end
	cb('ok')
end)

-- remove from radio
RegisterNUICallback('leaveRadio', function(data, cb)
	exports["pma-voice"]:setRadioChannel(0)
	exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
	exports['mythic_notify']:SendAlert('inform', Config.messages['you_leave'])
	cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
	enableRadio(false)
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	RadioDisable()
	cb('ok')
end)

RegisterCommand('radiostuck', function()
	enableRadio(false)
	SetNuiFocusKeepInput(false)
	SetNuiFocus(false, false)
	RadioDisable()
end)
CreateThread(function()
	TriggerEvent('chat:removeSuggestion', '/radiostuck')
end)

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
	enableRadio(true)
	RadioToggle()
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function(source)
	local playerName = GetPlayerName(source)
	exports["pma-voice"]:setRadioChannel(0)
	exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
	exports['mythic_notify']:SendAlert('inform', Config.messages['you_leave'])
end)


function setRadioDisabled()
	TriggerEvent('ls-radio:onRadioDrop')
end
exports('setRadioDisabled', setRadioDisabled)

function RadioToggle()
	local playerPed = PlayerPedId()
	local count = 0
	local dictionaryType = 1 + (IsPedInAnyVehicle(playerPed, false) and 1 or 0)
	local animationType = 1 + (radioOpen and 0 or 1)
	local dictionary = "cellphone@"
	local animation = "cellphone_text_in"
	local prop = `prop_cs_hand_radio`
	RequestAnimDict("cellphone@")
	
	while not HasAnimDictLoaded("cellphone@") do
		Wait(100)
	end
	RequestModel(prop)
	while not HasModelLoaded(prop) do
		Wait(100)
	end
	radioProp = CreateObject(prop, 0.0, 0.0, 0.0, true, true, false)
	local bone = GetPedBoneIndex(playerPed, 28422)
	SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
	AttachEntityToEntity(radioProp, playerPed, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 2, true)
	SetModelAsNoLongerNeeded(radioProp)
	TaskPlayAnim(playerPed, "cellphone@", "cellphone_text_in", 4.0, 4.0, -1, 50, 0, false, false, false)
end

function RadioDisable()
	local playerPed = PlayerPedId()
	local radio = `prop_cs_hand_radio`
	radioOpen = false
	TaskPlayAnim(playerPed, "cellphone@", "cellphone_text_out", 4.0, 4.0, -1, 49, 0, false, false, false)
	Wait(500)
	NetworkRequestControlOfEntity(radioProp)
	local count = 0
	while not NetworkHasControlOfEntity(radioProp) and count < 10 do
		Wait(200)
		count = count + 1
	end
	DetachEntity(radioProp, true, false)
	DeleteEntity(radioProp)
	ClearPedTasks(playerPed)
end

CreateThread(function()
	while true do
		if radioMenu and not ESX.PlayerData.dead and not GetPedConfigFlag(PlayerPedId(), 120, true) then
			DisableControlAction(0, 1, guiEnabled)-- LookLeftRight
			DisableControlAction(0, 2, guiEnabled)-- LookUpDown
			DisableControlAction(0, 24, guiEnabled)-- Melee Attack
			DisableControlAction(0, 25, guiEnabled)-- Melee Attack
			DisablePlayerFiring(PlayerPedId(),false)
			DisableControlAction(0, 106, guiEnabled)-- VehicleMouseControlOverride
			DisableControlAction(0, 142, guiEnabled)-- MeleeAttackAlternate
			DisableControlAction(0, 172, guiEnabled)-- Up
			DisableControlAction(0, 173, guiEnabled)-- Down
			DisableControlAction(0, 174, guiEnabled)-- Left
			DisableControlAction(0, 175, guiEnabled)-- Right
			--DisableControlAction(0, 176, guiEnabled)-- Enter/Left Click Cellphone Select
			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					type = "click"
				})
			end
		end
		Wait(0)
	end
end)
