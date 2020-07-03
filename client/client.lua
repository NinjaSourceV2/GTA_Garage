local menuConfig = json.decode(LoadResourceFile(GetCurrentResourceName(), 'json/ConfigMenu.json'))

local vehicles_list = {}
local vehicles_list_menu = {}
local vehicle_plate_list = {}
local scaleform = nil
local DUREE = 0
local personnelVeh = false
local isPortesVerr = false

local garage_locations = {
	{outside = {215.124, -791.377,29.936}, haveblip = true, handle = 0.0},
	{outside = {2061.7312011719, 3439.1110839844, 43.962757110596-1}, haveblip = true, handle = 0.0},
	{outside = {-141.89169311523, 6353.2626953125, 31.490631103516-1}, haveblip = true, handle = 0.0},
	{outside = {-462.576, -619.159, 31.2744-1}, haveblip = true, handle = 0.0},
}

local garage_blips ={}
local inrangeofgarage = false
local currentlocation = nil

local garage = {
	opened = false,
	title = "",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 1,
	marker = { r = 0, g = 155, b = 255, a = 200, type = 1 },
	menu = {
		x = 0.1 + 0.03,
		y = 0.0 + 0.03,
		width = 0.2 + 0.02 + 0.005,
		height = 0.04,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.3 + 0.05, --> Taille.
		font = 0,
		["main"] = {
			title = "GARAGE PERSONNEL",
			name = "main",
			buttons = {
				{name = "Rentrer mon véhicule", description = "", action = "rentrer"},
				{name = "Sortir un véhicule", description = "", action = "sortir"},
				{name = "Renommer un véhicule", description = "", action = "rename"},
			}
    	},
		["garagepersonnel"] = {
			title = "GARAGE PERSONNEL",
			name = "garagepersonnel",
			buttons = vehicles_list_menu
		},
		
		["garagepersonnelRenomer"] = {
			title = "GARAGE PERSONNEL",
			name = "garagepersonnelRenomer",
			buttons = vehicles_list_menu
    	},
  	}
}

local Ninja_Core__DisplayHelpAlert = function(msg)
	BeginTextCommandDisplayHelp("STRING");  
    AddTextComponentSubstringPlayerName(msg);  
    EndTextCommandDisplayHelp(0, 0, 1, -1);
end

local function GetLocalPed()
    return GetPlayerPed(PlayerId())
end


local function LocalPed()
	return GetPlayerPed(-1)
end

local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

local function isCarBlacklisted(model)
	for _, blacklistedCar in pairs(Config.Blacklist) do
		if model == GetHashKey(blacklistedCar) then
			return true
		end
	end

	return false
end

local function InputText()
	local text = ""
	AddTextEntry('text', "Nouveau nom :")
    DisplayOnscreenKeyboard(1, "text", "", "", "", "", "", 120)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(10)
    end
    if (GetOnscreenKeyboardResult()) then
        text = GetOnscreenKeyboardResult()
    end
    return text
end

local function GetVehicleNearOfMe()
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

local function IsPlayerInRangeOfGarage()
	return inrangeofgarage
end

local function OpenMenu(menu)
	garage.menu.from = 1
	garage.selectedbutton = 1
	garage.currentmenu = menu
end

local function tablelength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end
	return count
end


function table.HasValue(t,val)
	for k, v in pairs( t ) do
		if ( v == val ) then return true end
	end
	return false
end

local function OpenCreator()
	if not HasStreamedTextureDictLoaded("commonmenu") then
        RequestStreamedTextureDict("commonmenu", true)
	end
	
	scaleform = RequestScaleformMovie("mp_menu_glare")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
	end
	
	PushScaleformMovieFunction(scaleform, "initScreenLayout")
	PopScaleformMovieFunctionVoid()
	
	local ped = LocalPed()
	local pos = currentlocation.outside
	local g = Citizen.InvokeNative(0xC906A7DAB05C8D2B,pos[1],pos[2],pos[3],Citizen.PointerValueFloat(),0)
	garage.currentmenu = "main"
	garage.opened = true
	garage.selectedbutton = 1
