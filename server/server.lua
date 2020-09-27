--> Version de la Resource : 
local LatestVersion = ''; CurrentVersion = '1.5'
PerformHttpRequest('https://raw.githubusercontent.com/NinjaSourceV2/GTA_Garage/master/VERSION', function(Error, NewestVersion, Header)
    LatestVersion = NewestVersion
    if CurrentVersion ~= NewestVersion then
        print("\n\r ^2[GTA_Garage]^1 La version que vous utilisé n'est plus a jours, veuillez télécharger la dernière version. ^3\n\r")
    end
end)

RegisterServerEvent('garages:PutVehInGarages')
AddEventHandler('garages:PutVehInGarages', function()
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}})
end)

RegisterServerEvent('garages:RemoveVehicule')
AddEventHandler('garages:RemoveVehicule', function(plaque)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @plate", {['@plate'] = tostring(plaque)})
end)

local vehicles = {}
RegisterServerEvent('garages:GetVehiclesList')
AddEventHandler('garages:GetVehiclesList', function(garage)
	vehicles = {}
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local zone = garage["NomZone"]

    exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @username",{['@username'] = tostring(zone)}, function(result)
		for k, v in pairs(result) do
			table.insert(vehicles, {name = v.vehicle_name, plaque = v.vehicle_plate, state = v.vehicle_state})
		end

		TriggerClientEvent('garages:GetVehiclesListClient', source, vehicles)
	end)
end)

RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(vehiclename, garage, immatricule)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	local zone = garage["NomZone"]

	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @zone AND vehicle_name = @vehicle_name",{['@zone'] = tostring(zone), ['@vehicle_name'] = vehiclename}, function(result)
		if immatricule ~= result[1].vehicle_plate then
			if result[1].vehicle_state == "Sortit" then
				TriggerClientEvent('nMenuNotif:showNotification', source, "Ce véhicule ne se trouve pas dans votre garage.")
			end
		else
			TriggerClientEvent('garages:SpawnVehicle', source, result[1].vehicle_state,result[1].vehicle_model,result[1].vehicle_plate,result[1].vehicle_plateindex,result[1].vehicle_colorprimary,result[1].vehicle_colorsecondary,result[1].vehicle_pearlescentcolor,result[1].vehicle_wheelcolor)
		end
	end)
end)

RegisterServerEvent('garages:RenameVeh')
AddEventHandler('garages:RenameVeh', function(vehiclename)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @identifier AND vehicle_name = @vehicle_name",{['@identifier'] = identifier, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:RenomerVeh', source, result[1].vehicle_name, result[1].vehicle_plate)
	end)
end)

RegisterServerEvent('garages:NewVehiculeName')
AddEventHandler('garages:NewVehiculeName', function(newVehicleName, plaque)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_name'] = newVehicleName}, {['identifier'] = identifier}, {['vehicle_plate'] = plaque}})
end)


local vehicle_plate_list = {}
RegisterServerEvent('garages:CheckForVeh')
AddEventHandler('garages:CheckForVeh', function(garage)
	vehicle_plate_list = {}

	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	local maxEmplacement = garage["MaxVeh"]
	local zone = garage["NomZone"]

	--print("Max Emplacement : ", maxEmplacement)
	--print("Zone : ", zone)
	
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom", {['@nom'] = tostring(zone)}, function(res)
		for k, v in pairs(res) do
			table.insert(vehicle_plate_list, v.vehicle_plate)
		end

		if (#res ~= 0) then
			TriggerClientEvent('garages:StoreVehicle', source, zone, vehicle_plate_list, maxEmplacement)
		else
			TriggerClientEvent('garages:StoreFirstVehicle', source, zone)
		end		
	end)
end)

RegisterServerEvent('garages:CheckDuplicationVeh')
AddEventHandler('garages:CheckDuplicationVeh', function(zone)
	local source = source
	exports.ghmattimysql:scalar("SELECT vehicle_plate FROM gta_joueurs_vehicle GROUP BY vehicle_plate HAVING COUNT(vehicle_plate) > 1", function(dupli)
		if dupli then 
			TriggerClientEvent('nMenuNotif:showNotification', source, "~r~ Duplication de véhicule détecter, le véhicule à été automatiquement supprimer !")
			exports.ghmattimysql:execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate AND zone_garage = @zone_garage", {['@vehicle_plate'] = tostring(dupli), ['@zone_garage'] = tostring(zone)})
		end
	end)
end)

RegisterServerEvent('garages:GetEmplacement')
AddEventHandler('garages:GetEmplacement', function(zone)
	local source = source
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom", {['@nom'] = tostring(zone)}, function(res)
		TriggerClientEvent('garages:UpdateEmplacementDispo', source, #res)
	end)
end)

RegisterServerEvent('garages:SetVehOut')
AddEventHandler('garages:SetVehOut', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Sortit"}, {['identifier'] = player}, {['vehicle_plate'] = plate}})
end)

RegisterServerEvent('garages:SetVehIn')
AddEventHandler('garages:SetVehIn', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}, {['vehicle_plate'] = plate}})
end)

RegisterServerEvent('garages:SetVehicule')
AddEventHandler('garages:SetVehicule', function(nameCar, model, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zone_garage)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local valeurs = { player, nameCar, model, plate, "Rentré", primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zone_garage}
	exports.ghmattimysql:execute('INSERT INTO gta_joueurs_vehicle (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `zone_garage`) VALUES ?', { { valeurs } })
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = "Rentré"}, {['vehicle_state'] = 'Sortit'}})
end)