--> Version de la Resource : 
local LatestVersion = ''; CurrentVersion = '2.1'
PerformHttpRequest('https://raw.githubusercontent.com/NinjaSourceV2/GTA_Garage/master/VERSION', function(Error, NewestVersion, Header)
    LatestVersion = NewestVersion
    if CurrentVersion ~= NewestVersion then
        print("\n\r ^2[GTA_Garage]^1 La version que vous utilisé n'est plus a jours, veuillez télécharger la dernière version. ^3\n\r")
    end
end)
math.randomseed(os.time())
RegisterServerEvent('garages:PutAllVehInGarages')
AddEventHandler('garages:PutAllVehInGarages', function()
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = vehicle_state WHERE identifier = @identifier", { 
        ['@vehicle_state'] = "Rentré",
        ['@identifier'] = player
    })
end)

RegisterServerEvent('garages:RemoveVehicule')
AddEventHandler('garages:RemoveVehicule', function(plaque)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	MySQL.Sync.execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @plate and identifier = @identifier", {['@plate'] = tostring(plaque), ['@identifier'] = player})
end)

local vehicles = {}
RegisterServerEvent('garages:GetVehiclesList')
AddEventHandler('garages:GetVehiclesList', function(garage)
	vehicles = {}
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local zone = garage["NomZone"]

    MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @garage and identifier = @identifier",{['@garage'] = tostring(zone), ['@identifier'] = player}, function(result)
		for _, v in pairs(result) do
			table.insert(vehicles, {name = v.vehicle_name, plaque = v.vehicle_plate, state = v.vehicle_state})
		end

		TriggerClientEvent('garages:GetVehiclesListClient', source, vehicles)
	end)
end)

RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(vehiclename, garage, immatricule)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local zone = garage["NomZone"]

	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE vehicle_plate = @immatricule AND identifier = @identifier",{['@immatricule'] = tostring(immatricule), ['@identifier'] = player}, function(result)
		if (result[1].vehicle_state == "Sortit") then
			TriggerClientEvent("NUI-Notification", source, {"Ce véhicule se trouve à l'extérieur de votre garage."})
		else
			TriggerClientEvent('garages:SpawnVehicle', source, result[1].vehicle_state, tonumber(result[1].vehicle_model),result[1].vehicle_plate,result[1].vehicle_plateindex,result[1].vehicle_colorprimary,result[1].vehicle_colorsecondary,result[1].vehicle_pearlescentcolor,result[1].vehicle_wheelcolor)
		end
	end)
end)

RegisterServerEvent('garages:RenameVeh')
AddEventHandler('garages:RenameVeh', function(vehiclename, plaque)
	local source = source
	MySQL.Async.fetchAll("SELECT vehicle_name, vehicle_plate FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate AND vehicle_name = @vehicle_name",{['@vehicle_plate'] = plaque, ['@vehicle_name'] = vehiclename}, function(result)
		TriggerClientEvent('garages:RenomerVeh', source, result[1].vehicle_name, result[1].vehicle_plate)
	end)
end)

RegisterServerEvent('garages:NewVehiculeName')
AddEventHandler('garages:NewVehiculeName', function(newVehicleName, plaque)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Async.execute("UPDATE gta_joueurs_vehicle SET vehicle_name = @vehicle_name WHERE vehicle_plate = @vehicle_plate and identifier = @identifier", { 
        ['@vehicle_name'] = newVehicleName,
        ['@vehicle_plate'] = plaque,
        ['@identifier'] = player
    })
end)

RegisterServerEvent('garages:CheckForVeh')
AddEventHandler('garages:CheckForVeh', function(immatri)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchAll("SELECT vehicle_plate, proprietaire FROM gta_joueurs_vehicle WHERE identifier = @identifier", {['@identifier'] = player}, function(res)
		for _, v in pairs(res) do
			if (v.vehicle_plate == immatri) then
				TriggerClientEvent('garages:StoreVehicle', source, v.vehicle_plate)
				return
			end
		end
		TriggerClientEvent('garages:StoreVehicleStolen', source, immatri)
	end)
end)

