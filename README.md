# Auto WMS Lite Login

Copyright (c) 2024 [zelsaddr](https://github.com/zelsaddr)

Script untuk login otomatis ke WMS Lite pada router OpenWRT.

## Persyaratan

- Router dengan OpenWRT
- Paket yang dibutuhkan:
  - grep
  - curl
  - sed
  - dig 

## Cara Instalasi

1. Install paket yang dibutuhkan:

```bash
opkg update
opkg install grep curl
opkg install bind-dig 
```

2. Download dan pindahkan script:

```bash
wget https://raw.githubusercontent.com/zelsaddr/autologin-wms/refs/heads/main/autowms.sh
mv autowms.sh /usr/bin/
chmod +x /usr/bin/autowms.sh
```

3. Edit konfigurasi di dalam script:

```bash
nano /usr/bin/autowms.sh
```

Ubah nilai variabel berikut sesuai dengan pengaturan Anda:

- `SETUSERNAME`: Username WMS Lite Anda
- `SETPASSWORD`: Password WMS Lite Anda
- `SETIFACE`: Interface jaringan yang digunakan (contoh: wlan0, wlan1)

4. Untuk menjalankan script secara otomatis saat boot:

   a. Buka web interface OpenWRT (LuCI) di browser:

   - Buka `http://192.168.1.1` (atau IP router Anda)
   - Login dengan kredensial router Anda

   b. Tambahkan script ke startup:

   - Pergi ke menu "System" -> "Startup"
   - Di bagian "Local Startup", tambahkan baris berikut:

   ```bash
   /bin/sh /usr/bin/autowms.sh &
   ```

   - Klik "Submit" untuk menyimpan
   - Klik "Start" untuk menjalankan script sekarang

## Cara Penggunaan

1. Jalankan script secara manual:

```bash
/bin/sh /usr/bin/autowms.sh
```

2. Script akan berjalan di background dan:

   - Mengecek koneksi internet setiap 2 detik
   - Melakukan login otomatis jika koneksi terputus
   - Mencatat log di system log

3. Untuk melihat log:

```bash
logread | grep "autowms"
```

## Troubleshooting

1. Jika script tidak berjalan:

   - Pastikan semua paket terinstall
   - Periksa permission script (harus executable)
   - Periksa path script di pengaturan startup
   - Pastikan script berjalan di background (ada tanda & di akhir)

2. Jika login gagal:
   - Periksa username dan password di konfigurasi
   - Pastikan interface jaringan yang digunakan benar
   - Periksa koneksi ke server WMS Lite

## Catatan

- Script ini akan melakukan logout dan login ulang jika terdeteksi tidak ada koneksi internet
- Log akan dicatat di system log router
- Pastikan untuk mengganti username dan password sesuai dengan akun WMS Lite Anda

## Kontribusi

Silakan buat pull request jika Anda ingin berkontribusi untuk meningkatkan script ini.

## Lisensi

Script ini adalah perangkat lunak open source yang dirilis di bawah lisensi [MIT](https://opensource.org/licenses/MIT). Anda bebas untuk menggunakan, memodifikasi, dan mendistribusikan script ini sesuai dengan ketentuan lisensi MIT.

Lisensi MIT memberikan Anda kebebasan untuk:

- Menggunakan script untuk tujuan komersial
- Memodifikasi script
- Mendistribusikan script
- Menggunakan script secara pribadi
- Menggunakan script untuk tujuan komersial

Dengan syarat Anda menyertakan pemberitahuan hak cipta dan lisensi asli dalam semua salinan atau bagian penting dari script.
