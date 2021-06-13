RegisterNetEvent('garages:UpdateEmplacementDispo')
AddEventHandler('garages:UpdateEmplacementDispo', function(emplacement)
    Config.getEmplacement = emplacement
end)

RegisterNetEvent('garages:RefreshIsVehExist')
AddEventHandler('garages:RefreshIsVehExist', function(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
end)

RegisterNetEvent('garages:GetVehiclesListClient')
AddEventHandler('garages:GetVehiclesListClient', function(vehicles)
	for k in pairs(Config.vehicles_list_menu) do
		Config.vehicles_list_menu[k] = nil
    end
    
	for _, v in pairs(vehicles) do
		table.insert(Config.vehicles_list_menu, v)
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
    local player = GetPlayerPed(-1)
    local playerPos = GetEntityCoords(player, 1)
    local VehPos = GetOffsetFromEntityInWorldCoords(player, 0.0,20.0, 0.0)
    local targetVehicle = getVehicleInDirection(playerPos, VehPos)
    
    if DoesEntityExist(targetVehicle) then
        TriggerEvent("NUI-Notification", {"La zone est encombrée.", "warning"})
    else
        RequestModel(model)
        while not HasModelLoaded(model) do
          Citizen.Wait(0)
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
        
        TriggerEvent("NUI-Notification", {"Véhicule sorti, bonne route"})
        TriggerServerEvent('garages:SetVehOut', plate)
        TriggerEvent('garages:SetVehiculePerso', veh)
    end
end)

RegisterNetEvent('garages:StoreVehicle')
AddEventHandler('garages:StoreVehicle', function(plate)
    Citizen.CreateThread(function()
        Citizen.Wait(0)

		local playerPed  = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(playerPed, false)    
        local immatricul = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)


        if IsPedInAnyVehicle(playerPed) then
            local colors = table.pack(GetVehicleColours(vehicle))
            local extra_colors = table.pack(GetVehicleExtraColours(vehicle))
            local primarycolor = colors[1]
            local secondarycolor = colors[2]
            local pearlescentcolor = extra_colors[1]
            local wheelcolor = extra_colors[2]

            if tostring(string.upper(plate)) == tostring(string.upper(immatricul)) then	
                SetEntityAsMissionEntity(vehicle, true, true)
                Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
                
                TriggerServerEvent('garages:SetVehIn', model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, vehicle, Config.getEmplacement, GetInfoGarage())
                TriggerEvent("NUI-Notification", {"Véhicule rentré !"})
            else
                TriggerServerEvent('garages:CheckDuplicationVeh', model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, vehicle, GetInfoGarage())
			end
        else
            TriggerEvent("NUI-Notification", {"Veuillez entrer dans un véhicule !", "warning"})
        end
	end)
end)

RegisterNetEvent('garages:StoreVehicleStolen')
AddEventHandler('garages:StoreVehicleStolen', function(plate)
    Citizen.CreateThread(function()
        Citizen.Wait(0)
		local playerPed  = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local immatricul = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)

        if IsPedInAnyVehicle(playerPed) then
            local colors = table.pack(GetVehicleColours(vehicle))
            local extra_colors = table.pack(GetVehicleExtraColours(vehicle))
            local primarycolor = colors[1]
            local secondarycolor = colors[2]
            local pearlescentcolor = extra_colors[1]
            local wheelcolor = extra_colors[2]
            TriggerServerEvent('garages:NewStolenCar', model, immatricul, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, vehicle, Config.getEmplacement, GetInfoGarage())
            TriggerEvent("NUI-Notification", {"Véhicule rentré !"})
        else
            TriggerEvent("NUI-Notification", {"Veuillez entrer dans un véhicule !", "warning"})
        end
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
            mainMenu:SetSubtitle("Emplacement : "..Config.getEmplacement.. "/".. max + 1)
            subVehiculeListSortir:SetSubtitle("Emplacement : "..Config.getEmplacement.. "/".. max + 1)
            RageUI.Visible(subVehiculeListSortir, true)
        end
    end
end

--> Si le joueur déco, on lui remet ses véhicule dans son garage a son spawn :
AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent("GTA_Garage:RefreshTableCles")
    TriggerServerEvent("garages:PutAllVehInGarages")
end)
