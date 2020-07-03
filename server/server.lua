
--> Version de la Resource : 
local LatestVersion = ''; CurrentVersion = '1.2'
PerformHttpRequest('https://raw.githubusercontent.com/NinjaSourceV2/GTA_Garage/master/VERSION', function(Error, NewestVersion, Header)
    LatestVersion = NewestVersion
    if CurrentVersion ~= NewestVersion then
        print("\n\r ^2[GTA_Garage]^1 La version que vous utilisé n'est plus a jours, veuillez télécharger la dernière version. ^3\n\r")
    end
end)


RegisterServerEvent('garages:PutVehInGarages')
AddEventHandler('garages:PutVehInGarages', function(vehicle)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}})
end)

local vehicles = {}

RegisterServerEvent('garages:GetVehiclesList')
AddEventHandler('garages:GetVehiclesList', function()
	vehicles = {}
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

    exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @username",{['@username'] = player}, function(result)
		for k, v in pairs(result) do
			if v.vehicle_state == "Rentré" then
				table.insert(vehicles, v.vehicle_name)
			end
		end
		TriggerClientEvent('garages:GetVehiclesListClient', source, vehicles)
	end)
end)

RegisterServerEvent('garages:GetVehiclesList2')
AddEventHandler('garages:GetVehiclesList2', function()
	vehicles = {}
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

    exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @username",{['@username'] = player}, function(result)
		for k, v in pairs(result) do
			if v.vehicle_state == "Rentré" then
				table.insert(vehicles, v.vehicle_name)
			end
		end
		TriggerClientEvent('garages:GetVehiclesListClient2', source, vehicles)
	end)
end)


RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(vehiclename)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @identifier AND vehicle_name = @vehicle_name",{['@identifier'] = identifier, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:SpawnVehicle', source, result[1].vehicle_state,result[1].vehicle_model,result[1].vehicle_plate,result[1].vehicle_plateindex,result[1].vehicle_colorprimary,result[1].vehicle_colorsecondary,result[1].vehicle_pearlescentcolor,result[1].vehicle_wheelcolor)
	end)
end)

RegisterServerEvent('garages:RenameVeh')
AddEventHandler('garages:RenameVeh', function(vehiclename)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @identifier AND vehicle_name = @vehicle_name",{['@identifier'] = identifier, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:RenomerVeh', source, result[1].vehicle_name, result[1].vehicle_model)
	end)
end)

RegisterServerEvent('garages:NewVehiculeName')
AddEventHandler('garages:NewVehiculeName', function(newVehicleName, vehicle)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_name'] = newVehicleName}, {['identifier'] = identifier}, {['vehicle_model'] = vehicle}})
end)


local vehicle_plate_list = {}
RegisterServerEvent('garages:CheckForVeh')
AddEventHandler('garages:CheckForVeh', function()
	vehicle_plate_list = {}
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	exports.ghmattimysql:execute("SELECT vehicle_model,vehicle_plate FROM gta_joueurs_vehicle WHERE identifier = @username",{['@username'] = player}, function(result)
		for k, v in pairs(result) do
			table.insert(vehicle_plate_list, v.vehicle_plate)
		end
		TriggerClientEvent('garages:StoreVehicle', source, vehicle_plate_list)
	end)
end)

RegisterServerEvent('garages:SetVehOut')
AddEventHandler('garages:SetVehOut', function(vehicle)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Sortit"}, {['identifier'] = player}, {['vehicle_model'] = vehicle}})
end)


RegisterServerEvent('garages:SetVehIn')
AddEventHandler('garages:SetVehIn', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}, {['vehicle_plate'] = plate}})
end)


AddEventHandler('playerDropped', function (reason)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = "Rentré"}, {['vehicle_state'] = 'Sortit'}})
end)