end

local function CloseCreator()
	Citizen.CreateThread(function()
		garage.opened = false
		garage.menu.from = 1
		garage.menu.to = 10
	end)
end

local function drawMenuButton(button,x,y,selected)
	local menu = garage.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)

	for i=1, #menuConfig do 
		if selected then
			SetTextColour(menuConfig[i].couleurTextSelectMenu.r, menuConfig[i].couleurTextSelectMenu.g, menuConfig[i].couleurTextSelectMenu.b, menuConfig[i].couleurTextSelectMenu.a)
		else
			SetTextColour(menuConfig[i].couleurTextMenu.r, menuConfig[i].couleurTextMenu.g, menuConfig[i].couleurTextMenu.b, menuConfig[i].couleurTextMenu.a)
		end

		if selected then
			DrawRect(x,y,menu.width,menu.height,menuConfig[i].couleurRectSelectMenu.r,menuConfig[i].couleurRectSelectMenu.g,menuConfig[i].couleurRectSelectMenu.b,menuConfig[i].couleurRectSelectMenu.a)
		else
			DrawRect(x,y,menu.width,menu.height,0,0,0,150)
		end
	end

	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

local function DrawTextMenu(fonteP, stringT, scale, posX, posY)
    SetTextFont(fonteP)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(stringT)
    DrawText(posX, posY)
end


local function drawMenuTitle(txt,x,y)
	local menu = garage.menu
	SetTextFont(0)
	SetTextScale(0.4 + 0.008, 0.4 + 0.008)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	for i=1, #menuConfig do 
		DrawRect(x,y,menu.width,menu.height, menuConfig[i].couleurTopMenu.r, menuConfig[i].couleurTopMenu.g, menuConfig[i].couleurTopMenu.b, menuConfig[i].couleurTopMenu.a)
	end
	DrawTextMenu(1, txt, 0.8,menu.width - 0.4 / 2 + 0.1 + 0.005, y - menu.height/2 + 0.01, 255, 255, 255)
    DrawSprite("commonmenu", "interaction_bgd", x,y, menu.width,menu.height + 0.04 + 0.007, .0, 255, 255, 255, 255)
    DrawScaleformMovie(scaleform, 0.42 + 0.003,0.45, 0.9,0.9)
end

function ButtonSelected(button)
	local ped = GetPlayerPed(-1)
	local this = garage.currentmenu
	local btn = button.name
	if this == "main" then
		if btn == "Rentrer mon véhicule" then
			TriggerServerEvent('garages:CheckForVeh')
		elseif btn == "Sortir un véhicule" then
			TriggerServerEvent('garages:GetVehiclesList')
		elseif btn == "Renommer un véhicule" then
			TriggerServerEvent('garages:GetVehiclesList2')
		end
	elseif this == "garagepersonnel" then
		TriggerServerEvent('garages:CheckForSpawnVeh',btn)
	elseif this == "garagepersonnelRenomer" then
		TriggerServerEvent('garages:RenameVeh',btn)
	end
end

function Back()
	if garage.currentmenu == "main" then
		CloseCreator()
	elseif garage.currentmenu == "garagepersonnel" then
		OpenMenu("main")
	elseif garage.currentmenu == "garagepersonnelRenomer" then
		OpenMenu("main")
	end
end

RegisterNetEvent('garages:GetVehiclesListClient')
AddEventHandler('garages:GetVehiclesListClient', function(vehicles)
	vehicles_list = {}
	vehicles_list = vehicles
	for k,v in pairs(vehicles_list_menu) do
		vehicles_list_menu[k] = nil
	end
	for k, v in pairs (vehicles_list) do
		table.insert(vehicles_list_menu, {name = v})
	end
	OpenMenu("garagepersonnel")
end)

RegisterNetEvent('garages:GetVehiclesListClient2')
AddEventHandler('garages:GetVehiclesListClient2', function(vehicles)
	vehicles_list = {}
	vehicles_list = vehicles
	for k,v in pairs(vehicles_list_menu) do
		vehicles_list_menu[k] = nil
	end
	for k, v in pairs (vehicles_list) do
		table.insert(vehicles_list_menu, {name = v})
	end
	OpenMenu("garagepersonnelRenomer")
end)



