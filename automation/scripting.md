# Scripting
SlvCtrl+ provides the option of interconnecting different components to each other by scripts. The scripting
environment can be found under the "Automation" menu item.

## General usage
The scripting environment allows a user to execute automations (scripts) that are written in JavaScript. It further
allows to save such scripts for later usage.

Scripts can be deleted by clicking on the bin icon next to each entry in the select box. With the "create" button a new
script can be created.

The script can be written or copied into the coding editor and then been run by clicking on the "run" button in the
bottom left. Once the script runs, the "run" button changes to "stop" and logs of the script can be viewed by clicking
on the "logs" button next to the "stop" button.

The script will be triggered on each occurrence of one of the following events:

* `deviceUpdateReceived`: A device got updated through the external API
* `deviceRefreshed`: New data has been pulled from a device
* `deviceConnected`: A new device was connected
* `deviceDisconnected`: A device was disconnected

## Available variables

|  Variable | Description |
|-----------|-------------|
| `event` | Provides information about the event that triggered the script execution. `event.type` contains the name of the event and `event.device` contains the device instance that triggered the event. |
| `devices` | Provides access to all connected devices. `device.getDeviceById('device-uuid')` will return the device instance if it's connected or `null` if no device with such id was found. |
| `context` | Provides a simple key-value storage object which is persistent across all script invocations during a single run. Key can be chosen freely. |

## Examples

### Simple script
This script logs the string "hello world" everytime any event gets fired for any device.
```javascript
console.log('hello world');
```

### Event selection
This script logs the string "deviceUpdateReceived" everytime a `deviceUpdateReceived` event gets fired for any device.
```javascript
if ("deviceUpdateReceived" !== event.type) {
    return;
}

console.log("deviceUpdateReceived")
```

### Device selection
This script logs the string "this is the device you are looking for" everytime an event gets fired for the device with 
the id "filtered-device-uuid".
```javascript
if ("filtered-device-uuid" !== event.device.getDeviceId) {
    return;
}

console.log("this is the device you are looking for")
```

### Write/access attribute of a device
This script logs the string "Example attribute's value is: ..." everytime an event gets fired for the device with
the id "filtered-device-uuid" and the value "new value" is written to the `example` attribute of the device.
```javascript
if ("filtered-device-uuid" !== event.device.getDeviceId) {
    return;
}

const exampleAttribute = event.device.getAttribute('example');

console.log("Example attribute's value is: " + exampleAttribute);

event.device.setAttribute('example', 'new value');
```

### Access different devices
This script logs the uuid of a specifically selected device everytime an event gets fired for any device.
```javascript
const otherDevice = devices.getById('this-other-device-uuid');

console.log(otherDevice.deviceId);
```

### Usage of context
This script uses the `context` variable to store a counter that increases for every event fired by any device. And
prints out the counter. It is persistent between script executions during a single run.

```javascript
// Initialize counter and inStroke variable in context
if (!('init' in context)) {
    context.init = true;
    context.counter = 0;
}

context.counter++;

console.log(context.counter);
```
