local menuConfig = json.decode(LoadResourceFile(GetCurrentResourceName(), 'json/ConfigMenu.json'))

local vehicles_list = {}
local vehicles_list_menu = {}
local vehicle_plate_list = {}
local concessionnaire = ""

local Ninja_Core__DisplayHelpAlert = function(msg)
	BeginTextCommandDisplayHelp("STRING");  
    AddTextComponentSubstringPlayerName(msg);  
    EndTextCommandDisplayHelp(0, 0, 1, -1);
end

local garage = {
	opened = false,
	title = "",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 1,
	marker = { r = 0, g = 155, b = 255, a = 200, type = 1 },
	menu = {
		x = 0.8 + 0.07,
		y = 0.05,
		width = 0.2 + 0.05,
		height = 0.04,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.4,
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

local fakecar = {model = '', car = nil}
local garage_locations = {
	{outside = {215.124, -791.377,29.936}, haveblip = true, handle = 0.0},
	{outside = {2061.7312011719, 3439.1110839844, 43.962757110596-1}, haveblip = true, handle = 0.0},
	{outside = {-141.89169311523, 6353.2626953125, 31.490631103516-1}, haveblip = true, handle = 0.0},
	{outside = {-462.576, -619.159, 31.1744-1}, haveblip = true, handle = 0.0},
}

local garage_blips ={}
local inrangeofgarage = false
local currentlocation = nil

local function LocalPed()
	return GetPlayerPed(-1)
end

function IsPlayerInRangeOfGarage()
	return inrangeofgarage
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

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
		Citizen.Wait(0)
		inrange = false
		for k, v in pairs(garage_locations) do
			if GetDistanceBetweenCoords(v.outside[1],v.outside[2],v.outside[3],GetEntityCoords(LocalPed())) < 5 then
				currentlocation = v
			end
			if v.haveblip then
				DrawMarker(25,v.outside[1],v.outside[2],v.outside[3],0,0,0,0,0,0,3.0,3.0,0.1,84, 84, 84,200,0,0,0,0)
				if GetDistanceBetweenCoords(v.outside[1],v.outside[2],v.outside[3],GetEntityCoords(LocalPed())) < 4 then
					if GetLastInputMethod(0) then
						Ninja_Core__DisplayHelpAlert("~INPUT_TALK~ pour accedez a votre ~b~garage")
					else
						Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_RIGHT~ accedez a votre ~b~garage")
					end
					currentlocation = v
					inrange = true
					concessionnaire = k
				end
			elseif concessionnaire == k and garage.opened == true and GetDistanceBetweenCoords(v.outside[1],v.outside[2],v.outside[3],GetEntityCoords(LocalPed())) > 3 then
				CloseCreator()
			end
			inrangeofgarage = inrange
		end
	end
end)

function LocalPed()
	return GetPlayerPed(-1)
end

function OpenCreator()
	local ped = LocalPed()
	local pos = currentlocation.outside
	local g = Citizen.InvokeNative(0xC906A7DAB05C8D2B,pos[1],pos[2],pos[3],Citizen.PointerValueFloat(),0)
	garage.currentmenu = "main"
	garage.opened = true
	garage.selectedbutton = 1
end

function CloseCreator()
	Citizen.CreateThread(function()
		garage.opened = false
		garage.menu.from = 1
		garage.menu.to = 10
	end)
end

function drawMenuButton(button,x,y,selected)
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

function drawMenuTitle(txt,x,y)
	local menu = garage.menu
	SetTextFont(0)
	SetTextScale(0.4 + 0.008, 0.4 + 0.008)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	for i=1, #menuConfig do 
		DrawRect(x,y,menu.width,menu.height, menuConfig[i].couleurTopMenu.r, menuConfig[i].couleurTopMenu.g, menuConfig[i].couleurTopMenu.b, menuConfig[i].couleurTopMenu.a)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end


function tablelength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end
	return count
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

local backlock = false
	Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
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
				drawMenuButton(button,garage.menu.x,y,selected)
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
			if IsControlJustReleased(1,202) then
				backlock = false
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
	end
end)


