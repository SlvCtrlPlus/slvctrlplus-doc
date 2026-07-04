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
| `onEvent('deviceConnected', async (device) => {})` | Executed every time a new device was connected. |
| `onEvent('deviceDisconnected', async (device) => {})` | Executed every time a device was disconnected. |
| `onEvent('deviceRefreshed', async (device) => {})` | Executed every time new data has been pulled from a device. |
| `onEvent('deviceNotification', async (device, notificationData) => {})` | Executed every time a device sends a notification. |
| `onStart(async () => {})` | Executed once at automation script start |
| `onStop(async () => {})` | Executed once at automation script stop |

### Available variables

#### Globally

|  Variable | Description |
|-----------|-------------|
| `devices` | Provides access to all connected devices. `device.getDeviceById('device-uuid')` will return the device instance if it's connected or `null` if no device with such id was found. |

#### onEvent

|  Variable | Description |
|-----------|-------------|
| `device` | Hold a reference to the device instance that triggered the event. |

## Examples

### Simple script
This script logs the string "hello world" everytime any event gets fired for any device.
```javascript
onStart(async () => console.log('script started'));

onEvent(async () => console.log('hello world'));

onStop(async () => console.log('script stopped'));
```

### Event selection
This script logs the string "deviceRefreshed" everytime a `deviceRefreshed` event gets fired for any device.
```javascript
onEvent('deviceRefreshed', async (event) => {
    console.log('deviceRefreshed');
});
```

### Device selection
This script logs the string "this is the device you are looking for" everytime a `deviceRefreshed` event gets fired for the device with 
the id `filtered-device-uuid`.
```javascript
onEvent('deviceRefreshed', async (device) => {
    if ('filtered-device-uuid' !== device.getDeviceId) {
        return;
    }

    console.warn('this is the device you are looking for');
});
```

### Write/access attribute of a device
This script logs the string "Example attribute's value is: ..." everytime a `deviceRefreshed` event gets fired for the device with
the id `filtered-device-uuid` and the value "new value" is written to the `example` attribute of the device.
```javascript
onEvent('deviceRefreshed', async (device) => {
    if ('filtered-device-uuid' !== device.getDeviceId) {
        return;
    }

    const exampleAttribute = await event.device.getAttribute('example');

    console.log(`Example attribute's value is: ${exampleAttribute}`);

    try {
        await device.setAttribute('example', 'new value');
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
