local fixing, turn = false, false
local zcoords, mcolor = 255, 153, 51
local position = 0
Citizen.CreateThread(function()	
    while true do
		Citizen.Wait(5)	
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed, true)		
		for k,v in pairs(Config.Stations) do
			if not fixing then
				if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 100) then
					if IsPedInAnyVehicle(playerPed, false) then
						DrawMarker(1, v.x, v.y, v.z-0.4, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 153, 51, false, false, 2, false, false, false, false)
						if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 1.5) then							
							position = k
							if v.cost == false then
								hintToDisplay(_U('press_repair_free'))
								if IsControlJustPressed(0, 38) then	
									TriggerEvent('carfixstation:fixCar')						
									SetPedCoordsKeepVehicle(playerPed, v.x, v.y, v.z)
								end								
							else
								hintToDisplay(_U('press_repair_cost', v.cost))
								if IsControlJustPressed(0, 38) then									
									TriggerServerEvent('carfixstation:costRepair', v.cost)
									SetPedCoordsKeepVehicle(playerPed, v.x, v.y, v.z)
								end																
							end
						end
					end
				end
			else		
				if position == k then

				else
				end
			end
		end
    end
end)
RegisterNetEvent('carfixstation:markAnimation')
AddEventHandler('carfixstation:markAnimation', function()
    while true do
		Citizen.Wait(25)	
		if fixing then
			if zcoords < 0.5 and not turn then
				zcoords = zcoords + 0.03
				mcolor = mcolor + 2
			else
				turn = true
				zcoords = zcoords - 0.051
				mcolor = mcolor + 2
				if zcoords <= -0.4 then
					turn = false
				end
			end
		else
			break
		end
	end
end)
RegisterNetEvent('carfixstation:fixCar')
AddEventHandler('carfixstation:fixCar', function()
	local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	fixing = true
	TriggerEvent('carfixstation:markAnimation')	
	FreezeEntityPosition(vehicle, true)
	sendNotification(_U('repair_processing'), 'warning', Config.RepairTime-1)
	if Config.EnableSoundEffect == true then
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 1, 'car_repair', 1)
	end
	Wait(Config.RepairTime)
	fixing = false
	SetVehicleFixed(vehicle)
	SetVehicleDeformationFixed(vehicle)
	FreezeEntityPosition(vehicle, false)
	hintToDisplay(_U('repair_finish'))
	zcoords, mcolor, turn = 0.0, 0, false
end)
if Config.Blips then
	Citizen.CreateThread(function()
		for i=1, #Config.Stations, 1 do
			local blip = AddBlipForCoord(Config.Stations[i].x, Config.Stations[i].y, Config.Stations[i].z)

			SetBlipSprite (blip, 402)
			SetBlipDisplay(blip, 402)
			SetBlipScale  (blip, 1.5)
			SetBlipColour (blip, 47)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(_U('blips_name'))
			EndTextCommandSetBlipName(blip)
		end
	end)
end
function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
function sendNotification(message, messageType, messageTimeout)
	TriggerEvent("pNotify:SendNotification", {
		text = message,
		type = messageType,
		queue = "katalog",
		timeout = messageTimeout,
		layout = "bottomCenter"
	})
end