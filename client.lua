ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local isAFK = false
local originalPosition = nil
local lastActivity = 0
local verificationCode = nil
local afkStartTime = 0
local hasSpawned = false -- Tambah variabel untuk mengecek spawn

-- Variabel untuk melacak posisi terakhir
local lastX, lastY, lastZ = 0, 0, 0
local lastHeading = 0

-- Event names
local Events = {
    setAFK = 'bel-afk:setAFK',
    getAFKStatus = 'bel-afk:getAFKStatus',
    getSharedObject = 'esx:getSharedObject'
}

local shouldUpdateAFKMenu = false

-- Event saat player spawn pertama kali
AddEventHandler('playerSpawned', function()
    -- Set waktu aktivitas awal saat spawn
    lastActivity = GetGameTimer()
    hasSpawned = true
end)

-- Event saat player loaded di ESX
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    -- Reset timer dan status saat player baru masuk
    lastActivity = GetGameTimer()
    hasSpawned = true
    isAFK = false
end)

-- Event saat resource dimulai
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    -- Set waktu aktivitas awal saat resource start
    lastActivity = GetGameTimer()
end)

-- Event saat player disconnect atau keluar
AddEventHandler('esx:onPlayerLogout', function()
    hasSpawned = false
    isAFK = false
    originalPosition = nil
    verificationCode = nil
    afkStartTime = 0
    shouldUpdateAFKMenu = false
end)

-- Fungsi untuk memformat waktu
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

-- Thread untuk memeriksa perubahan posisi
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Cek setiap detik
        if not isAFK and hasSpawned then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(ped))
            local heading = GetEntityHeading(ped)
            
            -- Cek apakah posisi atau heading berubah
            if x ~= lastX or y ~= lastY or z ~= lastZ or heading ~= lastHeading then
                lastActivity = GetGameTimer()
            end
            
            -- Update posisi terakhir
            lastX, lastY, lastZ = x, y, z
            lastHeading = heading
        end
    end
end)

-- Fungsi untuk memeriksa aktivitas pemain
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckInterval)
        -- Hanya cek AFK jika player sudah spawn dan tidak sedang AFK
        if hasSpawned and not isAFK then
            if not IsPemainBergerak() then -- Ubah logika pengecekan
                if GetGameTimer() - lastActivity > (Config.AFKTimeout * 1000) then
                    SetPemainAFK()
                end
            else
                lastActivity = GetGameTimer()
            end
        end
    end
end)

-- Fungsi untuk memeriksa apakah pemain bergerak
function IsPemainBergerak()
    local ped = PlayerPedId()
    
    -- Cek pergerakan dasar (berjalan, berlari, sprint)
    if IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped) then
        return true
    end

    -- Cek kecepatan karakter
    if GetEntitySpeed(ped) > 0.0 then
        return true
    end

    -- Cek jika pemain sedang mengemudi
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 and GetEntitySpeed(vehicle) > 0.0 then
        return true
    end

    -- Cek input kontrol dari pemain
    if IsControlPressed(0, 32) or -- W
       IsControlPressed(0, 33) or -- S
       IsControlPressed(0, 34) or -- A
       IsControlPressed(0, 35) or -- D
       IsControlPressed(0, 21) or -- SHIFT
       IsControlPressed(0, 22) or -- SPACE
       IsControlPressed(0, 24) or -- Left Click
       IsControlPressed(0, 25) then -- Right Click
        return true
    end

    -- Jika tidak ada aktivitas, berarti pemain tidak bergerak
    return false
end

-- Fungsi untuk mengatur pemain menjadi AFK
function SetPemainAFK()
    local ped = PlayerPedId()
    originalPosition = GetEntityCoords(ped)
    isAFK = true
    afkStartTime = GetGameTimer()
    
    -- Membuat kode verifikasi acak
    verificationCode = tostring(math.random(1000, 9999))
    
    -- Teleport ke zona AFK menggunakan vector3
    SetEntityCoords(ped, Config.AFKZone, false, false, false, true)
    
    -- Tampilkan notifikasi AFK menggunakan ox_lib
    lib.notify(Config.Notifications.afk)
    
    TriggerServerEvent(Events.setAFK, true)
    
    -- Tampilkan UI verifikasi
    TampilkanUIVerifikasi()
end

-- Fungsi untuk menampilkan UI verifikasi menggunakan ox_lib
function TampilkanUIVerifikasi()
    -- Set flag untuk memulai thread
    shouldUpdateAFKMenu = true
    
    -- Thread untuk memperbarui durasi AFK hanya jika timer aktif
    if Config.UI.showTimer then
        Citizen.CreateThread(function()
            while shouldUpdateAFKMenu and isAFK do
                local durasiAFK = math.floor((GetGameTimer() - afkStartTime) / 1000)
                UpdateAFKMenu(durasiAFK)
                Citizen.Wait(1000)
            end
        end)
        -- Tampilkan menu awal dengan timer
        UpdateAFKMenu(0)
    else
        -- Jika timer tidak aktif, tampilkan menu statis
        UpdateAFKMenu(-1) -- Menggunakan -1 untuk menandakan menu statis
    end
end

-- Fungsi untuk memperbarui menu AFK
function UpdateAFKMenu(durasiDetik)
    local menuOptions = {}
    
    -- Tambahkan opsi timer hanya jika timer aktif dan durasiDetik bukan -1
    if Config.UI.showTimer and durasiDetik >= 0 then
        table.insert(menuOptions, {
            title = Config.UI.verificationMenu.durationTitle,
            description = FormatWaktu(durasiDetik),
            icon = Config.UI.verificationMenu.timerIcon
        })
    end
    
    -- Tambahkan opsi kode verifikasi
    table.insert(menuOptions, {
        title = Config.UI.verificationMenu.codeTitle,
        description = verificationCode,
        icon = Config.UI.verificationMenu.codeIcon
    })
    
    -- Tambahkan opsi input verifikasi
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

            -- Verifikasi kode
            if input[1] == verificationCode then
                KembaliDariAFK()
            else
                lib.notify(Config.Notifications.error)
                -- Tampilkan kembali menu setelah notifikasi error
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

    -- Selalu tampilkan menu saat AFK
    lib.showContext('afk_menu')
end

-- Fungsi untuk kembali dari mode AFK
function KembaliDariAFK()
    if originalPosition and isAFK then
        local ped = PlayerPedId()
        
        -- Hentikan thread update menu
        shouldUpdateAFKMenu = false
        
        -- Hapus menu konteks
        lib.hideContext()
        Citizen.Wait(100) -- Berikan sedikit waktu untuk menu benar-benar tertutup
        
        -- Enable semua kontrol terlebih dahulu
        EnableAllControlActions(0)
        EnableAllControlActions(1)
        EnableAllControlActions(2)
        
        -- Enable movement controls secara spesifik
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        SetPlayerControl(PlayerId(), true, 0)
        
        -- Teleport kembali ke posisi awal
        SetEntityCoords(ped, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
        
        -- Set status
        isAFK = false
        TriggerServerEvent(Events.setAFK, false)
        
        -- Tampilkan notifikasi selamat datang menggunakan ox_lib
        lib.notify(Config.Notifications.welcome)
        
        -- Reset semua variabel
        originalPosition = nil
        verificationCode = nil
        afkStartTime = 0
        
        -- Reset last activity
        lastActivity = GetGameTimer()
    end
end
