# Scripting
SlvCtrl+ provides the option of interconnecting different components to each other by scripts. The scripting
environment can be found under the "Automation" menu item.

## General usage
The scripting environment allows a user to execute automations (scripts) that are written in JavaScript or TypeScript. It further
allows to save such scripts for later usage.

Scripts can be deleted by clicking on the bin icon next to each entry in the select box. With the "create" button a new
script can be created.

The script can be written or copied into the coding editor and then been run by clicking on the "run" button in the
bottom left. Once the script runs, the "run" button changes to "stop" and logs of the script can be viewed by clicking
on the "logs" button next to the "stop" button.

The script has three hooks:

|  Hook     | Description |
|-----------|-------------|
| `onEvent(async (event) => {})` | Executed for every event listed below. |
| `onStart(async () => {})` | Executed once at automation script start |
| `onStop(async () => {})` | Executed once at automation script stop |

## onEvent's event.type

The value of `event.type` can be one of these:

* `deviceRefreshed`: New data has been pulled from a device
* `deviceConnected`: A new device was connected
* `deviceDisconnected`: A device was disconnected

### Available variables

#### Globally

|  Variable | Description |
|-----------|-------------|
| `devices` | Provides access to all connected devices. `device.getDeviceById('device-uuid')` will return the device instance if it's connected or `null` if no device with such id was found. |

#### onEvent

|  Variable | Description |
|-----------|-------------|
| `event` | Provides information about the event that triggered the script execution. `event.type` contains the name of the event and `event.device` contains the device instance that triggered the event. |

## Examples

### Simple script
This script logs the string "hello world" everytime any event gets fired for any device.
```javascript
onStart(async () => console.log('script started'));

onEvent(async () => console.log('hello world'));

onStop(async () => console.log('script stopped'));
```

### Event selection
This script logs the string "deviceUpdateReceived" everytime a `deviceUpdateReceived` event gets fired for any device.
```javascript
onEvent(async (event) => {
    if ("deviceUpdateReceived" !== event.type) {
        return;
    }

    console.log("deviceUpdateReceived");
});
```

### Device selection
This script logs the string "this is the device you are looking for" everytime an event gets fired for the device with 
the id "filtered-device-uuid".
```javascript
onEvent(async (event) => {
    if ("filtered-device-uuid" !== event.device.getDeviceId) {
        return;
    }

    console.warn("this is the device you are looking for");
});
```

### Write/access attribute of a device
This script logs the string "Example attribute's value is: ..." everytime an event gets fired for the device with
the id "filtered-device-uuid" and the value "new value" is written to the `example` attribute of the device.
```javascript
onEvent(async (event) => {
    if ("filtered-device-uuid" !== event.device.getDeviceId) {
        return;
    }

    const exampleAttribute = await event.device.getAttribute('example');

    console.log("Example attribute's value is: " + exampleAttribute);

    try {
        await event.device.setAttribute('example', 'new value');
    } catch(e) {
        console.error(e);
    }
});
```

### Access any connected device
This script logs the uuid of a specifically selected device everytime an event gets fired for any device.
```javascript
const otherDevice = devices.getById('this-other-device-uuid');

console.log(otherDevice.deviceId);
```
