-- Görev süreleri
local aracKolaySure = 2700
local aracOrtaSure = 2400
local aracZorSure = 2100
local tekneSure = 7200

-- başlamak için gereken ticaret malzemesi miktarı
local aracGerekenMiktar = 10
local tekneGerekenMiktar = 50

-- Göreb araçları
local kolayAracModel = "mule3"
local ortaAracModel = "benson"
local zorAracModel = "pounder2"
local tekneModel = "tug"

-- bildirim mesajları
local polisMesaj = "Legal Teslimat Görevi Başladı"
local illegalMesaj = "Deniz Ticareti Yapılıyor"

local jobCoords = { -- Teslimat Noktaları(Nekadar çok teslimat noktası varsa okadar çok para kazanılır)
    ["arac"] = { -- Araç Teslimat Noktaları
        vector3(985.86, -1821.09, 31.13),
        vector3(-390.57, -1877.02, 20.53),
        vector3(460.83, -585.69, 28.5),
        vector3(974.32, 5.38, 81.26),
        vector3(2594.36, 473.6, 108.46),
        vector3(347.42, 3412.28, 36.58),
        vector3(2926.3, 4636.06, 48.78),
        vector3(418.54, 6492.66, 28.17),
        vector3(-1196.0, -1485.54, 4.38),
        vector3(882.88, -1251.3, 26.18),
    },
    ["tekne"] = { -- Tekne Teslimat Noktaları
        vector3(-1851.44, -1260.62, 3.0),
        vector3(-3444.97, 960.99, 6.0),
        vector3(-302.4, 6652.80, 5.0),
    }
}

local items = { -- Ticaret Malzemesine çevrilebilecek eşyalar
    { item = "packaged_chicken", count = 9},
    { item = "talas", count = 10},
    { item = "sut", count = 14},
    { item = "portakalsuyu", count = 11},
    { item = "clothe", count = 14},
    { item = "wine", count = 7},
    { item = "kiyma", count = 17},
}

PantCore = nil
Citizen.CreateThread(function()
    while PantCore == nil do
        TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)
        Citizen.Wait(200)
    end
    createBlips()
   --[[  PlayerData = PantCore.Functions.GetPlayerData() -- Test Ederken Açılması lazım
    illegalPerm = PlayerData.metadata.illegalv2
    number = PlayerData.metadata.number ]]
end)

local boxCoords = vector3(918.48, -1262.47, 25.55)
local sellCoords = vector3(923.82, -1266.58, 25.52)
local tekneSpawnCoords = vector3(69.54, -2407.07, 6.04)
local carSpawn, carH = vector3(914.19, -1252.01, 25.53), 6.0
local yourVehicleModel = 0
local sellType, sellDif = "arac", "kolay"
local jobStart = false
local jobsCoords = 1
local jobBlip = nil
local number = "0000"
local deleteItemAmount = 0

RegisterNetEvent('PantCore:Client:OnPlayerLoaded')
AddEventHandler('PantCore:Client:OnPlayerLoaded', function()
    firstLogin()
end)

function firstLogin()
    PlayerData = PantCore.Functions.GetPlayerData()
    number = PlayerData.metadata.number
end

