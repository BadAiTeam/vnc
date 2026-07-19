#!/bin/bash

# 1. Update dan Install paket yang diperlukan (wajib pakai sudo untuk apt)
apt-get update -y
apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server novnc python3-websockify dbus-x11

# 2. Setup direktori dan password VNC
mkdir -p ~/.vnc
echo "cloudshell123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 3. Konfigurasi XStartup agar GUI XFCE meluncur dengan benar di dalam VNC
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
OS=`uname -s`
if [ $OS = 'Linux' ]; then
  case "$WINDOWMANAGER" in
    *xfce*)
      startxfce4 &
      ;;
    *)
      startxfce4 &
      ;;
  esac
fi
EOF
chmod +x ~/.vnc/xstartup

# 4. Bersihkan session lama (jika ada) dan nyalakan VNC Server baru
vncserver -kill :1 >/dev/null 2>&1
vncserver :1 -geometry 1280x720 -depth 24

# 5. Perbaiki bug 404 noVNC (wajib pakai sudo karena di direktori /usr)
ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 6. Jembatani ke Web port 8080
websockify --web=/usr/share/novnc/ 8080 localhost:5901
