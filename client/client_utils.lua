--> Function : 
Ninja_Core__DisplayHelpAlert = function(msg)
	BeginTextCommandDisplayHelp("STRING");  
    AddTextComponentSubstringPlayerName(msg);  
    EndTextCommandDisplayHelp(0, 0, 1, -1);
end

function GetLocalPed()
    return GetPlayerPed(PlayerId())
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function GetVehicleNearOfMe()
    local lPed = GetLocalPed()
    local lPedCoords = GetEntityCoords(lPed, alive)
    local lPedOffset = GetOffsetFromEntityInWorldCoords(lPed, 0.0, 3.0, 0.0)
    local rayHandle = StartShapeTestCapsule(lPedCoords.x, lPedCoords.y, lPedCoords.z, lPedOffset.x, lPedOffset.y, lPedOffset.z, 1.2, 10, lPed, 7)
    local returnValue, hit, endcoords, surface, vehicle = GetShapeTestResult(rayHandle)

    if hit then
        return vehicle
    else
        return false
    end
end

function InputText()
    local text = ""
    
	AddTextEntry('text', "Nouveau nom : ")
    DisplayOnscreenKeyboard(1, "text", "", "", "", "", "", 20)

    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(10)
    end

    if (GetOnscreenKeyboardResult()) then
        text = GetOnscreenKeyboardResult()
    end

    return text
end

Citizen.CreateThread(function()
    for i = 1, #Config.Locations do
        local blip = Config.Locations[i]["GarageEntrer"]
        local blip_config = Config.Locations[i]["GarageEntrer"]

        blip = AddBlipForCoord(blip["x"], blip["y"], blip["z"])

        if blip_config["AfficherBlip"] == true then
            SetBlipSprite(blip, 357)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, 32)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blip_config["NomZone"])
            EndTextCommandSetBlipName(blip)
        else
            RemoveBlip(blip)
        end
    end
end)