RegisterNetEvent('garages:SpawnVehicle')
AddEventHandler('garages:SpawnVehicle', function(state, model, plate, plateindex,colorprimary,colorsecondary,pearlescentcolor,wheelcolor)
	local car = GetHashKey(model)
	local pos = currentlocation.outside
	Citizen.CreateThread(function()			
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local playerPos = GetEntityCoords(player, 1)
		local VehPos = GetOffsetFromEntityInWorldCoords(player, 0.0,20.0, 0.0)
		local targetVehicle = getVehicleInDirection(playerPos, VehPos)


		if DoesEntityExist(targetVehicle) then
			exports.nCoreGTA:nNotificationMain({
				text = "La zone est encombrée",
				type = 'basGauche',
				nTimeNotif = 1000,
			})
		else
			if state == "Sortit" then
				exports.nCoreGTA:nNotificationMain({
					text = "Ce véhicule n'est pas dans le garage",
					type = 'basGauche',
					nTimeNotif = 1000,
				})
			else
				RequestModel(car)
				while not HasModelLoaded(car) do
					Citizen.Wait(0)
				end
				veh = CreateVehicle(car, pos[1], pos[2], pos[3], currentlocation.handle, true, false)
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
				
				exports.nCoreGTA:nNotificationMain({
					text = "Véhicule sorti, bonne route",
					type = 'basGauche',
					nTimeNotif = 1000,
				})

				TriggerServerEvent('garages:SetVehOut', model)
				print(veh)
				TriggerEvent('garages:SetVehiculePerso', veh)
			end   
			CloseCreator()
		end
	end)
end)

RegisterNetEvent('garages:SetVehiculePerso')
AddEventHandler('garages:SetVehiculePerso', function(vehicle)
    personnelVeh = vehicle
end)

