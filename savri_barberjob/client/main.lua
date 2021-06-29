local GUI = {}
GUI.Time = 0
local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local HasPaid = false
local name = nil
local value = nil

local PlayerData = {}

local skinBefore = {}

ESX = nil


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenShopMenu(targetServerId, skin)
	HasPaid = false
	OpenMenu(targetServerId, skin,function(data, menu)

		menu.close()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'shop_confirm',
			{
				css = 'coiffeur',
				title = _U('valid_purchase'),
				align = 'top-left',
				elements = {
					{label = _U('no'), value = 'no'},
					{label = _U('yes'), value = 'yes'}
				}
			},
			function(data, menu)
				menu.close()

				if data.current.value == 'yes' then

					ESX.TriggerServerCallback('Iz_barbershop:checkMoney', function(hasEnoughMoney)
						if hasEnoughMoney then
							RequestAnimDict("misshair_shop@barbers")
        while not HasAnimDictLoaded("misshair_shop@barbers") do
            Citizen.Wait(0)
        end
		local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	local prop_name = "p_cs_scissors_s"
	ciseau = CreateObject(GetHashKey(prop_name), x, y, z,  true,  true, true)
	AttachEntityToEntity(ciseau, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 28422), -0.0, 0.03, 0, 0, -270.0, -20.0, true, true, false, true, 1, true)
	
		TaskPlayAnim(GetPlayerPed(-1), "misshair_shop@barbers", "keeper_idle_b", 8.0, 8.0, 15000, 0, 0, -1, -1, -1)
		Wait(10500)
		DeleteObject(ciseau)
	DetachEntity(ciseau, 1, true)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	ClearPedSecondaryTask(GetPlayerPed(-1))
							TriggerServerEvent("Iz_barbershop:save", targetServerId)
							--TriggerServerEvent('Iz_barbershop:pay')

							HasPaid = true
						else
							ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
								TriggerEvent('skinchanger:loadSkin', skin) 
							end)

							ESX.ShowNotification(_U('not_enough_money'))
						end
					end)

				elseif data.current.value == 'no' then

					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
						TriggerEvent('skinchanger:loadSkin', skin) 
					end)

				end

				CurrentAction = 'shop_menu'
				CurrentActionMsg = _U('press_access')
				CurrentActionData = {}
			end, function(data, menu)
				menu.close()

				CurrentAction = 'shop_menu'
				CurrentActionMsg = _U('press_access')
				CurrentActionData = {}
			end)

	end, function(data, menu)
			menu.close()

			CurrentAction = 'shop_menu'
			CurrentActionMsg = _U('press_access')
			CurrentActionData = {}
	end, getLimitationByGrade())

end

AddEventHandler('Iz_barbershop:hasEnteredMarker', function(zone)
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('press_access')
	CurrentActionData = {}
end)

AddEventHandler('Iz_barbershop:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil

	if not HasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin) 
		end)
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for i=1, #Config.Shops, 1 do
		local blip = AddBlipForCoord(Config.Shops[i].x, Config.Shops[i].y, Config.Shops[i].z)

		SetBlipSprite(blip, 71)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.7)
		SetBlipColour(blip, 51)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('barber_blip'))
		EndTextCommandSetBlipName(blip)

	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end


		if(PlayerData.job and PlayerData.job.name == "barber") then
			for k,v in pairs(Config.Chests) do
				local distance = GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true)
				if(distance < Config.DrawDistance) then
				DrawMarker(27, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				
				
					if(distance < 2.0) then
						ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au coffre.")

						if(IsControlJustPressed(1, 38)) then
							OpenBarberActionsMenu()
						end
					end
				
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(200)

		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x then
				isInMarker = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone = currentZone
			TriggerEvent('Iz_barbershop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('Iz_barbershop:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 167) then
			if(PlayerData.job and PlayerData.job.name == 'barber') then
				OpenMobileActionsMenu()
			end
		end
		
		if CurrentAction ~= nil and PlayerData.job and PlayerData.job.name == 'barber' then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					local player, distance = GetClosestPlayer()

					if(player ~= -1 and distance < 3.0) then
						TriggerServerEvent("Iz_barbershop:getSkin", player)
					else
						ESX.ShowNotification("Il n'y a personne autour.")
					end
					--OpenShopMenu()
				end

				CurrentAction = nil
			end
		end
	end
end)







