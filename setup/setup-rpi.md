# Setting up SlvCtrl+ on a Raspberry Pi

## Prepare the system
```bash
$ sudo apt-get update && apt-get upgrade
$ sudo apt-get install nginx git
$ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
$ source ~/.bashrc
$ nvm install 18 && nvm alias default node && nvm use 18
$ npm install --global yarn
$ yarn global add pm2
```

Make sure Serial Port is enabled:

```bash
$ sudo raspi-config
```

Select `3 Interface Options`, then `I6 Serial Port` and make sure to enable it (`Yes`).

## Optional: Disable Bluetooth
It can be that SlvCtrl+ has a memory leak. This is caused by the Serialport library used for the communication with the components on certain Raspberry Pi models. To prevent the memory leak, Bluetooth needs to be disabled on the Raspberry Pi:

```bash
sudo echo "dtoverlay=disable-bt" >> /boot/config.txt
```

## Option 1: Use prebuilt version (recommended)
```bash
#!/bin/bash

echo "=> Install backend..."
(DIR=/usr/share/slvctrlplus-server && mkdir -p $DIR && cd $DIR && wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-server/releases/latest/download/dist.tar.gz -O - | tar -xz)

echo "=> Install frontend..."

(DIR=/usr/share/slvctrlplus-frontend && mkdir -p $DIR && cd $DIR && wget -cq https://github.com/SlvCtrlPlus/slvctrlplus-frontend/releases/latest/download/dist.tar.gz -O - | tar -xz)

echo "=> Done!"
```

## Option 2: Build from source
### Download source code
```bash
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-frontend.git /usr/share
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-server.git /usr/share
$ # Optional: Switch to the branch you want to use
```

### Transpile server
```bash
$ cd /usr/share/slvctrlplus-server
$ sudo tsc
```

### Transpile frontend
```bash
$ cd /usr/share/slvctrlplus-frontend
$ sudo yarn install && yarn run build
```

## Setup nginx
```bash
$ sudo vim /etc/nginx/sites-available/default
```

File content:

```
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /usr/share/slvctrlplus-frontend/dist/;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		include  /etc/nginx/mime.types;
		index index.html;

		try_files $uri $uri/ /index.html;
	}
}
```

## Setup pm2
Create the app config:

```bash
$ sudo mkdir -p /etc/pm2
$ sudo vim /etc/pm2/apps.config.js
```

Config file content:
```js
module.exports = {
  apps : [
      {
        name: "slvctrlplus-server",
        script: "/usr/share/slvctrlplus-server/dist/index.js",
        env: {
          "PORT": 1337,
          "LOG_LEVEL": "info",
        }
      }
  ]
}
```

Set pm2 to start on boot:
```bash
$ sudo pm2 startup
$ sudo pm2 start /etc/pm2/apps.config.js
```

## Update script
These are pre-baked scripts you can save into your home directory as `update-slvctrlplus.sh` and run them with the 
command `sudo  ./update-slvctrlplus.sh`.

### Option 1: Prebuilt version
This update to the latest release using the prebuilt versions.

```bash
#!/bin/bash

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
```

### Option 2: Build from source
This is a script that can be run to update server and frontend component once they were set up like described above. 
All manual changes that were made will be reset by this script.

```bash
#!/bin/bash

echo "=> Update backend..."
(cd /usr/share/slvctrlplus-server && git reset --hard && git pull && rm -rf node_module/ && yarn install && tsc)

echo "=> Update frontend..."
(cd /usr/share/slvctrlplus-frontend && git reset --hard && git pull && rm -rf node_module/ && yarn install && yarn run build)

echo "=> Restart server..."
pm2 restart slvctrlplus-server

echo "=> Done!"
```

## Setup ad-hoc network mode
If you want to use your SlvCtrl+ RPi when you're out and about, there's the possibility to create an ad-hoc network on the RPi to connect to it using a tablet 
or phone without any intermediary router or internet connection. To do so, [there's a guide and script available here](https://www.raspberryconnect.com/projects/65-raspberrypi-hotspot-accesspoints/183-raspberry-pi-automatic-hotspot-and-static-hotspot-installer).
