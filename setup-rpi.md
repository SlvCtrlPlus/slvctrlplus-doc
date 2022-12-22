# Setting up SlvCtrl+ on a RPi

## Prepare the system
```bash
$ sudo apt-get update && apt-get upgrade
$ sudo apt-get install nginx git
$ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
$ sudo nvm install 18 && nvm use 18
```

## Download source code
```bash
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-frontend.git /usr/share
$ sudo git clone https://github.com/SlvCtrlPlus/slvctrlplus-server.git /usr/share
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
todo