function getLimitationByGrade()
	local limitations = {
		'beard_1',
		'beard_2',
		'beard_3',
		'beard_4'
	}


	if(PlayerData.job.grade_name ~= "barbier") then
		table.insert(limitations, 'hair_1')
		table.insert(limitations, 'hair_2')
		table.insert(limitations, 'hair_color_1')
		table.insert(limitations, 'hair_color_2')
		table.insert(limitations, 'eyebrows_1')
		table.insert(limitations, 'eyebrows_2')
		table.insert(limitations, 'eyebrows_3')
		table.insert(limitations, 'eyebrows_4')
	end

	if(PlayerData.job.grade_name == "boss") then
		table.insert(limitations, 'makeup_1')
		table.insert(limitations, 'makeup_2')
		table.insert(limitations, 'makeup_3')
		table.insert(limitations, 'makeup_4')
		table.insert(limitations, 'lipstick_1')
		table.insert(limitations, 'lipstick_2')
		table.insert(limitations, 'lipstick_3')
		table.insert(limitations, 'lipstick_4')
		table.insert(limitations, 'ears_1')
		table.insert(limitations, 'ears_2')
	end

	return limitations
end





function OpenMenu(targetPlayerId, skin, submitCb, cancelCb, restrict)
    local playerPed = PlayerPedId()


    TriggerEvent('skinchanger:getData', function(components, maxVals)
        local elements    = {}
        local _components = {}

        -- Restrict menu
        if restrict == nil then
            for i=1, #components, 1 do
                _components[i] = components[i]
            end
        else
            for i=1, #components, 1 do
                local found = false

                for j=1, #restrict, 1 do
                    if components[i].name == restrict[j] then
                        found = true
                    end
                end

                if found then
                    table.insert(_components, components[i])
                end
            end
        end

        -- Insert elements
        for i=1, #_components, 1 do
            local value       = _components[i].value
            local componentId = _components[i].componentId

            if componentId == 0 then
                value = GetPedPropIndex(playerPed, _components[i].componentId)
            end

            local data = {
                label     = _components[i].label,
                name      = _components[i].name,
                value     = value,
                min       = _components[i].min,
                textureof = _components[i].textureof,
                zoomOffset= _components[i].zoomOffset,
                camOffset = _components[i].camOffset,
                type      = 'slider'
            }

            for k,v in pairs(maxVals) do
                if k == _components[i].name then
                    data.max = v
                    break
                end
            end

            table.insert(elements, data)
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'skin', {
            title    = _U('skin_menu'),
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            --[[TriggerEvent('skinchanger:getSkin', function(skin)
                lastSkin = skin
            end)]]--

            submitCb(data, menu)
        end, function(data, menu)
            menu.close()
            --TriggerEvent('skinchanger:loadSkin', lastSkin)
			TriggerServerEvent("Iz_barbershop:resetSkin", targetPlayerId)
            if cancelCb ~= nil then
                cancelCb(data, menu)
            end
        end, function(data, menu)
            local components, maxVals

            --[[TriggerEvent('skinchanger:getSkin', function(getSkin)
                skin = getSkin
            end)]]

            if skin[data.current.name] ~= data.current.value then
                -- Change skin element
                --TriggerEvent('skinchanger:change', data.current.name, data.current.value)
				name = data.current.name
				value = data.current.value
				TriggerServerEvent("Iz_barbershop:change", targetPlayerId, name, value)
                -- Update max values
                TriggerEvent('skinchanger:getData', function(comp, max)
                    components, maxVals = comp, max
                end)

                local newData = {}

                for i=1, #elements, 1 do
                    newData = {}
                    newData.max = maxVals[elements[i].name]

                    if elements[i].textureof ~= nil and data.current.name == elements[i].textureof then
                        newData.value = 0
                    end

                    menu.update({name = elements[i].name}, newData)
                end

                menu.refresh()
            end
        end, function(data, menu)
        end)
    end)
end




function GetClosestPlayer()
	local player = -1
	local minDistance = 1000.0
  
	local myCoords = GetEntityCoords(PlayerPedId())
	for _, id in pairs(GetActivePlayers()) do
	  if(id ~= PlayerId()) then
		local ped = GetPlayerPed(id)
		local coords = GetEntityCoords(ped)
		local distance = #(myCoords-coords)
  
		if(distance < minDistance) then
		  minDistance = distance
		  player = GetPlayerServerId(id)
		end
	  end
	end
  
	return player, minDistance
end
  





RegisterNetEvent("Iz_barbershop:setSkin")
AddEventHandler("Iz_barbershop:setSkin", function(skin, target)
	OpenShopMenu(target, skin)
end)


