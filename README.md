<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=33&color=601EF9&center=true&vCenter=true&width=600&lines=Membuat+Samba+Di+Debian">
</div>

## Apa Itu Samba?

Samba adalah software open-source yang digunakan untuk melakukan file sharing antara sistem Linux dan Windows. Dengan Samba, folder yang ada di Linux bisa diakses langsung dari Windows melalui jaringan lokal, dan sebaliknya. Samba menggunakan protokol SMB (Server Message Block), yaitu protokol standar yang biasa dipakai di lingkungan Windows untuk berbagi file, printer, dan resource jaringan lainnya. Karena itu, Samba sangat cocok digunakan di jaringan lokal (LAN), baik di sekolah, lab, maupun kantor.

## langkah-langkah Konfigurasi

Membuat file sharing menggunakan Samba di Debian sebenarnya cukup mudah. Kita hanya perlu menginstall paket Samba, lalu melakukan sedikit konfigurasi. Untuk memulai silahkan kalian masuk ke sistem Debian dan login sebagai root. Setelah itu, install paket Samba dengan command berikut:
```bash
apt install samba -y
```
tunggu hingga selesai lalu kalian dapat konfigurasi file config-nya. filenya terdapat di `/etc/samba`. Tetapi sebelum config disarankan kalian bisa membuat file backup confignya (opsional).Ini berguna kalau sewaktu-waktu terjadi kesalahan dan ingin mengembalikan ke pengaturan awal. Jika kalian ingin membuat file backup-nya kalian dapat menggunakan command ini:
```bash
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
```
setelah itu kalian dapat mengedit file config-nya menggunakan teks editor (nano).
```bash
nano /etc/samba/smb.conf
```
setelah membuka file confignya kalian dapat scroll ke paling bawah lalu kalian dapat menambahkan path direktori yang akan dijadikan tempat untuk file sharing dan beberapa opsi. sebagai contoh saya akan membuat direktori untuk file sharing di "/home/sharing_samba" dan berikut contoh config selengkapnya.
```txt
[File Sharing]
path = /home/sharing_samba
browsable = yes
writeable = yes
guest ok = yes
read only = no
```
Penjelasan singkat:
- [File Sharing] → Nama folder share yang akan muncul di network
- path → Lokasi folder di sistem Debian
- browsable = yes → Folder akan terlihat di jaringan
- writeable = yes → Client bisa upload, edit, dan hapus file
- guest ok = yes → Bisa diakses tanpa login
- read only = no → Folder tidak bersifat read-only

Setelah konfigurasi selesai, buat folder sesuai dengan path yang tadi ditentukan, lalu berikan permission agar bisa diakses oleh client. Kalian dapat menggunakan command seperti ini
```bash
mkdir /home/sharing_samba
chmod 777 /home/sharing_samba
```
Terakhir setelah config semuanya dengan benar, restart service Samba agar konfigurasi yang baru bisa diterapkan.
```bash
systemctl restart smbd
```

## Konfigurasi Samba dengan Username dan Password
Untuk menambahkan user dan password di Samba, konfigurasi dasarnya sebenarnya tidak jauh berbeda dengan konfigurasi sebelumnya. Perbedaannya ada pada pembatasan akses, di mana hanya user tertentu yang diperbolehkan mengakses folder sharing.

Sebagai contoh, pada tutorial ini kita akan membuat user dengan nama sambauser.

Agar folder sharing hanya bisa diakses oleh user tertentu, kita cukup menambahkan opsi "valid users = \<nama user>\"pada konfigurasi Samba. Kalian dapat membuka file konfigurasinya lalu tambahkan opsi tersebut, contohnya seperti ini:

```txt
[File Sharing]
path = /home/sharing_samba
browsable = yes
writeable = yes
guest ok = no
read only = no
valid users = sambauser
```

selanjutnya Kalian bisa menggunakan user Linux yang sudah ada, atau membuat user baru. Berikut contoh membuat user baru sekaligus menambahkannya ke Samba.
```bash
# Contoh membuat User Linux baru
adduser sambauser

# Menambahkan User dan Password ke Samba
smbpasswd -a sambauser

# Mengaktifkan user Samba
smbpasswd -e sambauser
```
Agar user "sambauser" memiliki hak akses ke folder sharing, ubah kepemilikan folder menjadi milik user tersebut.
```bash
chown sambauser:sambauser /home/sharing_samba
```
Terakhir, restart service Samba agar semua konfigurasi yang telah dibuat bisa diterapkan. Dan Setelah ini, folder sharing hanya bisa diakses menggunakan username dan password yang sudah dibuat.
```bash
systemctl restart smbd
```

Kalian dapat mengakses file sharing Samba melalui Windows dengan membuka File Explorer. Selanjutnya, masuk ke menu Network, lalu pada address bar ketikkan alamat server Samba dengan format berikut:
`\\<IP_Server_Samba>`
Kemudian tekan Enter, dan pilih folder File Sharing yang tersedia.

Sebagai contoh, jika IP address server Samba adalah 192.168.43.49, maka alamat yang diakses adalah: 
`\\192.168.43.49`
Setelah itu, folder sharing akan terbuka dan dapat digunakan untuk mengakses, menyalin, maupun mengelola file sesuai dengan hak akses yang diberikan.

![File-Sharing](https://raw.githubusercontent.com/Kaguai10/FileSharing_dengan_Samba/refs/heads/main/Samba.png "File-Sharing")

Kalian juga dapat mencoba tools Otomatis yang saya buat, dengan cara seperti berikut:
```bash
git clone https://github.com/Kaguai10/FileSharing_dengan_Samba.git

cd FileSharing_dengan_Samba

chmod +x run.sh

#lalu Jalankan run.sh dan bisa gunakan --help untuk melihat opsi yang tersedia
#contoh menjalankannya

sudo ./run.sh --path /home/kaguai/folder_sharing --user kaguai:passw0rd --no-guest
```
