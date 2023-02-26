# Setting up SlvCtrl+ on a Raspberry Pi

## Prepare the system
```bash
$ sudo apt-get update && apt-get upgrade
$ sudo apt-get install nginx git
$ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
$ source ~/.bashrc
$ nvm install 18 && nvm use 18
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

## Download source code
```bash
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-frontend.git /usr/share
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-server.git /usr/share
$ # Optional: Switch to the branch you want to use
```

## Transpile server
```bash
$ cd /usr/share/slvctrlplus-server
$ sudo tsc
```

## Transpile frontend
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
