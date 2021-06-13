mainMenu = RageUI.CreateMenu("Garage",  "Emplacement Max : "..Config.getEmplacement .."\n")
subVehiculeListSortir =  RageUI.CreateSubMenu(mainMenu, "Garage", "Voici la liste de vos vehicule.")
local immatri = nil
local Duree = 0
Citizen.CreateThread(function()
    while (true) do
        RageUI.IsVisible(mainMenu, function()
            RageUI.Button('Ranger un véhicule dans votre garage', "", {}, true, {onSelected = function() TriggerServerEvent('garages:CheckForVeh', immatri) RageUI.CloseAll(true)end})
            RageUI.Button('Liste de vos véhicules', "", {}, true, {}, subVehiculeListSortir);
        end, function()end)
        RageUI.IsVisible(subVehiculeListSortir, function()
            for _, v in pairs(Config.vehicles_list_menu) do
                RageUI.List("~b~".. v.name .. "~g~ #" ..v.plaque .. " ~y~ "..v.state, {
                    { Name = "~b~Sortir~w~" },
                    { Name = "~h~Renomer~w~" },
                    { Name = "~h~Créer une clé~w~" },
                }, v.index or 1, "", {}, true, {
                    onListChange = function(Index, Item)
                        v.index = Index;
                    end,
                    onSelected = function(Index, Item)
                        if Index == 1 then 
                            TriggerServerEvent('garages:CheckForSpawnVeh', v.name, GetInfoGarage(), v.plaque)
                            RageUI.CloseAll(true)
                        elseif Index == 2 then 
                            TriggerServerEvent('garages:RenameVeh', v.name, v.plaque)
                            RageUI.CloseAll(true)
                        elseif Index == 3 then 
                            TriggerServerEvent('garages:CreerNouvelCles', v.plaque)
                            RageUI.CloseAll(true)
                        end
                    end,
                })
            end
        end, function()end)
    Citizen.Wait(Duree)
    end
end)

Citizen.CreateThread(function()
    while true do
        Duree = 250
        for i = 1, #Config.Locations do
           local garagePos = Config.Locations[i]["GarageEntrer"]
           local zone = Config.Locations[i]["GarageEntrer"]["NomZone"]
           local max = Config.Locations[i]["GarageEntrer"]["MaxVeh"]
           local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
           local dist = GetDistanceBetweenCoords(plyCoords, garagePos["x"], garagePos["y"], garagePos["z"], true)

            if dist <= 5.0 then
                Duree = 0
            
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)    
                immatri = GetVehicleNumberPlateText(vehicle)
                
                if GetLastInputMethod(0) then
                   Ninja_Core__DisplayHelpAlert("~INPUT_PICKUP~ pour ~b~intéragir")
                else
                   Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_EXTRA_OPTION~ pour ~b~intéragir")
                end
           
                if (IsControlJustReleased(0, 38) or IsControlJustReleased(0, 214)) then 
                    TriggerServerEvent("garages:GetEmplacement", zone)
                    TriggerServerEvent('garages:GetVehiclesList', GetInfoGarage())
                    
                    Wait(250)

                    mainMenu.Title = zone
                    subVehiculeListSortir.Title = zone
                    mainMenu:SetSubtitle("Emplacement : "..Config.getEmplacement.. "/".. max + 1)
                    subVehiculeListSortir:SetSubtitle("Emplacement : "..Config.getEmplacement.. "/".. max + 1)
                    RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
                end
            elseif dist <= 15 then
                Duree = 0
                DrawMarker(25, garagePos["x"], garagePos["y"], garagePos["z"] - 0.1,0,0,0,0,0,0,3.0,3.0,0.1,84, 84, 84,200,0,0,0,0)
            end
        end

        if RageUI.Visible(mainMenu) == true or RageUI.Visible(subVehiculeListSortir) then 
            DisableControlAction(0, 140, true) --> DESACTIVER LA TOUCHE POUR PUNCH
            DisableControlAction(0, 172,true) --DESACTIVE CONTROLL HAUT  
        end

        for i = 1, #Config.pos_receler do
            local recelerPos = Config.pos_receler[i]["Receler"]
            local zone = Config.pos_receler[i]["Receler"]["NomZone"]
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = GetDistanceBetweenCoords(plyCoords, recelerPos["x"], recelerPos["y"], recelerPos["z"], true)

            local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)    
            local immatri = GetVehicleNumberPlateText(vehicle)

            if (dist <= 5.0) then 
                Duree = 0

                if GetLastInputMethod(0) then
                    Ninja_Core__DisplayHelpAlert("~INPUT_PICKUP~ pour ~b~intéragir")
                else
                    Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_EXTRA_OPTION~ pour ~b~intéragir")
                end
        
                if (IsControlJustReleased(0, 38) or IsControlJustReleased(0, 214)) then
                    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        TriggerServerEvent("GTA_Receler:RequestVenteVehicule", immatri, vehicle)
                    else
                        TriggerEvent("NUI-Notification", {"Veuillez entrer dans un véhicule !", "warning"})
                    end
                end
            elseif dist <= 15 then
                Duree = 0
                DrawMarker(25, recelerPos["x"], recelerPos["y"], recelerPos["z"] - 0.1,0,0,0,0,0,0,3.0,3.0,0.1,84, 84, 84,200,0,0,0,0)
            end
        end
       Citizen.Wait(Duree)
   end
