Config = {}

-- Pengaturan Waktu
Config.AFKTimeout = 5 -- Waktu dalam detik sebelum pemain dianggap AFK (300 = 5 menit)
Config.CheckInterval = 1000 -- Interval pengecekan aktivitas pemain dalam milidetik (1000 = 1 detik)
Config.TimeFormat = {
    hours = "jam",
    minutes = "menit",
    seconds = "detik"
}

-- Pengaturan Posisi
Config.AFKZone = vector3(223.6673, -897.6230, 30.6923) -- Koordinat zona AFK (x, y, z)

-- Pengaturan Notifikasi
Config.Notifications = {
    afk = {
        title = 'Status AFK',
        description = 'Anda sekarang dalam mode AFK',
        type = 'info'
    },
    welcome = {
        title = 'Selamat Datang Kembali',
        description = 'Anda telah kembali dari mode AFK',
        type = 'success'
    },
    error = {
        title = 'Kode Salah',
        description = 'Kode verifikasi yang anda masukkan salah',
        type = 'error'
    }
}

-- Pengaturan Tampilan
Config.UI = {
    showTimer = true, -- Set false untuk menyembunyikan tampilan waktu AFK
    position = "right-center", -- Posisi tampilan UI (right-center, left-center, top-center, bottom-center)
    style = {
        borderRadius = 0,
        backgroundColor = '#141517',
        color = 'white'
    },
    progressBar = {
        label = 'MODE AFK',
        disable = {
            move = true, -- Nonaktifkan gerakan
            car = true,  -- Nonaktifkan kendaraan
            combat = true, -- Nonaktifkan pertarungan
            mouse = false -- Aktifkan mouse
        }
    },
    verificationMenu = {
        title = "Menu AFK",
        durationTitle = "Durasi AFK",
        codeTitle = "Kode Verifikasi",
        enterCodeTitle = "Masukkan Kode",
        timerIcon = "clock",
        codeIcon = "key",
        enterIcon = "check"
    }
} 