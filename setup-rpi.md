# Setting up SlvCtrl+ on a RPi

## Prepare the system
```bash
$ sudo apt-get update && apt-get upgrade
$ sudo apt-get install nginx git
$ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
$ sudo nvm install 18 && nvm use 18
```

## Optional: disable Bluetooth
It can be that SlvCtrl+ has a memory leak. This is caused by the Serialport library used for the communication with the components on certain Raspberry Pi models. To prevent the memory leak, Bluetooth needs to be disabled on the Raspberry Pi:

```bash
echo "dtoverlay=disable-bt" >> /boot/config.txt
```

## Download source code
```bash
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-frontend.git /usr/share
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-server.git /usr/share
$ # Optional: Switch to the branch you want to use
```

## Compile server
```bash
$ cd /usr/share/slvctrlplus-server
$ sudo yarn install && yarn run build
```

## Compile frontend
```bash
$ cd /usr/share/slvctrlplus-frontend
$ sudo yarn install && yarn run build
```

## Setup nginx
todo

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