function round(num, idp)
	if idp and idp>0 then
		local mult = 10^idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end

function ButtonSelected(button)
	local ped = GetPlayerPed(-1)
	local this = garage.currentmenu
	local btn = button.name
	if this == "main" then
		if btn == "Rentrer mon véhicule" then
			TriggerServerEvent('garages:CheckForVeh',source)
		elseif btn == "Sortir un véhicule" then
			TriggerServerEvent('garages:GetVehiclesList',source)
			OpenMenu("garagepersonnel")
		elseif btn == "Renommer un véhicule" then
			TriggerServerEvent('garages:GetVehiclesList',source)
			OpenMenu("garagepersonnelRenomer")
		end
	elseif this == "garagepersonnel" then
		TriggerServerEvent('garages:CheckForSpawnVeh',btn)
	elseif this == "garagepersonnelRenomer" then
		TriggerServerEvent('garages:RenameVeh',btn)
	end
end

AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent("garages:PutVehInGarages",source)
end)


RegisterNetEvent('garages:FinishCheckForVeh')
AddEventHandler('FinishCheckForVeh', function(vehicle)
	CloseCreator(vehicle)
end)

function OpenMenu(menu)
	fakecar = {model = '', car = nil}
	garage.lastmenu = garage.currentmenu
	if menu == "vehicles" then
		garage.lastmenu = "main"
	elseif menu == "bikes"  then
		garage.lastmenu = "main"
	elseif menu == 'race_create_objects' then
		garage.lastmenu = "main"
	elseif menu == "race_create_objects_spawn" then
		garage.lastmenu = "race_create_objects"
	end
	garage.menu.from = 1
	garage.menu.to = 10
	garage.selectedbutton = 0
	garage.currentmenu = menu
end


function Back()
	if backlock then
		return
	end
	backlock = true
	if garage.currentmenu == "main" then
		CloseCreator()
	elseif garage.currentmenu == "garagepersonnel" then
		OpenMenu("main")
	elseif garage.currentmenu == "garagepersonnelRenomer" then
		OpenMenu("main")
	end
end

function stringstarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
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
end)

