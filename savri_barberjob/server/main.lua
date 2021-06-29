ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('Iz_barbershop:pay')
AddEventHandler('Iz_barbershop:pay', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeMoney(Config.Price)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid', ESX.Math.GroupDigits(Config.Price)))
end)

ESX.RegisterServerCallback('Iz_barbershop:checkMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.get('money') >= Config.Price)
	TriggerClientEvent('esx:showNotification', source, '~r~Vous êtes entrain de couper !')
end)



ESX.RegisterServerCallback('Iz_barbershop:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'barber', function(inventory)
    cb(inventory.items)
  end)

end)


RegisterServerEvent('Iz_barbershop:getStockItem')
AddEventHandler('Iz_barbershop:getStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'barber', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('Iz_barbershop:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)

RegisterServerEvent('Iz_barbershop:putStockItems')
AddEventHandler('Iz_barbershop:putStockItems', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'barber', function(inventory)

    local item = inventory.getItem(itemName)
    local playerItemCount = xPlayer.getInventoryItem(itemName).count

    if item.count >= 0 and count <= playerItemCount then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)

  end)

end)
------------------------------------------------------------------------------------------------------------------------ Target

RegisterServerEvent('Iz_barbershop:resetSkin')
AddEventHandler('Iz_barbershop:resetSkin', function(targetPlayerId)
TriggerClientEvent("Iz_barbershop:resetSkin", targetPlayerId)
end)




RegisterServerEvent('Iz_barbershop:save')
AddEventHandler('Iz_barbershop:save', function(targetServerId)
TriggerClientEvent('esx:showNotification', source, '~g~Vous avez fini la coupe, Bravo!')
TriggerClientEvent("Iz_barbershop:save", targetServerId)
end)




RegisterServerEvent('Iz_barbershop:setSkin')
AddEventHandler('Iz_barbershop:setSkin', function(skin, target)
_source = source
targetid = target
TriggerClientEvent("Iz_barbershop:setSkin", source, skin, target) -- _source
end)










RegisterServerEvent('Iz_barbershop:getSkin')
AddEventHandler('Iz_barbershop:getSkin', function(player)
target = player
_source = source
TriggerClientEvent("Iz_barbershop:getSkin", source, target)
end)

RegisterServerEvent('Iz_barbershop:change')
AddEventHandler('Iz_barbershop:change', function(targetPlayerId, name, value)
TriggerClientEvent("Iz_barbershop:change", targetPlayerId, name, value)
end)
