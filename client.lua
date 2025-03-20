ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local isAFK = false
local originalPosition = nil
local lastActivity = 0
local verificationCode = nil
local afkStartTime = 0
local hasSpawned = false 

local lastX, lastY, lastZ = 0, 0, 0
local lastHeading = 0

local Events = {
    setAFK = 'bel-afk:setAFK',
    getAFKStatus = 'bel-afk:getAFKStatus',
    getSharedObject = 'esx:getSharedObject'
}

local shouldUpdateAFKMenu = false

AddEventHandler('playerSpawned', function()
    -- Set waktu aktivitas awal saat spawn
    lastActivity = GetGameTimer()
    hasSpawned = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    lastActivity = GetGameTimer()
    hasSpawned = true
    isAFK = false
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    lastActivity = GetGameTimer()
end)

AddEventHandler('esx:onPlayerLogout', function()
    hasSpawned = false
    isAFK = false
    originalPosition = nil
    verificationCode = nil
    afkStartTime = 0
    shouldUpdateAFKMenu = false
end)

local function FormatWaktu(detik)
    local jam = math.floor(detik / 3600)
    local menit = math.floor((detik % 3600) / 60)
    local detik = math.floor(detik % 60)
    
    local hasil = {}
    
    if jam > 0 then
        table.insert(hasil, jam .. ' ' .. Config.TimeFormat.hours)
    end
    if menit > 0 then
        table.insert(hasil, menit .. ' ' .. Config.TimeFormat.minutes)
    end
    if detik > 0 or #hasil == 0 then
        table.insert(hasil, detik .. ' ' .. Config.TimeFormat.seconds)
    end
    
    return table.concat(hasil, ' ')
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if not isAFK and hasSpawned then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(ped))
            local heading = GetEntityHeading(ped)
            
            if x ~= lastX or y ~= lastY or z ~= lastZ or heading ~= lastHeading then
                lastActivity = GetGameTimer()
            end
            
            lastX, lastY, lastZ = x, y, z
            lastHeading = heading
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckInterval)
        if hasSpawned and not isAFK then
            if not IsPemainBergerak() then 
                if GetGameTimer() - lastActivity > (Config.AFKTimeout * 1000) then
                    SetPemainAFK()
                end
            else
                lastActivity = GetGameTimer()
            end
        end
    end
end)

function IsPemainBergerak()
    local ped = PlayerPedId()
    
    if IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped) then
        return true
    end

    if GetEntitySpeed(ped) > 0.0 then
        return true
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 and GetEntitySpeed(vehicle) > 0.0 then
        return true
    end

    if IsControlPressed(0, 32) or -- W
       IsControlPressed(0, 33) or -- S
       IsControlPressed(0, 34) or -- A
       IsControlPressed(0, 35) or -- D
       IsControlPressed(0, 21) or -- SHIFT
       IsControlPressed(0, 22) or -- SPACE
       IsControlPressed(0, 24) or -- Klik Kiri
       IsControlPressed(0, 25) then -- Klik Kanan
        return true
    end

    -- Jika tidak ada aktivitas, berarti pemain tidak bergerak
    return false
end

function SetPemainAFK()
    local ped = PlayerPedId()
    originalPosition = GetEntityCoords(ped)
    isAFK = true
    afkStartTime = GetGameTimer()
    
    verificationCode = tostring(math.random(1000, 9999))
    SetEntityCoords(ped, Config.AFKZone, false, false, false, true)
    lib.notify(Config.Notifications.afk)
    TriggerServerEvent(Events.setAFK, true)
    TampilkanUIVerifikasi()
end

function TampilkanUIVerifikasi()
    shouldUpdateAFKMenu = true
    
    if Config.UI.showTimer then
        Citizen.CreateThread(function()
            while shouldUpdateAFKMenu and isAFK do
                local durasiAFK = math.floor((GetGameTimer() - afkStartTime) / 1000)
                UpdateAFKMenu(durasiAFK)
                Citizen.Wait(1000)
            end
        end)
        UpdateAFKMenu(0)
    else
        -- Jika timer tidak aktif, tampilkan menu statis
        UpdateAFKMenu(-1) 
    end
end

function UpdateAFKMenu(durasiDetik)
    local menuOptions = {}
    
    if Config.UI.showTimer and durasiDetik >= 0 then
        table.insert(menuOptions, {
            title = Config.UI.verificationMenu.durationTitle,
            description = FormatWaktu(durasiDetik),
            icon = Config.UI.verificationMenu.timerIcon
        })
    end
    
    table.insert(menuOptions, {
        title = Config.UI.verificationMenu.codeTitle,
        description = verificationCode,
        icon = Config.UI.verificationMenu.codeIcon
    })
    
    table.insert(menuOptions, {
        title = Config.UI.verificationMenu.enterCodeTitle,
        icon = Config.UI.verificationMenu.enterIcon,
        onSelect = function()
            local input = lib.inputDialog('Verifikasi AFK', {
                {
                    type = 'input',
                    label = 'Masukkan Kode Verifikasi',
                    placeholder = '####',
                    required = true,
                    min = 4,
                    max = 4
                }
            })

            -- Jika input dibatalkan, tampilkan kembali menu AFK
            if not input then
                if Config.UI.showTimer then
                    UpdateAFKMenu(math.floor((GetGameTimer() - afkStartTime) / 1000))
                else
                    UpdateAFKMenu(-1)
                end
                return
            end

            if input[1] == verificationCode then
                KembaliDariAFK()
            else
                lib.notify(Config.Notifications.error)
                if Config.UI.showTimer then
                    UpdateAFKMenu(math.floor((GetGameTimer() - afkStartTime) / 1000))
                else
                    UpdateAFKMenu(-1)
                end
            end
        end
    })

    lib.registerContext({
        id = 'afk_menu',
        title = Config.UI.verificationMenu.title,
        options = menuOptions
    })

    lib.showContext('afk_menu')
end

function KembaliDariAFK()
    if originalPosition and isAFK then
        local ped = PlayerPedId()
        
        shouldUpdateAFKMenu = false
        
        lib.hideContext()
        Citizen.Wait(100)
        
        EnableAllControlActions(0)
        EnableAllControlActions(1)
        EnableAllControlActions(2)
        
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        SetPlayerControl(PlayerId(), true, 0)
        
        SetEntityCoords(ped, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
        
        isAFK = false
        TriggerServerEvent(Events.setAFK, false)
        
        lib.notify(Config.Notifications.welcome)
        
        originalPosition = nil
        verificationCode = nil
        afkStartTime = 0
        
        lastActivity = GetGameTimer()
    end
end