RegisterNetEvent('garages:SpawnVehicle')
AddEventHandler('garages:SpawnVehicle', function(state, model, plate, plateindex,colorprimary,colorsecondary,pearlescentcolor,wheelcolor,neoncolor1,neoncolor2,neoncolor3,windowtint,wheeltype,mods0,mods1,mods2,mods3,mods4,mods5,mods6,mods7,mods8,mods9,mods10,mods11,mods12,mods13,mods14,mods15,mods16,turbo,tiresmoke,xenon,mods23,mods24,neon0,neon1,neon2,neon3,bulletproof,smokecolor1,smokecolor2,smokecolor3,modvariation)
	local car = GetHashKey(model)
	local pos = currentlocation.outside
	Citizen.CreateThread(function()			
		Citizen.Wait(0)
		local caisseo = GetClosestVehicle(pos[1], pos[2], pos[3], 0, 70)
		if DoesEntityExist(caisseo) then
			drawNotification("La zone est encombrée") 
		else
			if state == "Sortit" then
				drawNotification("Ce véhicule n'est pas dans le garage")
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
				SetVehicleMod(veh, 0, tonumber(mods0))
				SetVehicleMod(veh, 1, tonumber(mods1))
				SetVehicleMod(veh, 2, tonumber(mods2))
				SetVehicleMod(veh, 3, tonumber(mods3))
				SetVehicleMod(veh, 4, tonumber(mods4))
				SetVehicleMod(veh, 5, tonumber(mods5))
				SetVehicleMod(veh, 6, tonumber(mods6))
				SetVehicleMod(veh, 7, tonumber(mods7))
				SetVehicleMod(veh, 8, tonumber(mods8))
				SetVehicleMod(veh, 9, tonumber(mods9))
				SetVehicleMod(veh, 10, tonumber(mods10))
				SetVehicleMod(veh, 11, tonumber(mods11))
				SetVehicleMod(veh, 12, tonumber(mods12))
				SetVehicleMod(veh, 13, tonumber(mods13))
				SetVehicleMod(veh, 14, tonumber(mods14))
				SetVehicleMod(veh, 15, tonumber(mods15))
				SetVehicleMod(veh, 16, tonumber(mods16))
				SetPedIntoVehicle(GetPlayerPed(-1), veh, -1)
				if turbo == "on" then
					ToggleVehicleMod(veh, 18, true)
				else
					ToggleVehicleMod(veh, 18, false)
				end
				if tiresmoke == "on" then
					ToggleVehicleMod(veh, 20, true)
				else
					ToggleVehicleMod(veh, 20, false)
				end
				if xenon == "on" then
					ToggleVehicleMod(veh, 22, true)
				else
					ToggleVehicleMod(veh, 22, false)
				end
					SetVehicleWheelType(veh, tonumber(wheeltype))
					SetVehicleMod(veh, 23, tonumber(mods23))
					SetVehicleMod(veh, 24, tonumber(mods24))
				if neon0 == "on" then
					SetVehicleNeonLightEnabled(veh,0, true)
				else
					SetVehicleNeonLightEnabled(veh,0, false)
				end
				if neon1 == "on" then
					SetVehicleNeonLightEnabled(veh,1, true)
				else
					SetVehicleNeonLightEnabled(veh,1, false)
				end
				if neon2 == "on" then
					SetVehicleNeonLightEnabled(veh,2, true)
				else
					SetVehicleNeonLightEnabled(veh,2, false)
				end
				if neon3 == "on" then
					SetVehicleNeonLightEnabled(veh,3, true)
				else
					SetVehicleNeonLightEnabled(veh,3, false)
				end
				if bulletproof == "on" then
					SetVehicleTyresCanBurst(veh, false)
				else
					SetVehicleTyresCanBurst(veh, true)
				end
				SetVehicleWindowTint(veh,tonumber(windowtint))
				SetEntityInvincible(veh, false) 
				SetVehicleHasBeenOwnedByPlayer(veh, true)
				local id = NetworkGetNetworkIdFromEntity(veh)
				SetNetworkIdCanMigrate(id, true)
				drawNotification("Véhicule sorti, bonne route")				
				TriggerServerEvent('garages:SetVehOut', model)
			end   
			CloseCreator()
		end
	end)
end)

local function SaisitText(actualtext, max)
    local text = ""
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TTTIP8", "", actualtext, "", "", "", max)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(10)
    end
    if (GetOnscreenKeyboardResult()) then
        text = GetOnscreenKeyboardResult()
    end
    return text
end

RegisterNetEvent('garages:RenomerVeh')
AddEventHandler('garages:RenomerVeh', function(vehicle_name, model)
	local car = GetHashKey(model)
	local pos = currentlocation.outside
	Citizen.CreateThread(function()			
		Citizen.Wait(0)
		local caisseo = GetClosestVehicle(pos[1], pos[2], pos[3], 0, 70)
		if DoesEntityExist(caisseo) then
			drawNotification("La zone est encombrée") 
		else
			local newVehicleNom = SaisitText("", 25)
			TriggerServerEvent("garages:NewVehiculeName", newVehicleNom, model)
			CloseCreator()
		end
	end)
end)

function table.HasValue( t, val )
	for k, v in pairs( t ) do
		if ( v == val ) then return true end
	end
	return false
end


