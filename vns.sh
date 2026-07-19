sudo apt-get update -y
sudo apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server novnc python3-websockify dbus-x11 x11-xserver-utils

# 2. Setup folder & password VNC
mkdir -p ~/.vnc
echo "cloudshell123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 3. Konfigurasi xstartup yang memaksa XFCE meluncur via DBus
cat << 'EON' > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Memuat konfigurasi X11 bawaan sistem jika ada
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey

# Menjalankan XFCE dengan dbus-launch agar tidak crash di container minimal
if [ -x /usr/bin/startxfce4 ]; then
  dbus-launch --exit-with-session /usr/bin/startxfce4
else
  x-session-manager
fi
EON
chmod +x ~/.vnc/xstartup

# 4. Bersihkan sisa proses VNC yang mati mendadak
vncserver -kill :1 >/dev/null 2>&1
sudo rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null

# 5. Jalankan VNC Server dengan opsi pembatasan localhost dimatikan
vncserver :1 -geometry 1280x720 -depth 24 -localhost no

# 6. Salin & Perbaiki noVNC di direktori lokal
mkdir -p ~/novnc-web
cp -r /usr/share/novnc/* ~/novnc-web/
ln -sf ~/novnc-web/vnc.html ~/novnc-web/index.html

# 7. Jalankan Websockify
websockify --web=$HOME/novnc-web/ 8080 localhost:5901
