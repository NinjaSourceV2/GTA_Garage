--> Event : 
vehicle_plate_list = {}
getEmplacement = 0
list_vehicule = {}
vehicles_list_menu = {} --> Tableau qui contient la liste des véhicule du joueurs.

RegisterNetEvent('garages:UpdateEmplacementDispo')
AddEventHandler('garages:UpdateEmplacementDispo', function(emplacement)
    getEmplacement = emplacement
end)

RegisterNetEvent('garages:GetVehiclesListClient')
AddEventHandler('garages:GetVehiclesListClient', function(vehicles)
	list_vehicule = {}
    list_vehicule = vehicles
    
	for k in pairs(vehicles_list_menu) do
		vehicles_list_menu[k] = nil
    end
    
	for _, v in pairs(list_vehicule) do
		table.insert(vehicles_list_menu, v)
	end
end)

RegisterNetEvent('garages:RenomerVeh')
AddEventHandler('garages:RenomerVeh', function(vehicle_name, plaque)
    local newVehicleNom = InputText()
    TriggerServerEvent("garages:NewVehiculeName", newVehicleNom, plaque)
    refreshMenuRename()
end)

RegisterNetEvent('garages:SpawnVehicle')
AddEventHandler('garages:SpawnVehicle', function(state, model, plate, plateindex,colorprimary,colorsecondary,pearlescentcolor,wheelcolor)
    local car = GetHashKey(model)
    Citizen.CreateThread(function()
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local playerPos = GetEntityCoords(player, 1)
		local VehPos = GetOffsetFromEntityInWorldCoords(player, 0.0,20.0, 0.0)
        local targetVehicle = getVehicleInDirection(playerPos, VehPos)
        
        if state == "Sortit" then
            exports.nCoreGTA:nNotificationMain({
				text = "Votre véhicule se trouve en dehors de votre garage.",
				type = 'basGauche',
				nTimeNotif = 3500,
			})
            return 
        end

		if DoesEntityExist(targetVehicle) then
			exports.nCoreGTA:nNotificationMain({
				text = "La zone est encombrée",
				type = 'basGauche',
				nTimeNotif = 1000,
			})
		else
            RequestModel(model)
            local waiting = 0
            while not HasModelLoaded(model) do
                waiting = waiting + 100
                Citizen.Wait(100)
                if waiting > 3000 then
                    exports.nCoreGTA:nNotificationMain({
                        text = "~r~Véhicule non trouver.",
                        type = 'basGauche',
                        nTimeNotif = 3500,
                    })
                    break
                end
            end

            for i = 1, #Config.Locations do 
                local garagePos = Config.Locations[i]["GarageEntrer"]
                local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local dist = GetDistanceBetweenCoords(plyCoords, garagePos["x"], garagePos["y"], garagePos["z"], true)
                
                if dist <= 10.0 then
                    veh = CreateVehicle(model, garagePos["x"], garagePos["y"], garagePos["z"], garagePos["h"], true, false)
                end
            end

            SetVehicleNumberPlateText(veh, plate)
            SetVehicleOnGroundProperly(veh)
            SetVehicleColours(veh, tonumber(colorprimary), tonumber(colorsecondary))
            SetVehicleExtraColours(veh, tonumber(pearlescentcolor), tonumber(wheelcolor))
            SetVehicleNumberPlateTextIndex(veh,tonumber(plateindex))
            SetVehicleNeonLightsColour(veh,tonumber(neoncolor1),tonumber(neoncolor2),tonumber(neoncolor3))
            SetVehicleTyreSmokeColor(veh,tonumber(smokecolor1),tonumber(smokecolor2),tonumber(smokecolor3))
            SetVehicleModKit(veh,0)
            SetPedIntoVehicle(player, veh, -1)
            
            SetVehicleWindowTint(veh,tonumber(windowtint))
            SetEntityInvincible(veh, false) 
            SetVehicleHasBeenOwnedByPlayer(veh, true)

            local id = NetworkGetNetworkIdFromEntity(veh)
            SetNetworkIdCanMigrate(id, true)
            
            exports.nCoreGTA:ShowNotification("Véhicule sorti, bonne route")

            TriggerServerEvent('garages:SetVehOut', plate)
            TriggerEvent('garages:SetVehiculePerso', veh)
		end
	end)
end)