AddEventHandler('ld:playerdead', function(dead)
    if dead then
        if jobStart then
            jobStart = false
            if jobBlip then RemoveBlip(jobBlip) end
            if sellType == "tekne" then
                TriggerServerEvent("ld-ticaret:illegal-bildirim", "Deniz Ticaretini Yapan Kişi Yaralandı!")
            end
            sellType = "arac"
            sellDif = "kolay"
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local time = 1000
        if PantCore then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local boxDistance = #(playerCoords - boxCoords)
            if boxDistance < 20 then 
                time = 1
                DrawMarker(20, boxCoords.x, boxCoords.y, boxCoords.z-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0,0, 100, false, true, 2, false, false, false, false)
                if boxDistance < 2 then
                    PantCore.Functions.DrawText3D(boxCoords.x,boxCoords.y,boxCoords.z, "[E] Pack the materials")
                    if IsControlJustPressed(1, 38) then
                        local elements = {}
                        for i=1, #items do
                            local itemName = items[i].item
                            local rCount = items[i].count
                            table.insert(elements, {label = PantCore.Shared.Items[itemName].label.. " Malzemeleri Kutula("..rCount..")", value = itemName, rCount = rCount})
                        end

                        PantCore.UI.Menu.Open('default', GetCurrentResourceName(), 'kutula', {
                            title    = "kutula",
                            align    = 'top-left',
                            elements = elements
                        }, function(data, menu)
                            menu.close()
                            TriggerServerEvent("ld-ticaret:give-item", data.current.value, data.current.rCount)
                        end, function(data, menu)
                            menu.close()
                        end) 

                    end
                end
            end

            local sellDistance = #(playerCoords - sellCoords)
            if sellDistance < 20 then 
                time = 1
                DrawMarker(20, sellCoords.x, sellCoords.y, sellCoords.z-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0,0, 100, false, true, 2, false, false, false, false)
                if sellDistance < 2 then
                    PantCore.Functions.DrawText3D(sellCoords.x,sellCoords.y,sellCoords.z, "[E] Sell Trade Items")
                    if IsControlJustPressed(1, 38) then
                        PantCore.UI.Menu.Open('default', GetCurrentResourceName(), 'satis', {
                            title    = "satis",
                            align    = 'top-left',
                            elements = {
                                {label = "Araç", value = "arac"},
                                {label = "Tekne", value = "tekne"},
                            }
                        }, function(data, menu)
                            if data.current.value == "arac" then
                                --if not illegalPerm then
                                    PantCore.UI.Menu.Open('default', GetCurrentResourceName(), 'arac_satis', {
                                        title    = "satis",
                                        align    = 'top-left',
                                        elements = {
                                            {label = "Kolay", value = "kolay", time = aracKolaySure},
                                            {label = "Orta", value = "orta", time = aracOrtaSure},
                                            {label = "Zor", value = "zor", time = aracZorSure},
                                        }
                                    }, function(data2, menu2)
                                        PantCore.Functions.TriggerCallback("ld-ticaret:check-item", function(amount)
                                            if amount >= aracGerekenMiktar then
                                                startJob("arac", data2.current.value, data2.current.time, aracGerekenMiktar)
                                            else
                                                PantCore.Functions.Notify("Least "..aracGerekenMiktar.." Need Grain Trade Material!", "error")
                                            end
                                        end)
                                        PantCore.UI.Menu.CloseAll()
                                    end, function(data2, menu2)
                                        menu2.close()
                                    end) 
                                --else
                                --    PantCore.Functions.Notify("Yeminliler Bu İşi Yapamaz!", "error")
                                --end
                            elseif data.current.value == "tekne" then
                                PantCore.Functions.TriggerCallback("ld-ticaret:time-control", function(result)
                                    if result then
                                        PantCore.Functions.TriggerCallback("ld-ticaret:check-item", function(amount)
                                            if amount >= tekneGerekenMiktar then
                                                TriggerServerEvent("ld-ticaret:set-time")
                                                startJob("tekne", "zor", tekneSure, tekneGerekenMiktar)
                                            else
                                                PantCore.Functions.Notify("Least "..tekneGerekenMiktar.." Need Grain Trade Material!", "error")
                                            end
                                        end)
                                        PantCore.UI.Menu.CloseAll()
                                    end
                                end)
                            end
                        end, function(data, menu)
                            menu.close()
                        end) 

                    end
                end
            end

            if jobStart then
                local coords = jobCoords[sellType][jobsCoords]
                if jobCoords[sellType][jobsCoords] then
                    local jobsDistance = #(playerCoords - coords)
                    local firstDistance = 20
                    if sellType == "tekne" then firstDistance = 100 end
                    if jobsDistance < firstDistance then
                        time = 1
                        local height = 1.0
                        if sellType == "tekne" then height = 4.5 end
                        DrawMarker(20, coords.x, coords.y, coords.z-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, height, height, height, 255, 0,0, 100, false, true, 2, false, false, false, false)
                        local checkDistance = 2
                        if sellType == "tekne" then checkDistance = 20 end
                        if jobsDistance < checkDistance then
                            PantCore.Functions.DrawText3D(coords.x,coords.y,coords.z, "[E] Deliver Material")
                            if IsControlJustPressed(1, 38) then
                                PantCore.Functions.Progressbar("teslim", "Delivering", 5000, false, false, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    jobsCoords = jobsCoords + 1
                                    if jobsCoords > #jobCoords[sellType] then
                                        complateJob("Görev Tamamlandı!", "success")
                                        PantCore.Functions.DeleteVehicle(GetVehiclePedIsIn(playerPed, false))
                                    else
                                        setGPS()
                                    end
                                end, function() -- Cancel
                                end)
                               
                            end
                        end
                    end
                end
            end

            if not jobStart and sellType == "tekne" then
                local tekneSpawn = #(playerCoords - tekneSpawnCoords)
                if tekneSpawn < 20 then
                    time = 1
                    DrawMarker(20, tekneSpawnCoords.x, tekneSpawnCoords.y, tekneSpawnCoords.z-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0,0, 100, false, true, 2, false, false, false, false)
                    if tekneSpawn < 2 then
                        PantCore.Functions.DrawText3D(tekneSpawnCoords.x,tekneSpawnCoords.y,tekneSpawnCoords.z, "[E] Take out the Boat")
                        if IsControlJustPressed(1, 38) then
                            startTime(tekneSure)
                            jobStart = true
                            spawnVehicle(GetHashKey(tekneModel), vector3(53.77, -2417.03, 0.0), 51.92)
                        end
                    end

                end
            end
        end

        Citizen.Wait(time)
    end
end)

