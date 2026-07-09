#!/bin/bash

INSTALL_PATH=/usr/share

# Prepare system
echo "=> Prepare system..."
sudo apt-get update && apt-get upgrade
sudo apt-get install nginx git
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
source ~/.bashrc
nvm install 20 && nvm alias default node && nvm use 20
npm install --global yarn
yarn global add pm2

# Enable serial
echo "enable_uart=1" >> /boot/config.txt

# Disable bluetooth (uncomment if SlvCtrl+ has a memory leak)
#sudo echo "dtoverlay=disable-bt" >> /boot/config.txt

# Install SlvCtrl+
echo "=> Install backend..."
(DIR=$INSTALL_PATH/slvctrlplus-server && mkdir -p $DIR && cd $DIR && wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-server/releases/latest/download/dist.tar.gz -O - | tar -xz)

echo "=> Install frontend..."

(DIR=$INSTALL_PATH/slvctrlplus-frontend && mkdir -p $DIR && cd $DIR && wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-frontend/releases/latest/download/dist.tar.gz -O - | tar -xz)

# Setup nginx
echo "=> Configure nginx..."
sudo echo "server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root $INSTALL_PATH/slvctrlplus-frontend/dist/;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		include  /etc/nginx/mime.types;
		index index.html;

		try_files \$uri \$uri/ /index.html;
	}
}" > /etc/nginx/sites-available/default

sudo service nginx reload

# Setup pm2
echo "=> Configure pm2..."
PM2_CONFIG_FILE=/etc/pm2/apps.config.js
sudo mkdir -p /etc/pm2
sudo echo "module.exports = {
  apps : [
      {
        name: \"slvctrlplus-server\",
        script: \"$INSTALL_PATH/slvctrlplus-server/dist/index.js\",
        env: {
          \"PORT\": 1337,
        }
      }
  ]
}" > $PM2_CONFIG_FILE
sudo pm2 startup
sudo pm2 start $PM2_CONFIG_FILE

# Create update script
echo "Save update script into $HOME..."
echo "#!/bin/bash

get_latest_release() {
  curl --silent \"https://api.github.com/repos/\$1/releases/latest\" | # Get latest release from GitHub api
    grep '\"tag_name\":' |                                            # Get tag line
    sed -E 's/.*\"([^\"]+)\".*/\1/'                                    # Pluck JSON value
}

BACKEND_REPO=SlvCtrlPlus/slvctrlplus-server
BACKEND_DIR=$INSTALL_PATH/slvctrlplus-server
BACKEND_VERSION=\$(get_latest_release \$BACKEND_REPO)
echo \"=> Update backend to version \$BACKEND_VERSION...\"
(mkdir -p \$BACKEND_DIR && cd \$BACKEND_DIR && wget -cq https://github.com/\$BACKEND_REPO/releases/latest/download/dist.tar.gz -O - | tar -xz)

FRONTEND_REPO=SlvCtrlPlus/slvctrlplus-frontend
FRONTEND_DIR=$INSTALL_PATH/slvctrlplus-frontend
FRONTEND_VERSION=\$(get_latest_release \$FRONTEND_REPO)
echo \"=> Update frontend to version \$FRONTEND_VERSION...\"
(mkdir -p \$FRONTEND_DIR && cd \$FRONTEND_DIR && wget -cq https://github.com/\$FRONTEND_REPO/releases/latest/download/dist.tar.gz -O - | tar -xz)

echo \"=> Restart server...\"
pm2 restart slvctrlplus-server

echo \"=> Done!\"" > $HOME/update-slvctrlplus.sh

echo "=> Done!"

# Reboot for the /boot/config.txt changes
echo "=> Rebooting now..."
sudo shutdown -r now
