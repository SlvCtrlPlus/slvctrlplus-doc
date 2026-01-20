# Device support

## Buttplug.io

Thanks to the work of [@drone4770](https://github.com/drone4770) SlvCtrl+ supports buttplug.io.

### Install Intiface engine

Install either the newest release of the [Intiface engine](https://github.com/intiface/intiface-engine/releases/latest) if you're running SlvCtrl+ on a headless operating system or install [Intiface central](https://github.com/intiface/intiface-central/releases/latest) if you're on an operating system with a window manager.

### Add source to SlvCtrl+ config

First make sure SlvCtrl+ server is not running.

Add the source to your SlvCtrl+ config file (`~/.slvctrlplus/settings.json`) after any other configured source (i.e. `...` in below code snippet).

```json
    "deviceSources": {
        ...,
        "f263e3ef-f6f5-4df2-b2cd-2c4d87ab7058": {
            "id": "f263e3ef-f6f5-4df2-b2cd-2c4d87ab7058",
            "type": "buttplugIoWebsocket",
            "config": {
                // Address to the buttplug.io websocket server
                "address": "127.0.0.1:12345"
            }
        }
    }
```

Start SlvCtrl+ server. The new configuration should be picked up.

## E-Stim Systems 2B

### Add source to SlvCtrl+ config

First make sure SlvCtrl+ server is not running.

Add the source to your SlvCtrl+ config file (`~/.slvctrlplus/settings.json`) after any other configured source (i.e. `...` in below code snippet).

```json
    "deviceSources": {
        ...,
        "5d9ce14d-219f-41d1-8b2b-2340165d009a": {
            "id": "5d9ce14d-219f-41d1-8b2b-2340165d009a",
            "type": "estim2bSerial",
            "config": {}
        }
    }
```

Start SlvCtrl+ server. The new configuration should be picked up.

### Connecting

Make sure the E-Stim Systems 2B device is turned on and fully booted up first, then connect the USB cable to the USB port on your host device running SlvCtrl+.
The device should then be detected automatically after a few seconds.

## CrashOverride85's ZC95

### Add source to SlvCtrl+ config

First make sure SlvCtrl+ server is not running.

Add the source to your SlvCtrl+ config file (`~/.slvctrlplus/settings.json`) after any other configured source (i.e. `...` in below code snippet).

```json
    "deviceSources": {
        ...,
        "0c8db386-6b07-4832-855f-9519429d5616": {
            "id": "0c8db386-6b07-4832-855f-9519429d5616",
            "type": "zc95Serial",
            "config": {}
        },
    }
```

Start SlvCtrl+ server. The new configuration should be picked up.

### Connecting

Make sure the ZC95 device is turned on and fully booted up first, then connect the USB cable to the USB port on your host device running SlvCtrl+.
The device should then be detected automatically after a few seconds.