RegisterNetEvent('garages:StoreVehicle')
AddEventHandler('garages:StoreVehicle', function(plate_list)
	vehicle_plate_list = {}
	vehicle_plate_list = plate_list
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local pos = currentlocation.outside
		local veh = GetClosestVehicle(pos[1], pos[2], pos[3], 3.000, 0, 70)
		SetEntityAsMissionEntity(veh, true, true)		
		local platecaissei = GetVehicleNumberPlateText(veh)
		if DoesEntityExist(veh) then	
			for k, v in pairs (vehicle_plate_list) do
				if v == platecaissei then 
					local plate = v
				end
			end
			if not table.HasValue(vehicle_plate_list,platecaissei) then				
				drawNotification("Ce n'est pas ton véhicule")
			else
				SetEntityAsMissionEntity( veh, true, true )
				local colors = table.pack(GetVehicleColours(veh))
				local extra_colors = table.pack(GetVehicleExtraColours(veh))
				local neoncolor = table.pack(GetVehicleNeonLightsColour(veh))
				local mods = table.pack(GetVehicleMod(veh))
				local smokecolor = table.pack(GetVehicleTyreSmokeColor(veh))
				local plate = GetVehicleNumberPlateText(veh)
				local plateindex = GetVehicleNumberPlateTextIndex(veh)
				local colorprimary = colors[1]
				local colorsecondary = colors[2]
				local pearlescentcolor = extra_colors[1]
				local wheelcolor = extra_colors[2]
				local neoncolor1 = neoncolor[1]
				local neoncolor2 = neoncolor[2]
				local neoncolor3 = neoncolor[3]
				local windowtint = GetVehicleWindowTint(veh)
				local wheeltype = GetVehicleWheelType(veh)
				local smokecolor1 = smokecolor[1]
				local smokecolor2 = smokecolor[2]
				local smokecolor3 = smokecolor[3]
				local mods0 = GetVehicleMod(veh, 0)
				local mods1 = GetVehicleMod(veh, 1)
				local mods2 = GetVehicleMod(veh, 2)
				local mods3 = GetVehicleMod(veh, 3)
				local mods4 = GetVehicleMod(veh, 4)
				local mods5 = GetVehicleMod(veh, 5)
				local mods6 = GetVehicleMod(veh, 6)
				local mods7 = GetVehicleMod(veh, 7)
				local mods8 = GetVehicleMod(veh, 8)
				local mods9 = GetVehicleMod(veh, 9)
				local mods10 = GetVehicleMod(veh, 10)
				local mods11 = GetVehicleMod(veh, 11)
				local mods12 = GetVehicleMod(veh, 12)
				local mods13 = GetVehicleMod(veh, 13)
				local mods14 = GetVehicleMod(veh, 14)
				local mods15 = GetVehicleMod(veh, 15)
				local mods16 = GetVehicleMod(veh, 16)
				local mods23 = GetVehicleMod(veh, 23)
				local mods24 = GetVehicleMod(veh, 24)
				if IsToggleModOn(veh,18) then
					turbo = "on"
				else
					turbo = "off"
				end
				if IsToggleModOn(veh,20) then
					tiresmoke = "on"
				else
					tiresmoke = "off"
				end
				if IsToggleModOn(veh,22) then
					xenon = "on"
				else
					xenon = "off"
				end
				if IsVehicleNeonLightEnabled(veh,0) then
					neon0 = "on"
				else
					neon0 = "off"
				end
				if IsVehicleNeonLightEnabled(veh,1) then
					neon1 = "on"
				else
					neon1 = "off"
				end
				if IsVehicleNeonLightEnabled(veh,2) then
					neon2 = "on"
				else
					neon2 = "off"
				end
				if IsVehicleNeonLightEnabled(veh,3) then
					neon3 = "on"
				else
					neon3 = "off"
				end
				if GetVehicleTyresCanBurst(veh) then
					bulletproof = "off"
				else
					bulletproof = "on"
				end
				if GetVehicleModVariation(veh,23) then
					modvariation = "on"
				else
					modvariation = "off"
				end
				TriggerServerEvent("ply_garages2:UpdateVeh", plate, plateindex,colorprimary,colorsecondary,pearlescentcolor,wheelcolor,neoncolor1,neoncolor2,neoncolor3,windowtint,wheeltype,mods0,mods1,mods2,mods3,mods4,mods5,mods6,mods7,mods8,mods9,mods10,mods11,mods12,mods13,mods14,mods15,mods16,turbo,tiresmoke,xenon,mods23,mods24,neon0,neon1,neon2,neon3,bulletproof,smokecolor1,smokecolor2,smokecolor3,modvariation)
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
				drawNotification("Véhicule rentré")
				TriggerServerEvent('garages:SetVehIn', platecaissei)
			end
		else
			drawNotification("Aucun véhicule n'est sur la zone.")
		end   
		CloseCreator()
	end)
end)