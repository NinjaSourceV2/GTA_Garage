
--> Version de la Resource : 
local LatestVersion = ''; CurrentVersion = '1.0'
PerformHttpRequest('https://raw.githubusercontent.com/NinjaSourceV2/GTA_Garage/master/VERSION', function(Error, NewestVersion, Header)
    LatestVersion = NewestVersion
    if CurrentVersion ~= NewestVersion then
        print("\n\r ^2[GTA_Garage]^1 La version que vous utilisé n'est plus a jours, veuillez télécharger la dernière version. ^3\n\r")
    end
end)


RegisterServerEvent('garages:PutVehInGarages')
AddEventHandler('garages:PutVehInGarages', function(vehicle)
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}})
end)

local vehicles = {}

RegisterServerEvent('garages:GetVehiclesList')
AddEventHandler('garages:GetVehiclesList', function()
	vehicles = {}
	local player = GetPlayerIdentifiers(source)[1]
	local source = source

    exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @username",{['@username'] = player}, function(result)
		for k, v in pairs(result) do
			if v.vehicle_state == "Rentré" then
				table.insert(vehicles, v.vehicle_name)
			end
		end
		TriggerClientEvent('garages:GetVehiclesListClient', source, vehicles)
	end)
end)

RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(vehiclename)
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]
	
	exports.ghmattimysql:execute("SELECT * FROM gta_joueurs_vehicle WHERE identifier = @identifier AND vehicle_name = @vehicle_name",{['@identifier'] = identifier, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:SpawnVehicle', source, result[1].vehicle_state,result[1].vehicle_model,result[1].vehicle_plate,result[1].vehicle_plateindex,result[1].vehicle_colorprimary,result[1].vehicle_colorsecondary,result[1].vehicle_pearlescentcolor,result[1].vehicle_wheelcolor,result[1].vehicle_neoncolor1,result[1].vehicle_neoncolor2,result[1].vehicle_neoncolor3,result[1].vehicle_windowtint,result[1].vehicle_wheeltype,result[1].vehicle_mods0,result[1].vehicle_mods1,result[1].vehicle_mods2,result[1].vehicle_mods3,result[1].vehicle_mods4,result[1].vehicle_mods5,result[1].vehicle_mods6,result[1].vehicle_mods7,result[1].vehicle_mods8,result[1].vehicle_mods9,result[1].vehicle_mods10,result[1].vehicle_mods11,result[1].vehicle_mods12,result[1].vehicle_mods13,result[1].vehicle_mods14,result[1].vehicle_mods15,result[1].vehicle_mods16,result[1].vehicle_turbo,result[1].vehicle_tiresmoke,result[1].vehicle_xenon,result[1].vehicle_mods23,result[1].vehicle_mods24,result[1].vehicle_neon0,result[1].vehicle_neon1,result[1].vehicle_neon2,result[1].vehicle_neon3,result[1].vehicle_bulletproof,result[1].vehicle_smokecolor1,result[1].vehicle_smokecolor2,result[1].vehicle_smokecolor3,result[1].vehicle_modvariation)
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

RegisterServerEvent("ply_garages2:UpdateVeh")
AddEventHandler('ply_garages2:UpdateVeh', function(plate, plateindex, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, neoncolor1, neoncolor2, neoncolor3, windowtint, wheeltype, mods0, mods1, mods2, mods3, mods4, mods5, mods6, mods7, mods8, mods9, modds10, modds11, modds12, modds13, modds14, modds15, modds16, turbo, tiresmoke, xenon, modds23, modds24, neon0, neon1, neon2, neon3, bulletproof, smokecolor1, smokecolor2, smokecolor3, variation)
	local source = source
	exports.ghmattimysql:execute('UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?',
	{
	{
		['vehicle_plateindex'] = plateindex,
		['vehicle_colorprimary'] = primarycolor,
		['vehicle_colorsecondary'] = secondarycolor,
		['vehicle_pearlescentcolor'] = pearlescentcolor,
		['vehicle_wheelcolor'] = wheelcolor,
		['vehicle_neoncolor1'] = neoncolor1,
		['vehicle_neoncolor2'] = neoncolor2,
		['vehicle_neoncolor3'] = neoncolor3,
		['vehicle_windowtint'] = windowtint,
		['vehicle_wheeltype'] = wheeltype,
		['vehicle_mods0'] = mods0,
		['vehicle_mods1'] = mods1,
		['vehicle_mods2'] = mods2,
		['vehicle_mods3'] = mods3,
		['vehicle_mods4'] = mods4,
		['vehicle_mods5'] = mods5,
		['vehicle_mods6'] = mods6,
		['vehicle_mods7'] = mods7,
		['vehicle_mods8'] = mods8,
		['vehicle_mods9'] = mods9,
		['vehicle_mods10'] = mods10,
		['vehicle_mods11'] = mods11,
		['vehicle_mods12'] = mods12,
		['vehicle_mods13'] = mods13,
		['vehicle_mods14'] = mods14,
		['vehicle_mods15'] = mods15,
		['vehicle_mods16'] = mods16,
		['vehicle_turbo'] = turbo,
		['vehicle_tiresmoke'] = tiresmoke,
		['vehicle_xenon'] = xenon,
		['vehicle_mods23'] = mods23,
		['vehicle_mods24'] = mods24,
		['vehicle_neon0'] = neon0,
		['vehicle_neon1'] = neon1,
		['vehicle_neon2'] = neon2,
		['vehicle_neon3'] = neon3,
		['vehicle_bulletproof'] = bulletproof,
		['vehicle_smokecolor1'] = smokecolor1,
		['vehicle_smokecolor2'] = smokecolor2,
		['vehicle_smokecolor3'] = smokecolor3,
		['vehicle_modvariation'] = variation,
	},
	{['identifier'] = GetPlayerIdentifiers(source)[1]},
	{['vehicle_plate'] = plate}
	})
end)


RegisterServerEvent('garages:SetVehOut')
AddEventHandler('garages:SetVehOut', function(vehicle)
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Sortit"}, {['identifier'] = player}, {['vehicle_model'] = vehicle}})
end)


RegisterServerEvent('garages:SetVehIn')
AddEventHandler('garages:SetVehIn', function(plate)
	local player = GetPlayerIdentifiers(source)[1]
	exports.ghmattimysql:execute("UPDATE gta_joueurs_vehicle SET ? WHERE ? AND ?", { {['vehicle_state'] = "Rentré"}, {['identifier'] = player}, {['vehicle_plate'] = plate}})
end)