local vehicle_plate_list_stolen = {}
RegisterServerEvent('garages:NewStolenCar')
AddEventHandler('garages:NewStolenCar', function(model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, vehicle, max, GetInfoGarage)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local zone = GetInfoGarage["NomZone"]
	local maxEmplacement = GetInfoGarage["MaxVeh"]
	local randomId = math.random(0,999)
	local value = {player, "Vehicule Moldu#"..randomId, model, immatricul, "Rentré", primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zone, "Volé", 0}
	vehicle_plate_list_stolen = {}

	MySQL.Async.fetchAll("SELECT vehicle_plate FROM gta_joueurs_vehicle WHERE identifier = @identifier", {['@identifier'] = player}, function(res)
		if (res[1] ~= nil) then
			for _, v in pairs(res) do
				table.insert(vehicle_plate_list_stolen, v.vehicle_plate)
			end
		
			if (max <= maxEmplacement) then
				if (immatri == vehicle_plate_list_stolen[1]) then
					TriggerClientEvent('garages:StoreVehicle', source, vehicle_plate_list_stolen)
					TriggerClientEvent("garages:RefreshIsVehExist", source, vehicle)
				else 
					MySQL.Sync.execute('INSERT INTO gta_joueurs_vehicle (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `zone_garage`, `proprietaire`, `prix`) VALUES ?', { { value } })
					TriggerClientEvent("garages:RefreshIsVehExist", source, vehicle)
				end
			else
				TriggerClientEvent("NUI-Notification", source, {"Ce garage est complet."})
			end
		else
			MySQL.Sync.execute('INSERT INTO gta_joueurs_vehicle (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `zone_garage`, `proprietaire`, `prix`) VALUES ?', { { value } })
			TriggerClientEvent("garages:RefreshIsVehExist", source, vehicle)
		end
	end)
end)

RegisterServerEvent('garages:CheckDuplicationVeh')
AddEventHandler('garages:CheckDuplicationVeh', function(model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zoneGarage, vehicle)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local dupli = MySQL.Sync.fetchScalar("SELECT vehicle_plate FROM gta_joueurs_vehicle GROUP BY vehicle_plate HAVING COUNT(vehicle_plate) > 1")
	local randomId = math.random(0,999)
	
	if dupli then 
		TriggerClientEvent("NUI-Notification", source, {"Duplication de véhicule détecter, le véhicule ne peut pas être ranger dans ce garage."})
	else
		MySQL.Sync.execute("INSERT INTO gta_joueurs_vehicle  (`identifier`, `vehicle_name`, `vehicle_model`, `vehicle_plate`, `vehicle_state`, `vehicle_colorprimary`, `vehicle_colorsecondary`, `vehicle_pearlescentcolor`, `vehicle_wheelcolor`, `zone_garage`) VALUES(@identifier, @vehicle_name, @vehicle_model, @vehicle_plate, @vehicle_state, @vehicle_colorprimary, @vehicle_colorsecondary, @vehicle_pearlescentcolor, @vehicle_wheelcolor, @zone_garage)", {
			['@identifier'] = player,
			['@vehicle_name'] = "Mon vehicule#"..randomId,
			['@vehicle_model'] = model,
			['@vehicle_plate'] = plate,
			['@vehicle_state'] = "Rentré",
			['@vehicle_colorprimary'] = primarycolor,
			['@vehicle_colorsecondary'] = secondarycolor,
			['@vehicle_pearlescentcolor'] = pearlescentcolor,
			['@vehicle_wheelcolor'] = wheelcolor,
			['@zone_garage'] = zone_garage
		})
		TriggerClientEvent("garages:RefreshIsVehExist", source, vehicle)
	end
end)

RegisterServerEvent('garages:GetEmplacement')
AddEventHandler('garages:GetEmplacement', function(zone)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE zone_garage = @nom and identifier = @identifier", {['@nom'] = tostring(zone), ['@identifier'] = player}, function(res)
		TriggerClientEvent('garages:UpdateEmplacementDispo', source, #res)
	end)
end)