RegisterNetEvent('garages:togglePortes')
AddEventHandler('garages:togglePortes', function()
	local playerPed = LocalPed()
	local vehicle = GetVehiclePedIsIn(playerPed)
	
	if personnelVeh ~= false then
        local playerPos = GetEntityCoords(LocalPed(), true)
        local personalVehiclePos = GetEntityCoords(personnelVeh, true)
        if (Vdist(playerPos.x, playerPos.y, playerPos.z, personalVehiclePos.x, personalVehiclePos.y, personalVehiclePos.z) < 15.0) then
			local locked = GetVehicleDoorLockStatus(personnelVeh)
			if (locked == 1 or locked == 0) then
				if not IsPedInAnyVehicle(playerPed) then
					local dict = "anim@mp_player_intmenu@key_fob@"

					RequestAnimDict(dict)

					while not HasAnimDictLoaded(dict) do
						Citizen.Wait(0)
					end	

					vehCles = CreateObject(GetHashKey("prop_cuff_keys_01"), 0, 0, 0, true, true, true)
					AttachEntityToEntity(vehCles, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
					TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

					Wait(500)
				
					SetVehicleDoorsLocked(personnelVeh, 2)
					exports.nCoreGTA:nNotificationMain({
						text = "Portes ~r~verrouillée~w~.",
						type = 'basGauche',
						nTimeNotif = 1000,
					})

					Wait(1000)
					DeleteEntity(vehCles)
				else
					isPortesVerr = true
					SetVehicleDoorsLocked(personnelVeh, 2)
					PlayVehicleDoorOpenSound(vehicle,0)
					exports.nCoreGTA:nNotificationMain({
						text = "Portes ~r~verrouillée~w~.",
						type = 'basGauche',
						nTimeNotif = 1000,
					})
				end
			else
				if not IsPedInAnyVehicle(playerPed) then
					local dict = "anim@mp_player_intmenu@key_fob@"

					RequestAnimDict(dict)

					while not HasAnimDictLoaded(dict) do
						Citizen.Wait(0)
					end	

					vehCles = CreateObject(GetHashKey("prop_cuff_keys_01"), 0, 0, 0, true, true, true)
					AttachEntityToEntity(vehCles, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.03, -0.03, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
					TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
					SetVehicleDoorsLocked(personnelVeh, 1)
					exports.nCoreGTA:nNotificationMain({
						text = "Portes ~g~déverrouillée~w~.",
						type = 'basGauche',
						nTimeNotif = 1000,
					})
					Wait(1000)
					DeleteEntity(vehCles)
				else
					isPortesVerr = false
					PlayVehicleDoorOpenSound(vehicle,0)
					SetVehicleDoorsLocked(personnelVeh, 1)
					exports.nCoreGTA:nNotificationMain({
						text = "Portes ~g~déverrouillée~w~.",
						type = 'basGauche',
						nTimeNotif = 1000,
					})
				end
			end
		end
	end
end)

RegisterNetEvent('garages:RenomerVeh')
AddEventHandler('garages:RenomerVeh', function(vehicle_name, model)
	local car = GetHashKey(model)
	local pos = currentlocation.outside
	Citizen.CreateThread(function()
		Citizen.Wait(0)
		local playerPos = GetEntityCoords(GetPlayerPed(-1), 1)
		local VehPos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)
		local targetVehicle = getVehicleInDirection(playerPos, VehPos)
		if DoesEntityExist(targetVehicle) then
			exports.nCoreGTA:nNotificationMain({
				text = "~y~ La zone est encombrée !",
				type = 'basGauche',
				nTimeNotif = 1000,
			})
		else
			local newVehicleNom = InputText()
			TriggerServerEvent("garages:NewVehiculeName", newVehicleNom, model)
			CloseCreator()
		end
	end)
end)



RegisterNetEvent('garages:StoreVehicle')
AddEventHandler('garages:StoreVehicle', function(plate_list)
	vehicle_plate_list = {}
	vehicle_plate_list = plate_list
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local playerPed  = GetPlayerPed(-1)
		local veh = GetVehicleNearOfMe()
		local playerPos = GetEntityCoords(playerPed, 1)
		local VehPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 20.0, 0.0)
		local targetVehicle = getVehicleInDirection(playerPos, VehPos)


		if targetVehicle ~= false then
			SetEntityAsMissionEntity(veh, true, true)		
			local platecaissei = GetVehicleNumberPlateText(veh)
			for k, v in pairs (vehicle_plate_list) do
				if v == platecaissei then 
					local plate = v
				end
			end
			if not table.HasValue(vehicle_plate_list,platecaissei) then				
				exports.nCoreGTA:nNotificationMain({
					text = "~y~ Ce n'est pas ton véhicule !",
					type = 'basGauche',
					nTimeNotif = 1000,
				})
			else
				SetEntityAsMissionEntity( veh, true, true )
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
				exports.nCoreGTA:nNotificationMain({
					text = "~g~ Véhicule rentré !",
					type = 'basGauche',
					nTimeNotif = 1000,
				})
				TriggerServerEvent('garages:SetVehIn', platecaissei)
			end
		end

		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed)
			SetEntityAsMissionEntity(vehicle, true, true)		
			local platecaissei = GetVehicleNumberPlateText(vehicle)
			for k, v in pairs (vehicle_plate_list) do
				if v == platecaissei then 
					local plate = v
				end
			end
			if not table.HasValue(vehicle_plate_list,platecaissei) then
				exports.nCoreGTA:nNotificationMain({
					text = "~y~ Ce n'est pas ton véhicule !",
					type = 'basGauche',
					nTimeNotif = 1000,
				})
			else
				SetEntityAsMissionEntity( vehicle, true, true )
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
				exports.nCoreGTA:nNotificationMain({
					text = "~g~ Véhicule rentré !",
					type = 'basGauche',
					nTimeNotif = 1000,
				})
				TriggerServerEvent('garages:SetVehIn', platecaissei)
			end
		end
		CloseCreator()
	end)
end)


AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent("garages:PutVehInGarages")
end)


