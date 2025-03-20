# Bel-AFK Script

Script AFK (Away From Keyboard) untuk FiveM server dengan ESX Framework. Script ini membantu mengelola pemain yang tidak aktif di server dengan sistem verifikasi yang aman.

## Fitur Utama

### 1. Sistem Deteksi AFK
- Mendeteksi pemain yang tidak aktif berdasarkan:
  - Tidak ada pergerakan karakter
  - Tidak ada input kontrol (WASD, SHIFT, SPACE, Mouse)
  - Tidak ada pergerakan kendaraan
  - Tidak ada perubahan posisi atau heading
- Timer yang dapat dikustomisasi untuk menentukan kapan pemain dianggap AFK
- Interval pengecekan yang dapat disesuaikan

### 2. Sistem Verifikasi
- Kode verifikasi 4 digit yang diacak
- Input dialog yang user-friendly menggunakan ox_lib
- Pencegahan keluar dari mode AFK tanpa verifikasi
- Notifikasi error jika kode verifikasi salah

### 3. UI/UX
- Menu AFK yang responsif menggunakan ox_lib
- Timer AFK yang dapat diaktifkan/nonaktifkan
- Format waktu yang dapat dikustomisasi (jam, menit, detik)
- Notifikasi server yang informatif

### 4. Sistem Teleportasi
- Teleportasi otomatis ke zona AFK yang dapat dikonfigurasi
- Penyimpanan posisi asli pemain
- Teleportasi kembali ke posisi awal setelah verifikasi

### 5. Integrasi Server
- Notifikasi server untuk semua pemain
- Status AFK yang dapat diakses oleh script lain
- Event system untuk integrasi dengan script lain

## Cara Kerja

### 1. Deteksi AFK
1. Script memantau aktivitas pemain setiap interval yang ditentukan
2. Jika tidak ada aktivitas terdeteksi selama waktu timeout:
   - Posisi pemain disimpan
   - Pemain di-teleport ke zona AFK
   - Status AFK diaktifkan
   - Kode verifikasi dibuat

### 2. Mode AFK
1. Pemain tidak dapat bergerak atau berinteraksi
2. Menu AFK ditampilkan dengan:
   - Timer durasi AFK (opsional)
   - Kode verifikasi
   - Tombol untuk memasukkan kode
3. Server memberitahu semua pemain

### 3. Kembali dari AFK
1. Pemain memasukkan kode verifikasi
2. Jika kode benar:
   - Pemain di-teleport kembali ke posisi awal
   - Kontrol pemain diaktifkan kembali
   - Status AFK dinonaktifkan
3. Jika kode salah:
   - Notifikasi error ditampilkan
   - Pemain tetap dalam mode AFK

## Konfigurasi

Semua pengaturan dapat diubah di file `config.lua`:

### Timer & Interval
```lua
Config.AFKTimeout = 300 -- Waktu dalam detik sebelum pemain dianggap AFK
Config.CheckInterval = 1000 -- Interval pengecekan dalam milidetik
```

### Format Waktu
```lua
Config.TimeFormat = {
    hours = "jam",
    minutes = "menit",
    seconds = "detik"
}
```

### Notifikasi
```lua
Config.Notifications = {
    afk = "Anda telah masuk mode AFK",
    welcome = "Selamat datang kembali!",
    error = "Kode verifikasi salah!"
}
```

### UI
```lua
Config.UI = {
    showTimer = true, -- Tampilkan timer AFK
    verificationMenu = {
        title = "Menu Verifikasi AFK",
        durationTitle = "Durasi AFK",
        codeTitle = "Kode Verifikasi",
        enterCodeTitle = "Masukkan Kode",
        -- ... konfigurasi icon
    }
}
```

### Zona AFK
```lua
Config.AFKZone = vector3(x, y, z) -- Koordinat zona AFK
```

## Dependensi

### Wajib
- ESX Framework
- ox_lib

### Versi yang Direkomendasikan
- ESX Legacy
- ox_lib terbaru

## Instalasi

1. Download script dari repository
2. Ekstrak folder `bel-afk` ke folder `resources` server
3. Tambahkan `ensure bel-afk` di `server.cfg`
4. Pastikan dependensi sudah terinstall dan berjalan
5. Restart server atau gunakan `refresh` dan `ensure bel-afk`

## Troubleshooting

### Masalah Umum
1. Script tidak berjalan
   - Pastikan dependensi sudah terinstall
   - Cek error di console server
   - Pastikan urutan load script benar

2. Pemain tidak terdeteksi AFK
   - Cek konfigurasi timeout dan interval
   - Pastikan fungsi deteksi pergerakan berjalan
   - Cek console untuk error

3. Menu tidak muncul
   - Pastikan ox_lib terinstall dengan benar
   - Cek konfigurasi UI
   - Restart resource

## Support

Untuk bantuan atau laporan bug, silakan buat issue di repository.
atau masuk discord https://discord.gg/yxvDyQeUFZ

## Lisensi

Script ini dilisensikan di bawah MIT License. Silakan lihat file `LICENSE` untuk detail lebih lanjut. 
