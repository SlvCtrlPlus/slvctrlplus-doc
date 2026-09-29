#!/usr/bin/env bash
#
# Unattended SlvCtrl+ install script for Raspberry Pi (OS: Debian/Raspberry Pi OS).
# Installs the prebuilt release of server + frontend, sets up nginx (HTTP only)
# and registers the server with pm2 to start on boot.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/SlvCtrlPlus/slvctrlplus-doc/main/setup/install-rpi.sh | sudo bash
#
# See setup/setup-rpi.md in this repo for the manual, step-by-step version of
# this guide (including build-from-source and HTTPS setup).

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Try: curl -fsSL <url> | sudo bash" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

SERVICE_USER=slvctrlplus
SERVICE_HOME=/home/$SERVICE_USER
BACKEND_DIR=/usr/share/slvctrlplus-server
FRONTEND_DIR=/usr/share/slvctrlplus-frontend
NODE_VERSION=24

# Runs a command as $SERVICE_USER with nvm/node/pm2 available on PATH.
as_service_user() {
  sudo -u "$SERVICE_USER" -H bash -c '
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    eval "$1"
  ' _ "$1"
}

echo "=> Updating system packages..."
apt-get update
apt-get -y upgrade
apt-get -y install nginx git ssl-cert

echo "=> Enabling serial port..."
if raspi-config nonint get_serial_hw >/dev/null 2>&1; then
  raspi-config nonint do_serial_hw 0
else
  raspi-config nonint do_serial 0 \
    || echo "WARNING: could not enable serial port automatically, please run 'sudo raspi-config' manually (Interface Options > Serial Port)."
fi

echo "=> Checking for known Bluetooth memory leak..."
PI_MODEL=""
if [ -f /proc/device-tree/model ]; then
  PI_MODEL=$(tr -d '\0' < /proc/device-tree/model)
fi
if echo "$PI_MODEL" | grep -qE 'Pi (3|4|400)|Zero (W|2)'; then
  cat <<EOF

NOTE: $PI_MODEL has built-in Bluetooth, which shares UART hardware and is
known to cause a memory leak in the 'serialport' npm package used by
SlvCtrl+. If you notice memory usage growing over time, disable Bluetooth:

  echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt
  sudo reboot

EOF
fi

echo "=> Creating service user '$SERVICE_USER'..."
if ! id "$SERVICE_USER" >/dev/null 2>&1; then
  adduser --system --group --home "$SERVICE_HOME" "$SERVICE_USER"
fi
usermod -aG ssl-cert "$SERVICE_USER"

echo "=> Installing nvm, Node.js $NODE_VERSION and pm2 for $SERVICE_USER..."
sudo -u "$SERVICE_USER" -H bash -c '
  if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
  fi
'
as_service_user "nvm install $NODE_VERSION && nvm alias default node && nvm use $NODE_VERSION && npm install --global pm2"

echo "=> Installing SlvCtrl+ backend..."
mkdir -p "$BACKEND_DIR"
wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-server/releases/latest/download/dist.tar.gz -O - | tar -xz -C "$BACKEND_DIR"

echo "=> Installing SlvCtrl+ frontend..."
mkdir -p "$FRONTEND_DIR"
wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-frontend/releases/latest/download/dist.tar.gz -O - | tar -xz -C "$FRONTEND_DIR"

# Let $SERVICE_USER write here directly, so update-slvctrlplus.sh doesn't need root.
chown -R "$SERVICE_USER:$SERVICE_USER" "$BACKEND_DIR" "$FRONTEND_DIR"

echo "=> Configuring nginx..."
cat > /etc/nginx/sites-available/default <<EOF
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root $FRONTEND_DIR/dist/;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		include  /etc/nginx/mime.types;
		index index.html;

		try_files \$uri \$uri/ /index.html;
	}
}
EOF
systemctl reload nginx

echo "=> Configuring pm2..."
mkdir -p /etc/pm2
cat > /etc/pm2/apps.config.js <<EOF
module.exports = {
  apps : [
      {
        name: "slvctrlplus-server",
        script: "$BACKEND_DIR/dist/index.js",
        env: {
          "PORT": 1337,
          "LOG_LEVEL": "info"
        }
      }
  ]
}
EOF

echo "=> Registering pm2 to start on boot..."
STARTUP_OUTPUT=$(as_service_user "pm2 startup systemd -u $SERVICE_USER --hp $SERVICE_HOME")
echo "$STARTUP_OUTPUT"
STARTUP_CMD=$(echo "$STARTUP_OUTPUT" | grep '^sudo ' || true)
if [ -n "$STARTUP_CMD" ]; then
  eval "$STARTUP_CMD"
else
  echo "WARNING: could not detect pm2 startup command automatically, run 'pm2 startup' manually as $SERVICE_USER."
fi

echo "=> Starting SlvCtrl+ server..."
as_service_user "pm2 start /etc/pm2/apps.config.js && pm2 save"

echo "=> Creating update script..."
cat > "$SERVICE_HOME/update-slvctrlplus.sh" <<'EOF'
#!/usr/bin/env bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

BACKEND_REPO=SlvCtrlPlus/slvctrlplus-server
BACKEND_DIR=/usr/share/slvctrlplus-server
BACKEND_VERSION=$(get_latest_release $BACKEND_REPO)
echo "=> Update backend to version $BACKEND_VERSION..."
(mkdir -p $BACKEND_DIR && cd $BACKEND_DIR && wget -cq https://github.com/$BACKEND_REPO/releases/latest/download/dist.tar.gz -O - | tar -xz)

FRONTEND_REPO=SlvCtrlPlus/slvctrlplus-frontend
FRONTEND_DIR=/usr/share/slvctrlplus-frontend
FRONTEND_VERSION=$(get_latest_release $FRONTEND_REPO)
echo "=> Update frontend to version $FRONTEND_VERSION..."
(mkdir -p $FRONTEND_DIR && cd $FRONTEND_DIR && wget -cq https://github.com/$FRONTEND_REPO/releases/latest/download/dist.tar.gz -O - | tar -xz)

echo "=> Restart server..."
pm2 restart slvctrlplus-server

echo "=> Done!"
EOF
chmod +x "$SERVICE_HOME/update-slvctrlplus.sh"
chown "$SERVICE_USER:$SERVICE_USER" "$SERVICE_HOME/update-slvctrlplus.sh"

echo "=> Done! SlvCtrl+ is now running and will start automatically on boot."
echo "   Visit http://<your-pi-ip>/ in your browser to access the frontend."