Citizen.CreateThread(function()
	while true do
		if (IsControlJustReleased(0, 54) or IsControlJustReleased(0, 175)) and IsPlayerInRangeOfGarage() then
			if not garage.opened then
				OpenCreator()
			end
		end

		if garage.opened then
			DisableControlAction(0, 140, true) --> DESACTIVER LA TOUCHE POUR PUNCH
			DisableControlAction(0, 172,true) --DESACTIVE CONTROLL HAUT
			local ped = LocalPed()
			local menu = garage.menu[garage.currentmenu]
			drawMenuTitle(menu.title, garage.menu.x,garage.menu.y + 0.08)
			local y = garage.menu.y + 0.12
			buttoncount = tablelength(menu.buttons)
			local selected = false
			for i,button in pairs(menu.buttons) do
				if i >= garage.menu.from and i <= garage.menu.to then
					if i == garage.selectedbutton then
						selected = true
					else
						selected = false
					end
				drawMenuButton(button,garage.menu.x,y + 0.02 + 0.003,selected)
				y = y + 0.04
					if selected and IsControlJustPressed(1,201) then
						PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						ButtonSelected(button)
					end
				end
			end
		end

		if garage.opened then

			if IsControlJustPressed(1,202) then
				Back()
			end

			if IsControlJustPressed(1,188) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				if garage.selectedbutton > 1 then
					garage.selectedbutton = garage.selectedbutton -1
					if buttoncount > 10 and garage.selectedbutton < garage.menu.from then
						garage.menu.from = garage.menu.from -1
						garage.menu.to = garage.menu.to - 1
					end
				end
			end

			if IsControlJustPressed(1,187)then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				if garage.selectedbutton < buttoncount then
					garage.selectedbutton = garage.selectedbutton +1
					if buttoncount > 10 and garage.selectedbutton > garage.menu.to then
						garage.menu.to = garage.menu.to + 1
						garage.menu.from = garage.menu.from + 1
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustReleased(0, 303) and GetLastInputMethod(0) then
			local playerPed = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(playerPed)
			local carModel = GetEntityModel(vehicle)

			if not isCarBlacklisted(carModel) then
				TriggerEvent("garages:togglePortes")
			else
				exports.nCoreGTA:nNotificationMain({
					text = "~y~Action Impossible.\nce type de véhicule ne peut être verrouiller.",
					type = 'basGauche',
					nTimeNotif = 3000,
				})
			end
		end

		if isPortesVerr then
			DisableControlAction(0, 75)
		end
	end
end)


Citizen.CreateThread(function()
	for k, v in pairs(garage_locations) do
		if v.haveblip then
			local blip = AddBlipForCoord(v.outside[1],v.outside[2],v.outside[3])
			SetBlipSprite(blip,357)
			SetBlipColour(blip, 3)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Garage')
			EndTextCommandSetBlipName(blip)
			SetBlipAsShortRange(blip,true)
			SetBlipAsMissionCreatorBlip(blip,true)
		end
	end
	while true do
		DUREE = 1000
		inrange = false
		for _, v in pairs(garage_locations) do
			if GetDistanceBetweenCoords(v.outside[1],v.outside[2],v.outside[3],GetEntityCoords(LocalPed())) < 5 then
				DUREE = 8
				currentlocation = v
			end
			if v.haveblip then
				DUREE = 8
				DrawMarker(25,v.outside[1],v.outside[2],v.outside[3] - 0.1,0,0,0,0,0,0,3.0,3.0,0.1,84, 84, 84,200,0,0,0,0)
				if GetDistanceBetweenCoords(v.outside[1],v.outside[2],v.outside[3],GetEntityCoords(LocalPed())) < 4 then
					if GetLastInputMethod(0) then
						Ninja_Core__DisplayHelpAlert("~INPUT_TALK~ pour accedez a votre ~b~garage")
					else
						Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_RIGHT~ accedez a votre ~b~garage")
					end
					currentlocation = v
					inrange = true
				end
			end
			inrangeofgarage = inrange
		end
		Citizen.Wait(DUREE)
	end
end)