RegisterNetEvent('garages:StoreFirstVehicle')
AddEventHandler('garages:StoreFirstVehicle', function(zoneGarage)
    Citizen.CreateThread(function()		
        Citizen.Wait(0)
		local playerPed  = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(playerPed, false)    
        local platecaissei = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)

        if IsPedInAnyVehicle(playerPed) then
            local colors = table.pack(GetVehicleColours(vehicle))
            local extra_colors = table.pack(GetVehicleExtraColours(vehicle))
            local primarycolor = colors[1]
            local secondarycolor = colors[2]
            local pearlescentcolor = extra_colors[1]
            local wheelcolor = extra_colors[2]

            SetEntityAsMissionEntity(vehicle, true, true)
            Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))

            exports.nCoreGTA:ShowNotification("~g~ Véhicule rentré !")


            TriggerServerEvent('garages:SetVehicule', "Mon vehicule", model, platecaissei, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zoneGarage)
            Wait(150)
            TriggerServerEvent('garages:CheckDuplicationVeh', zoneGarage, platecaissei)
        else
            exports.nCoreGTA:ShowNotification("~r~ Veuillez entrer dans un véhicule !")
        end
        --> Anti Duplication :
        TriggerServerEvent("garages:CheckVehiculeAntiDupli", GetInfoGarage())
	end)
end)

RegisterNetEvent('garages:StoreVehicle')
AddEventHandler('garages:StoreVehicle', function(zoneGarage, plate_list, max)
    vehicle_plate_list = {}
	vehicle_plate_list = plate_list
    Citizen.CreateThread(function()
        Citizen.Wait(0)

		local playerPed  = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(playerPed, false)    
        local platecaissei = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)


        if IsPedInAnyVehicle(playerPed) then
            local plate = "#####"

            for _, v in pairs(vehicle_plate_list) do
				if v == platecaissei then 
					plate = v
				end
            end

            local colors = table.pack(GetVehicleColours(vehicle))
            local extra_colors = table.pack(GetVehicleExtraColours(vehicle))
            local primarycolor = colors[1]
            local secondarycolor = colors[2]
            local pearlescentcolor = extra_colors[1]
            local wheelcolor = extra_colors[2]

            if tostring(string.upper(plate)) == tostring(string.upper(platecaissei)) then	
                SetEntityAsMissionEntity( vehicle, true, true)
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
                
                TriggerServerEvent('garages:SetVehIn', platecaissei)
                
                exports.nCoreGTA:ShowNotification("~g~ Véhicule rentré !")
            else
                if getEmplacement <= max then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))

                    TriggerServerEvent('garages:SetVehicule', "Mon vehicule", model, platecaissei, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, zoneGarage)
                    Wait(150)
                    TriggerServerEvent('garages:CheckDuplicationVeh', zoneGarage, platecaissei)
                    
                    exports.nCoreGTA:ShowNotification("~g~ Véhicule rentré !")

                else
                    exports.nCoreGTA:ShowNotification("~y~Tout les emplacement disponible sont pris, veuillez revendre ou supprimer un véhicule.")
                end
			end
        else
            exports.nCoreGTA:ShowNotification("~r~ Veuillez entrer dans un véhicule !")
        end
        --> Anti Duplication :
        TriggerServerEvent("garages:CheckVehiculeAntiDupli", GetInfoGarage())
	end)
end)

function GetInfoGarage()
    for i = 1, #Config.Locations do 
        local garagePos = Config.Locations[i]["GarageEntrer"]
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local max =  Config.Locations[i]["GarageEntrer"]["MaxVeh"]
        local zone =  Config.Locations[i]["GarageEntrer"]["NomZone"]
        local dist = GetDistanceBetweenCoords(plyCoords, garagePos["x"], garagePos["y"], garagePos["z"], true)
        
        if dist <= 10.0 then
            return garagePos
        end
    end
end

function refreshMenuRename()
    for i = 1, #Config.Locations do
        local garagePos = Config.Locations[i]["GarageEntrer"]
        local zone = Config.Locations[i]["GarageEntrer"]["NomZone"]
        local max = Config.Locations[i]["GarageEntrer"]["MaxVeh"]
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = GetDistanceBetweenCoords(plyCoords, garagePos["x"], garagePos["y"], garagePos["z"], true)

        if dist <= 3.0 then
            TriggerServerEvent("garages:GetEmplacement", zone)
            TriggerServerEvent('garages:GetVehiclesList', GetInfoGarage())
            Wait(250)
            mainMenu.Title = zone
            subVehiculeListSortir.Title = zone
            mainMenu:SetSubtitle("Emplacement : "..getEmplacement.. "/".. max + 1)
            subVehiculeListSortir:SetSubtitle("Emplacement : "..getEmplacement.. "/".. max + 1)
            RageUI.Visible(subVehiculeListSortir, true)
        end
    end
end

--> Si le joueur déco, on lui remet ses véhicule dans son garage a son spawn :
AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent("garages:PutAllVehInGarages")
end)