RegisterNetEvent("Iz_barbershop:resetSkin")
AddEventHandler("Iz_barbershop:resetSkin", function()
	TriggerEvent('skinchanger:loadSkin', skinBefore)
end)

RegisterNetEvent("Iz_barbershop:getSkin")
AddEventHandler("Iz_barbershop:getSkin", function(target)
	TriggerEvent('skinchanger:getSkin', function(skin)
		skinBefore = skin
		TriggerServerEvent('Iz_barbershop:setSkin', skin, target)
	end)
end)

RegisterNetEvent("Iz_barbershop:change")
AddEventHandler("Iz_barbershop:change", function(name, value)
	TriggerEvent('skinchanger:change', name, value)
end)


RegisterNetEvent("Iz_barbershop:save")
AddEventHandler("Iz_barbershop:save", function()
	TriggerEvent('skinchanger:getSkin', function(skin)
		TriggerServerEvent('esx_skin:save', skin)
	end)
end)
















function OpenBarberActionsMenu()

	local elements = {
	  --{label = _U('work_wear'), value = 'cloakroom'},
	  --{label = _U('civ_wear'), value = 'cloakroom2'},
	  {label = "Déposer Stock", value = 'put_stock'}
	}
	
	if PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss'  then 
	  table.insert(elements, {label = 'Prendre Stock', value = 'get_stock'})
	  table.insert(elements, {label = "Actions boss", value = 'boss_actions'})
	end
  
	ESX.UI.Menu.CloseAll()
  
	ESX.UI.Menu.Open(
	  'default', GetCurrentResourceName(), 'barber_actions',
	  {
		title    = "Coiffeur",
		elements = elements
	  },
	  function(data, menu)
  
		if data.current.value == 'put_stock' then
		  OpenPutStocksMenu()
		end
  
		if data.current.value == 'get_stock' then
		  OpenGetStocksMenu()
		end
		
		if data.current.value == 'boss_actions' then
		  TriggerEvent('esx_society:openBossMenu', 'barber', function(data, menu)
			menu.close()
		  end)
		end
  
	  end,
	  function(data, menu)
		menu.close()
		CurrentAction     = 'barber_actions_menu'
		CurrentActionMsg  = _U('open_actions')
		CurrentActionData = {}
	  end
	)
  end
  


  
function OpenGetStocksMenu()

	ESX.TriggerServerCallback('Iz_barbershop:getStockItems', function(items)
    
	  local elements = {}
  
	  for i=1, #items, 1 do
		table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
	  end
  
	  ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'stocks_menu',
		{
		  title    = "Coiffeur stock",
		  elements = elements
		},
		function(data, menu)
  
		  local itemName = data.current.value
  
		  ESX.UI.Menu.Open(
			'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
			{
			  title = "Quantité"
			},
			function(data2, menu2)
  
			  local count = tonumber(data2.value)
  
			  if count == nil then
				ESX.ShowNotification("Quantité invalide")
			  else
				menu2.close()
				menu.close()
				OpenGetStocksMenu()
  
				TriggerServerEvent('Iz_barbershop:getStockItem', itemName, count)
			  end
  
			end,
			function(data2, menu2)
			  menu2.close()
			end
		  )
  
		end,
		function(data, menu)
		  menu.close()
		end
	  )
  
	end)
  
  end
  
  function OpenPutStocksMenu()
  
  ESX.TriggerServerCallback('Iz_barbershop:getPlayerInventory', function(inventory)
  
	  local elements = {}
  
	  for i=1, #inventory.items, 1 do
  
		local item = inventory.items[i]
  
		if item.count > 0 then
		  table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
		end
  
	  end
  
	  ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'stocks_menu',
		{
		  title    = "Inventaire",
		  elements = elements
		},
		function(data, menu)
  
		  local itemName = data.current.value
  
		  ESX.UI.Menu.Open(
			'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
			{
			  title = "Quantité"
			},
			function(data2, menu2)
  
			  local count = tonumber(data2.value)
  
			  if count == nil then
				ESX.ShowNotification("Quantité invalide")
			  else
				menu2.close()
				menu.close()
				OpenPutStocksMenu()
  
				TriggerServerEvent('Iz_barbershop:putStockItems', itemName, count)
			  end
  
			end,
			function(data2, menu2)
			  menu2.close()
			end
		  )
  
		end,
		function(data, menu)
		  menu.close()
		end
	  )
  
	end)
  
  end