end)


RegisterNetEvent("GTA_Garage:IsPlayerHaveCles")
AddEventHandler("GTA_Garage:IsPlayerHaveCles", function(VehId, bHaveKey)
    if (bHaveKey == true) then
        local lockStatus = GetVehicleDoorLockStatus(VehId)

        if lockStatus == 1 then
            SetVehicleDoorsLocked(VehId, 2)
            PlayVehicleDoorCloseSound(VehId, 1)
            TriggerEvent("NUI-Notification", {"Véhicule vérrouillé"})
        elseif lockStatus == 2 then
            SetVehicleDoorsLocked(VehId, 1)
            PlayVehicleDoorOpenSound(VehId, 0)
            TriggerEvent("NUI-Notification", {"Véhicule dévérrouillé"})
        end
    else
        TriggerEvent("NUI-Notification", {"Vous n'avez pas les clés de ce véhicule."})
    end
end)


RegisterNetEvent("GTA_Garage:IsPlayerHaveClesOutside")
AddEventHandler("GTA_Garage:IsPlayerHaveClesOutside", function(VehId, bHaveKey)
    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end

    if (bHaveKey == true) then
        local lockStatus = GetVehicleDoorLockStatus(VehId)
        if lockStatus == 1 then -- unlocked
            SetVehicleDoorsLocked(VehId, 2)
            PlayVehicleDoorCloseSound(VehId, 1)
            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
            TriggerEvent("NUI-Notification", {"Véhicule vérrouillé"})
        elseif lockStatus == 2 then -- locked
            SetVehicleDoorsLocked(VehId, 1)
            PlayVehicleDoorOpenSound(VehId, 0)
            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
            TriggerEvent("NUI-Notification", {"Véhicule dévérrouillé"})
        end
    else
        TriggerEvent("NUI-Notification", {"Vous n'avez pas les clés de ce véhicule."})
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if (IsControlJustReleased( 0, 303 )) and GetLastInputMethod( 0 ) then 
            local plr = GetPlayerPed(-1)
            local plrCoords = GetEntityCoords(plr, true)

            if(IsPedInAnyVehicle(plr, true))then
                local localVehId = GetVehiclePedIsIn(plr, false)
                local localVehPlate = GetVehicleNumberPlateText(localVehId)
                TriggerServerEvent("GTA_Garage:RequestPlayerCles", localVehId, localVehPlate)
            else
                local vehicle = GetClosestVehicle(plrCoords['x'], plrCoords['y'], plrCoords['z'], 5.9, 0, 70) --> Work fine.
                local localVehPlate = GetVehicleNumberPlateText(vehicle)
               
                if DoesEntityExist(vehicle) then
                    if (localVehPlate ~= nil) then
                        TriggerServerEvent("GTA_Garage:RequestPlayerClesOutside", vehicle, localVehPlate)
                    end
                else
                    TriggerEvent("NUI-Notification", {"Aucun véhicule trouvé proche de vous.", "warning"})
                end
            end
            Citizen.Wait(1000)
        end
    end
end)