function setGPS()
    owned("Next Delivery Point Marked On The Map")
    SetNewWaypoint(jobCoords[sellType][jobsCoords]["x"], jobCoords[sellType][jobsCoords]["y"])
    if jobBlip then RemoveBlip(jobBlip) end
    jobBlip = AddBlipForCoord(jobCoords[sellType][jobsCoords]["x"], jobCoords[sellType][jobsCoords]["y"],jobCoords[sellType][jobsCoords]["z"])
	SetBlipSprite(jobBlip, 1)
	SetBlipColour(jobBlip, 16742399)
	SetBlipScale(jobBlip, 0.5)
end

function startJob(type, dif, setTime, xdeleteItemAmount)
    if not jobStart and sellType ~= "tekne" then
        deleteItemAmount = xdeleteItemAmount
        sellType = type
        sellDif = dif
        jobsCoords = 1
        if sellType == "arac" then
            startTime(setTime)
            jobStart = true
            if sellDif == "kolay" then
                spawnVehicle(GetHashKey(kolayAracModel), carSpawn, carH)
            elseif sellDif == "orta" then
                spawnVehicle(GetHashKey(ortaAracModel), carSpawn, carH)
            else
                spawnVehicle(GetHashKey(zorAracModel), carSpawn, carH)
            end
        elseif sellType == "tekne" then
            PantCore.Functions.Notify("Go to the Location Marked on the Map and Get the Boat", "primary", 15000)
            SetNewWaypoint(tekneSpawnCoords.x, tekneSpawnCoords.y)
        end
    end  
end

function startTime(setTime)
    local time = setTime
    Citizen.CreateThread(function()
        local fullTime = time
        while jobStart do
            local playerPed = PlayerPedId()
            Citizen.Wait(1000)
            time = time - 1
            if sellType == "tekne" then
                if time == 7180 or time == 6500 or time == 5000 or time == 3800 or time == 2800 or time == 1200 then
                    alertSystem()
                end
            end

            if time == 0 then complateJob("Teslimat Süresi Bitti!", "error") end

            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if yourVehicleModel ~= GetEntityModel(vehicle) then
                    complateJob("Farklı Araçta Olduğun İçin İş İptal Oldu!", "error")
                elseif GetVehicleEngineHealth(vehicle) < 200 and sellType == "arac" then
                    complateJob("Araç Motoru Çok Hasarlı Olduğu İçi İş İptal Oldu!", "error")
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while jobStart do
            DrawGenericTextThisFrame()
            SetTextEntry("STRING")
            AddTextComponentString("Kalan Dakika: " .. PantCore.Shared.Round(time/60, 2))
            DrawText(0.5, 0.90)
            Citizen.Wait(1)
        end
    end)
end

function complateJob(text, textType)
    jobStart = false
    if jobBlip then RemoveBlip(jobBlip) end
    TriggerServerEvent("ld-ticaret:give-money", jobsCoords-1 , sellDif, sellType, deleteItemAmount)
    PantCore.Functions.Notify(text, textType)
    sellType = "arac"
    sellDif = "kolay"
end

function DrawGenericTextThisFrame()
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end

function spawnVehicle(model, coords, h)
    yourVehicleModel = model
	WaitForModel(yourVehicleModel)
    PantCore.Functions.SpawnVehicle(yourVehicleModel, function(yourVehicle)
        local vehicleProps = {}
        vehicleProps.plate = "T"..GetPlayerServerId(PlayerId())
        PantCore.Functions.SetVehicleProperties(yourVehicle, vehicleProps)
        NetworkFadeInEntity(yourVehicle, true, true)
		SetModelAsNoLongerNeeded(yourVehicleModel)
		TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
        SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
        local id = NetworkGetNetworkIdFromEntity(yourVehicle)
        SetNetworkIdCanMigrate(id, true)
        SetVehicleFuelLevel(yourVehicle, 100.0)
        DecorSetFloat(yourVehicle, "_FUEL_LEVEL", 100.0)
        TriggerEvent("x-hotwire:give-keys", yourVehicle)
        setGPS()
    end, {x= coords.x, y= coords.y, z= coords.z, h=h }, true) -- coords, isnetwork
end

function WaitForModel(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
    
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return PantCore.Functions.Notify("There is no this model vehicle in the game.")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)
		DrawScreenText("Araç Yükleniyor " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end

function createBlips()
    blip = AddBlipForCoord(boxCoords)
    SetBlipSprite(blip, 615)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 47)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Ticaret Merkezi")
    EndTextCommandSetBlipName(blip)
end

function alertSystem()
    TriggerEvent("Ld-PolisBildirim:BildirimGonder", polisMesaj, false)
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("ld-ticaret:illegal-bildirim", illegalMesaj.." Place: Chupcabra Port - Red Desert Ave (Pasific Ocean) - Barbareno Port (Pasific Ocean)")
end

