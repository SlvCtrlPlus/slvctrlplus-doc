# Connecting Buttplug.io to SlvCtrl+

Thanks to the work of [@drone4770](https://github.com/drone4770) SlvCtrl+ supports buttplug.io.

## Install Intiface engine

Install either the newest release of the [Intiface engine](https://github.com/intiface/intiface-engine/releases/latest) if you're running SlvCtrl+ on a headless operating system or install [Intiface central](https://github.com/intiface/intiface-central/releases/latest) if you're on an operating system with a window manager.

## Add source to SlvCtrl+ config

First make sure SlvCtrl+ server is not running.

Add the source to your SlvCtrl+ config file (`~/.slvctrlplus/settings.json`) after any other configured source (i.e. `...` in below code snippet).

```json
    "deviceSources": {
        ...,
        "f263e3ef-f6f5-4df2-b2cd-2c4d87ab7058": {
            "id": "f263e3ef-f6f5-4df2-b2cd-2c4d87ab7058",
            "type": "buttplugIoWebsocket",
            "config": {
                "address": "127.0.0.1:12345"
            }
        }
    }
```

Start SlvCtrl+ server. The new configuration should be picked up.