RegisterServerEvent('garages:SetVehOut')
AddEventHandler('garages:SetVehOut', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	MySQL.Sync.execute("UPDATE gta_joueurs_vehicle SET vehicle_state = @vehicle_state WHERE vehicle_plate = @vehicle_plate and identifier = @identifier", { 
		['@vehicle_state'] = "Sortit",
		['@vehicle_plate'] = plate,
		['@identifier'] = player
	})
end)

RegisterServerEvent('garages:SetVehIn')
AddEventHandler('garages:SetVehIn', function(model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, vehicle, max, garage)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local maxEmplacement = garage["MaxVeh"]
	local zone = garage["NomZone"]

	MySQL.Async.execute( "UPDATE gta_joueurs_vehicle SET vehicle_state=@vehicle_state, zone_garage=@zone_garage WHERE vehicle_plate=@vehicle_plate and identifier = @identifier", {
	['@vehicle_plate'] = immatricul,
	['@identifier'] = player,
	['@vehicle_state'] = "Rentré",
	['@zone_garage'] = tostring(zone)})
end)



--[=====[
        Synchronisation du coffre une fois le player deconnecter :
]=====]
AddEventHandler('playerDropped', function(reason)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Async.execute( "UPDATE gta_joueurs_vehicle SET vehicle_state=@vehicle_state WHERE identifier = @identifier", {
		['@identifier'] = player,
		['@vehicle_state'] = "Rentré"
	})
end)


