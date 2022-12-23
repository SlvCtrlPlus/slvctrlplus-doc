# SlvCtrl+ protocol 1.0 (DRAFT!)

:warning: This protocol version is not yet implemented/supported!

## General
### Command separation
The commands and their responses always need to be separated by a new line (`\n`).

## Commands
### Command `introduce`
This is the first command the server sends to the component once it established a successful serial connection.
The component needs to answer this command with some basic information about itself. (See *Response* section)

#### Request
No parameters

#### Response
```
introduce;{device type: string},{firmware version: int},{protocol version: int}
```

Example: 
```
introduce;air_valve,10223,1
```

The number `10223` will be read as `1.2.23`.

### Command `status`
Returns the current status of the component. It returns a comma separated property/value list.

#### Request
No parameters

#### Response
```
status[;{property name 1}:{value 1},{property name 2}:{value 2},...]
```

Example:
```
status;flow:55
```

### Component specific/custom commands
The component may implement custom commands to make it possible to tweak certain values or read some specific 
information.

The command names should only contain lower case letters a-z, numbers and dashes and should have at least the length 
of 1 (`^[a-z0-9-]+$`).

Parameters can be provided as a comma separated list: `custom-command,param1,param2,...`.

The response should always contain the command name plus all its parameters with an optional additional 
property/value list: `custom-command,param1,param2;operation:successful`.

## Complete example
* `-->` describes input the server sends to the component
* `<--` describes output the component returns as response to a command sent by the server to the component

```
--> introduce\n
<-- introduce;air_valve,10223,1\n
--> status\n
<-- status;flow:100\n
--> set-flow,50\n
<-- set-flow,50;operation:successful\n
--> get-current-flow\n
<-- get-current-flow;flow:50\n
```