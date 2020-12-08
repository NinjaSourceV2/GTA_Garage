--> Version de la Resource : 
local LatestVersion = ''; CurrentVersion = '1.9'
PerformHttpRequest('https://raw.githubusercontent.com/NinjaSourceV2/GTA_Garage/master/VERSION', function(Error, NewestVersion, Header)
    LatestVersion = NewestVersion
    if CurrentVersion ~= NewestVersion then
        print("\n\r ^2[GTA_Garage]^1 La version que vous utilisé n'est plus a jours, veuillez télécharger la dernière version. ^3\n\r")
    end
end)

RegisterServerEvent('garages:PutAllVehInGarages')
AddEventHandler('garages:PutAllVehInGarages', function()
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = vehicle_state WHERE identifier = @identifier", { 
        ['@identifier'] = player,
        ['@vehicle_state'] = "Rentré"
    })
end)

RegisterServerEvent('garages:RemoveVehicule')
AddEventHandler('garages:RemoveVehicule', function(plaque)
	MySQL.Sync.execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @plate", {['@plate'] = tostring(plaque)})
end)

local vehicles = {}
RegisterServerEvent('garages:GetVehiclesList')
AddEventHandler('garages:GetVehiclesList', function(garage)
	vehicles = {}
	local source = source
	local zone = garage["NomZone"]

    MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @username",{['@username'] = tostring(zone)}, function(result)
		for k, v in pairs(result) do
			table.insert(vehicles, {name = v.vehicle_name, plaque = v.vehicle_plate, state = v.vehicle_state})
		end

		TriggerClientEvent('garages:GetVehiclesListClient', source, vehicles)
	end)
end)

RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(vehiclename, garage, immatricule)
	local source = source
	local zone = garage["NomZone"]

	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @zone AND vehicle_name = @vehicle_name",{['@zone'] = tostring(zone), ['@vehicle_name'] = vehiclename}, function(result)
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
AddEventHandler('garages:RenameVeh', function(vehiclename, plaque)
	local source = source
	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate AND vehicle_name = @vehicle_name",{['@vehicle_plate'] = plaque, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:RenomerVeh', source, result[1].vehicle_name, result[1].vehicle_plate)
	end)
end)

RegisterServerEvent('garages:NewVehiculeName')
AddEventHandler('garages:NewVehiculeName', function(newVehicleName, plaque)
	MySQL.Async.execute("UPDATE gta_joueurs_vehicle SET vehicle_name = @vehicle_name WHERE vehicle_plate = @vehicle_plate", { 
        ['@vehicle_name'] = newVehicleName,
        ['@vehicle_plate'] = plaque
    })
end)


local vehicle_plate_list = {}
RegisterServerEvent('garages:CheckForVeh')
AddEventHandler('garages:CheckForVeh', function(garage)
	vehicle_plate_list = {}
	local source = source
	local maxEmplacement = garage["MaxVeh"]
	local zone = garage["NomZone"]

	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom", {['@nom'] = tostring(zone)}, function(res)
		for _, v in pairs(res) do
			table.insert(vehicle_plate_list, v.vehicle_plate)
		end

		if (#res ~= 0) then
			TriggerClientEvent('garages:StoreVehicle', source, zone, vehicle_plate_list, maxEmplacement)
		else
			TriggerClientEvent('garages:StoreFirstVehicle', source, zone)
		end
	end)
end)

RegisterServerEvent('garages:CheckVehiculeAntiDupli')
AddEventHandler('garages:CheckVehiculeAntiDupli', function(garage)
	local source = source
	local zone = garage["NomZone"]

	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom", {['@nom'] = tostring(zone)}, function(res)
        local dupli = MySQL.Sync.fetchScalar("SELECT vehicle_plate FROM gta_joueurs_vehicle GROUP BY vehicle_plate HAVING COUNT(vehicle_plate) > 1")
		if dupli then 
			MySQL.Sync.execute("DELETE FROM gta_joueurs_vehicle WHERE proprietaire = @proprietaire AND zone_garage = @zone_garage", {['@proprietaire'] = tostring("Volé"), ['@zone_garage'] = tostring(zone)})
		end
	end)
end)

RegisterServerEvent('garages:CheckDuplicationVeh')
AddEventHandler('garages:CheckDuplicationVeh', function(zone, plate)
	local source = source
	local dupli = MySQL.Sync.fetchScalar("SELECT vehicle_plate FROM gta_joueurs_vehicle GROUP BY vehicle_plate HAVING COUNT(vehicle_plate) > 1")
	if dupli then 
		local zoneDupli = MySQL.Sync.fetchScalar("SELECT zone_garage FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate", {['@vehicle_plate'] = plate})
		if zoneDupli == "Aucun" then
			MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET zone_garage = @zone_garage WHERE vehicle_plate = @vehicle_plate", { 
				['@zone_garage'] = tostring(zone),
				['@vehicle_plate'] = plate
			})

			MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = tostring("Rentré")}, {['vehicle_plate'] = plate}})
		else
			MySQL.Sync.execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate AND zone_garage = @zone_garage", {['@vehicle_plate'] = tostring(dupli), ['@zone_garage'] = tostring(zone)})
			
			MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = tostring("Rentré")}, {['vehicle_plate'] = plate}})
			TriggerClientEvent('nMenuNotif:showNotification', source, "~r~ Duplication de véhicule détecter, le véhicule à été automatiquement remis dans votre garage.")
		end
	end
end)

RegisterServerEvent('garages:GetEmplacement')
AddEventHandler('garages:GetEmplacement', function(zone)
	local source = source
	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom", {['@nom'] = tostring(zone)}, function(res)
		TriggerClientEvent('garages:UpdateEmplacementDispo', source, #res)
	end)
end)

RegisterServerEvent('garages:SetVehOut')
AddEventHandler('garages:SetVehOut', function(plate)
	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = @vehicle_state WHERE vehicle_plate = @vehicle_plate", { 
		['@vehicle_state'] = "Sortit",
		['@vehicle_plate'] = plate
	})
end)

RegisterServerEvent('garages:SetVehIn')
AddEventHandler('garages:SetVehIn', function(plate)
	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = @vehicle_state WHERE vehicle_plate = @vehicle_plate", { 
		['@vehicle_state'] = "Rentré",
		['@vehicle_plate'] = plate
	})
end)

RegisterServerEvent('garages:SetVehicule')
AddEventHandler('garages:SetVehicule', function(nameCar, model, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zone_garage)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Sync.execute("INSERT INTO gta_joueurs_vehicle  (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `zone_garage`) VALUES(@identifier, @vehicle_name, @vehicle_model, @vehicle_plate, @vehicle_state, @vehicle_colorprimary, @vehicle_colorsecondary, @vehicle_pearlescentcolor, @vehicle_wheelcolor, @zone_garage)", {
		['@identifier'] = player,
		['@vehicle_name'] = nameCar,
		['@vehicle_model'] = model,
		['@vehicle_plate'] = plate,
		['@vehicle_state'] = "Rentré",
		['@vehicle_colorprimary'] = primarycolor,
		['@vehicle_colorsecondary'] = secondarycolor,
		['@vehicle_pearlescentcolor'] = pearlescentcolor,
		['@vehicle_wheelcolor'] = wheelcolor,
		['@zone_garage'] = zone_garage
	})
end)


---------------------------------------------------> A REWORK LE PLAYER DROP
AddEventHandler('playerDropped', function(reason)
	local source = source
	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = @vehicle_state WHERE vehicle_plate = @vehicle_plate", { 
		['@vehicle_state'] = "Rentré",
		['@vehicle_state'] = "Sortit"
	})
end)