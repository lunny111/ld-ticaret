PantCore = nil
TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)


RegisterServerEvent("ld-ticaret:give-item")
AddEventHandler("ld-ticaret:give-item", function(item, miktar)
    print(item, miktar)
    local xPlayer = PantCore.Functions.GetPlayer(source)
    local itemcount = xPlayer.Functions.GetItemByName(item)
    print(json.encode(itemcount))
    if  itemcount ~= nil then
    if itemcount.amount >= miktar then
    xPlayer.Functions.RemoveItem(item, miktar)
    TriggerClientEvent('inventory:client:ItemBox', xPlayer.PlayerData.source, PantCore.Shared.Items[item], "remove", miktar)
    xPlayer.Functions.AddItem("ticaretm", 1)
    TriggerClientEvent('inventory:client:ItemBox', xPlayer.PlayerData.source, PantCore.Shared.Items['ticaretm'], "add", 1)
else
    TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Yeteri kadar yok.', "error")
end
else
    TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Yeteri kadar yok.', "error")
end
end)

-- sikemkoddüzenini
RegisterServerEvent("ld-ticaret:give-money")
AddEventHandler("ld-ticaret:give-money",function(a, b, c, d)
    local pl = PantCore.Functions.GetPlayer(source)
    if c == "arac" then
        if pl.Functions.GetItemByName("ticaretm") ~= nil then
            if pl.Functions.GetItemByName("ticaretm").amount >= 10 then
                if b == "kolay" then
            pl.Functions.AddMoney("cash", 3000)
            pl.Functions.RemoveItem("ticaretm", 10)
            TriggerClientEvent('inventory:client:ItemBox', pl.PlayerData.source, PantCore.Shared.Items['ticaretm'], "remove", 10)
        end
     if b == "orta" then
         print("2")
        pl.Functions.AddMoney("cash", 4000)
        plpl.Functions.RemoveItem("ticaretm", 10)
        TriggerClientEvent('inventory:client:ItemBox', pl.PlayerData.source, PantCore.Shared.Items['ticaretm'], "remove", 10)
     end
        if b == "zor" then
            print("3")
            pl.Functions.AddMoney("cash", 5000)
            pl.Functions.RemoveItem("ticaretm", 10)
            TriggerClientEvent('inventory:client:ItemBox', pl.PlayerData.source, PantCore.Shared.Items['ticaretm'], "remove", 10)
        end
    else
        TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Bi zeki sen değilsin', "error")  
    end  
else
    TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Bi zeki sen değilsin', "error")       
end
        else 
        if c == "tekne" then
            if pl.Functions.GetItemByName("ticaretm") ~= nil then
                if pl.Functions.GetItemByName("ticaretm").amount >= 50 then 
                    pl.Functions.AddMoney("cash", 100000)
                    pl.Functions.RemoveItem("ticaretm", 50)
                    TriggerClientEvent('inventory:client:ItemBox', pl.PlayerData.source, PantCore.Shared.Items['ticaretm'], "remove", 50)
        else
            TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Bi zeki sen değilsin', "error")       
        end
    else
        TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Bi zeki sen değilsin', "error")  
    end  
end
    end
end)

local NextTicaret = 7220
local lastTicaret = 0

PantCore.Functions.CreateCallback('ld-ticaret:time-control', function(source, cb)
    local xPlayer = PantCore.Functions.GetPlayer(source)
    if (os.time() - lastTicaret) < NextTicaret and lastTicaret ~= 0 then
        local seconds = NextTicaret - (os.time() - lastTicaret)
       
        TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'Yeniden ticaret yapmak için şu kadar beklemen gerek: ' .. math.floor(seconds / 60) .. ' dakika.', "error")
        cb(false)
    else
        lastTicaret = os.time()
        print(lastTicaret)
        cb(true)
    end
end)

PantCore.Functions.CreateCallback('ld-ticaret:check-item', function(source, cb)
	local ply = PantCore.Functions.GetPlayer(source)
	local item = ply.Functions.GetItemByName("ticaretm")

	if item ~= nil then 
		cb(item.amount)
	else
		cb(0)
	end
end)

RegisterServerEvent("ld-ticaret:illegal-bildirim")
AddEventHandler("ld-ticaret:illegal-bildirim", function(message)

    TriggerClientEvent("ld-ticaret:client:illegal-bildirim", message)
end)