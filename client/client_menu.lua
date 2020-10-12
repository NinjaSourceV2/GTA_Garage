mainMenu = RageUI.CreateMenu("Garage",  "Emplacement Max : "..getEmplacement .."\n")
subVehiculeListSortir =  RageUI.CreateSubMenu(mainMenu, "Garage", "Voici la liste de vos vehicule.")

local Duree = 0
Citizen.CreateThread(function()
    while (true) do
        RageUI.IsVisible(mainMenu, function()
            RageUI.Button('Ranger un véhicule dans votre garage', "", {}, true, {onSelected = function() TriggerServerEvent('garages:CheckForVeh', GetInfoGarage()) RageUI.CloseAll(true)end})
            RageUI.Button('Liste de vos véhicules', "", {}, true, {}, subVehiculeListSortir);
        end, function()end)
        RageUI.IsVisible(subVehiculeListSortir, function()
            for _, v in pairs(vehicles_list_menu) do
                RageUI.List("~b~".. v.name .. "~g~ #" ..v.plaque .. " ~y~ "..v.state, {
                    { Name = "~b~Sortir~w~" },
                    { Name = "~g~Renomer~w~" },
                    { Name = "~r~Supprimer~w~" },
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
                            TriggerServerEvent('garages:CheckForSpawnVeh', v.name, GetInfoGarage(), v.plaque)
                            TriggerServerEvent('garages:RemoveVehicule', v.plaque)
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
            
                if GetLastInputMethod(0) then
                   Ninja_Core__DisplayHelpAlert("~INPUT_PICKUP~ pour ~b~intéragir")
                else
                   Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_EXTRA_OPTION~ pour ~b~intéragir")
                end
           
                if (IsControlJustReleased(0, 38) or IsControlJustReleased(0, 214)) then 
                    TriggerServerEvent("garages:CheckVehiculeAntiDupli", GetInfoGarage())
                    TriggerServerEvent("garages:GetEmplacement", zone)
                    TriggerServerEvent('garages:GetVehiclesList', GetInfoGarage())
                    
                    Wait(250)

                    mainMenu.Title = zone
                    subVehiculeListSortir.Title = zone
                    mainMenu:SetSubtitle("Emplacement : "..getEmplacement.. "/".. max + 1)
                    subVehiculeListSortir:SetSubtitle("Emplacement : "..getEmplacement.. "/".. max + 1)
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
       Citizen.Wait(Duree)
   end
end)