local clesList = {}
RegisterServerEvent('GTA_Garage:RefreshTableCles')
AddEventHandler('GTA_Garage:RefreshTableCles', function()
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local res = MySQL.Sync.fetchAll("SELECT plate, count, label FROM cles_vehicule WHERE license = @player", { ['@player'] = player})

	if (clesList[player] == nil) then 

		clesList[player] = {}

		if (res) then
			for _,v in pairs(res) do
				clesList[player][#clesList[player] + 1] = {plate = v.plate, count = v.count, label = v.label}
			end
		end
	end

	TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
end)


RegisterServerEvent('GTA_Garage:RequestPlayerCles')
AddEventHandler('GTA_Garage:RequestPlayerCles', function(VehId, plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local plateFound = nil

	for _,v in pairs(clesList[player]) do 
		if (v.plate == plate) then
			plateFound = v.plate
			break
		end
	end

	if (plateFound ~= nil) then
		TriggerClientEvent("GTA_Garage:IsPlayerHaveCles", source, VehId, true)
	else
		TriggerClientEvent("GTA_Garage:IsPlayerHaveCles", source, VehId, false)
	end
end)

RegisterServerEvent('GTA_Garage:RequestPlayerClesOutside')
AddEventHandler('GTA_Garage:RequestPlayerClesOutside', function(VehId, plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local plateFound = nil

	if (clesList[player] ~= nil) then
		for _,v in pairs(clesList[player]) do 
			if (v.plate == plate) then 
				plateFound = v.plate
				break
			end
		end

		if (plateFound ~= nil) then
			TriggerClientEvent("GTA_Garage:IsPlayerHaveClesOutside", source, VehId, true)
		else
			TriggerClientEvent("GTA_Garage:IsPlayerHaveClesOutside", source, VehId, false)
		end
	end
end)

RegisterServerEvent('GTA_Garage:SupprimerCles')
AddEventHandler('GTA_Garage:SupprimerCles', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	for k,v in pairs(clesList[player]) do
        if v.plate == plate then
            clesList[player][k] = nil
        end
    end

	MySQL.Sync.execute("DELETE FROM `cles_vehicule` WHERE license = @player AND plate = @plate", { 
        ['@player'] = player,
        ['@plate'] = plate
    })
	
	TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
end)

RegisterServerEvent('GTA_Garage:RenomerCles')
AddEventHandler('GTA_Garage:RenomerCles', function(plate, new_label)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]

	MySQL.Sync.execute("UPDATE `cles_vehicule` SET `label`=@label WHERE license = @identifier AND plate = @plate", { 
		['@identifier'] = player,
		['@plate'] = plate,
		['@label'] = new_label
	})

	Wait(50)

	local res = MySQL.Sync.fetchAll("SELECT plate, count, label FROM cles_vehicule WHERE license = @player", { ['@player'] = player})
	for _, v in pairs(res) do
		clesList[player][#clesList[player]] = {plate = v.plate, count = v.count, label = v.label}
	end

	TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
end)

RegisterServerEvent('GTA_Garage:DonnerCles')
AddEventHandler('GTA_Garage:DonnerCles', function(target, plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local playerTarget = GetPlayerIdentifiers(target)[1]
	local res = MySQL.Sync.fetchAll("SELECT plate, count FROM cles_vehicule WHERE license = @player", { ['@player'] = playerTarget})

	for k,v in pairs(clesList[player]) do
        if v.plate == plate then
			if (res[1] == nil or res[1].plate == plate and res[1].count < 1) then
				MySQL.Sync.execute("UPDATE `cles_vehicule` SET `license`=@recieverid, `label`=@label WHERE license = @identifier AND plate = @plate", { 
					['@recieverid'] = playerTarget,
					['@identifier'] = player,
					['@plate'] = plate,
					['@label'] = plate
				})

				clesList[player][#clesList[player] + 1] = {plate = v.plate, count = 0, label = v.plate}
				clesList[playerTarget][#clesList[playerTarget] + 1] = {plate = v.plate, count = 1}
				clesList[player][k] = nil

				TriggerClientEvent("NUI-Notification", source, {"Vous avez donner votre clé immatricule : "..plate})
				TriggerClientEvent("NUI-Notification", target, {"Vous avez reçu une clé immatricule : "..plate})

				TriggerClientEvent("GTA_Inv:ReceiveItemAnim", target)
				TriggerClientEvent("GTA_Inv:ReceiveItemAnim", source)
			else
				TriggerClientEvent("NUI-Notification", source, {"Cette personne à déjà cette clé immatricule : " ..plate})
				TriggerClientEvent("NUI-Notification", target, {"Vous avez déjà une clé sur vous immatricule : "..plate})
			end
        end
    end

	TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
	TriggerClientEvent("GTA:UpdateClesVehicule", target, clesList[playerTarget])
end)


RegisterServerEvent('GTA_Garage:CopierCles')
AddEventHandler('GTA_Garage:CopierCles', function(target, plate)
	local source = source
	local playerTarget = GetPlayerIdentifiers(target)[1]
	local player = GetPlayerIdentifiers(source)[1]
	local res = MySQL.Sync.fetchAll("SELECT plate, count FROM cles_vehicule WHERE license = @player", { ['@player'] = playerTarget})

	for _,v in pairs(clesList[player]) do
        if v.plate == plate then
			if (res[1] == nil or res[1].plate == plate and res[1].count < 1) then
				MySQL.Sync.execute("INSERT INTO `cles_vehicule`(`license`, `plate`, `count`, `label`) VALUES (@recieverid,@plate,@count,@label)", { 
					['@recieverid'] = player,
					['@plate'] = plate,
					['@count'] = 1,
					['@label'] = plate
				})

				clesList[player][#clesList[player] + 1] = {plate = v.plate, count = 1, label = plate}

				TriggerClientEvent("GTA_Inv:ReceiveItemAnim", target)
				TriggerClientEvent("GTA_Inv:ReceiveItemAnim", source)
			
				TriggerClientEvent("NUI-Notification", source, {"Vous avez donner un double de vos clé immatricule : "..plate})
				TriggerClientEvent("NUI-Notification", target, {"Vous avez reçu un double de clé immatricule : "..plate})
				TriggerClientEvent("GTA:UpdateClesVehicule", target, clesList[playerTarget])
			else
				TriggerClientEvent("NUI-Notification", source, {"Cette personne à déjà cette clé immatricule : " ..plate})
				TriggerClientEvent("NUI-Notification", target, {"Vous avez déjà une clé sur vous immatricule : "..plate})
				return
			end
        end
    end
end)


RegisterServerEvent('garages:CreerNouvelCles')
AddEventHandler('garages:CreerNouvelCles', function(plate)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local res = MySQL.Sync.fetchAll("SELECT plate, count FROM cles_vehicule WHERE license = @player AND plate = @plate", { ['@player'] = player, ['@plate'] = plate})
	
	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate",{['@vehicle_plate'] = plate}, function(result)
		if (result[1].proprietaire ~= "Volé") then
			if (res[1] == nil) then
				MySQL.Sync.execute("INSERT INTO `cles_vehicule`(`license`, `plate`, `count`, `label`) VALUES (@recieverid,@plate,@count,@label)", { 
					['@recieverid'] = player,
					['@plate'] = plate,
					['@count'] = 1,
					['@label'] = plate,
				})
	
				clesList[player][#clesList[player] + 1] = {plate = plate, count = 1, label = plate}
	
				TriggerClientEvent("NUI-Notification", source, {"Vous avez reçu une nouvel clé créer avec l'immatricule : "..plate})
				TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
			elseif (res[1].plate ~= plate and res[1].count < 1) then
				MySQL.Sync.execute("INSERT INTO `cles_vehicule`(`license`, `plate`, `count`, `label`) VALUES (@recieverid,@plate,@count,@label)", { 
					['@recieverid'] = player,
					['@plate'] = plate,
					['@count'] = 1,
					['@label'] = plate,
				})
	
				clesList[player][#clesList[player] + 1] = {plate = plate, count = 1, label = plate}
	
				TriggerClientEvent("NUI-Notification", source, {"Vous avez reçu une nouvel clé créer avec l'immatricule : "..plate})
				TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
			else
				TriggerClientEvent("NUI-Notification", source, {"Vous avez déjà une clé sur vous immatricule : "..plate})
			end
		else
			TriggerClientEvent("NUI-Notification", source, {"Vous ne pouvez pas faire de double de clé avec un véhicule volé."})
		end
	end)
end)


RegisterServerEvent('GTA_Receler:RequestVenteVehicule')
AddEventHandler('GTA_Receler:RequestVenteVehicule', function(plate, vehicule)
	local source = source
	local player = GetPlayerIdentifiers(source)[1]
	local price = 0
	MySQL.Async.fetchAll("SELECT * FROM gta_joueurs_vehicle WHERE vehicle_plate = @vehicle_plate and identifier = @identifier", {['@vehicle_plate'] = tostring(plate), ['@identifier'] = player}, function(res)
		if (res[1] ~= nil) then
			if (res[1].proprietaire == "Volé") then 
				TriggerClientEvent("NUI-Notification", source, {"Ce véhicule ne peut pas être revendu il est volé."})
			else
				price = (price /2) + res[1].prix
				MySQL.Sync.execute("DELETE FROM gta_joueurs_vehicle WHERE vehicle_plate = @plate and identifier = @identifier", {['@plate'] = tostring(plate), ['@identifier'] = player})
				MySQL.Sync.execute("DELETE FROM `cles_vehicule` WHERE license = @player AND plate = @plate", { 
					['@player'] = player,
					['@plate'] = plate
				})


				for k,v in pairs(clesList[player]) do
					if v.plate == plate then
						clesList[player][k] = nil
					end
				end

				TriggerClientEvent("garages:RefreshIsVehExist", source, vehicule)
				TriggerClientEvent("GTA:UpdateClesVehicule", source, clesList[player])
				TriggerClientEvent("GTA_Inventaire:AjouterItem", source, "cash", price)
				TriggerClientEvent("NUI-Notification", source, {"Véhicule revendu pour "..price .. "$"})
			end
		else
			TriggerClientEvent("NUI-Notification", source, {"Ce véhicule n'est pas enregistrer dans votre garage."})
		end
	end)
end)

