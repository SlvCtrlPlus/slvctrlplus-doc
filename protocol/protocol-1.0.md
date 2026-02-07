# SlvCtrl+ protocol 1.0 (DRAFT!)

:warning: This protocol version is not yet implemented/supported!

## General
### Command separation
The commands and their responses always MUST be separated by a new line (`\n`).


### Parameter separation
A command's parameters MUST be separated by a space:
```
set flow 50 100
```
In the example above the command is `set` with three arguments: `flow`, `50` and `100`.

### Command response
If a command is sent, a response MUST be sent back. It MUST include the original command and all its
arguments and additional information segments separated by `;` (semicolons). The `status` information MUST always be included 
in the response:

```
set flow 50 100;status:ok
```

#### Possible values for `status` information
| State  | Description |
|--------|-------------|
| `ok` | Command processed successfully |
| `error`     | The command was not processed successfully by the device |
| `unknown`    | Currently it's unknown whether processin the command was successful or not |

## Commands
The following described minimum set of commands MUST be implemented.

### Command `introduce`
This is the first command the server sends to the component once it established a successful connection.
The component MUST answer this command with some basic information about itself. (See *Response* section)

#### Request
No parameters

#### Response
```
introduce;type:{device type: string},fw:{firmware version: int},protocol:{protocol version: int};status:ok
```

Example: 
```
introduce;type:air_valve,fw:110223,protocol:10000;status:ok
```

The number `110223` MUST be read as `11.2.23`.
The number `10000` MUST be read as `1.0.0`.

### Command `attributes`
Returns a list of attributes this component offers for read and/or write.

The attribute names MUST only contain lower and upper case letters (`A-Za-z`), numbers (`0-9`), dashes (`-`) 
and underscores (`_`) and MUST have at least the length of 1 (`^[A-Za-z0-9_-]+$`).
The name `status` MUST NOT be used for an attribute and is a reserved keyword.

### Request
No parameters

### Response
```
attributes[;{attribute name}:{attribute type}[{data type}],...];status:ok
```

Example:
```
attributes;flow:rw[int(0..100)],pressure:ro[int(10..20)];status:ok
```

#### Attribute types
| Type   | Description |
|--------|-------------|
| `ro`   | read-only, attribute can only be read |
| `wo`   | write-only, attribute can only be written |
| `rw`   | read-write, attribute can be read and written |

#### Data types
| Type   | Description | Example |
|--------|-------------|---------|
| String  | Any string  | `str` |
| Integer | An integer | `int` |
| Float   | A float | `float` |
| Boolean | A boolean | `bool` |
| List    | A list of options (of any other data type) | <code>foo&#124;bar&#124;baz</code> or <code>8&#124;16&#124;32&#124;64</code> |
| Range   | A range | `int/0..100` (of either integer or float) |

### Command `status`
Returns the current status of the component. It MUST return a comma separated list with all attributes and their values.
If a value cannot be determined, the value MUST be empty.

#### Request
No parameters

#### Response
```
status[;{attribute name 1}:{value 1},{attribute name 2}:{value 2},...];status:ok
```

Example:
```
status;flow:55,pressure:10;status:ok
```

Example in case value cannot be determined at the moment:
```
status;flow:,pressure:10;status:ok
```

Write-only attributes MUST be omitted in the status response.

### Attribute commands `get ...` and `set ...`
The component MUST implement a command to get a value and/or write a value for each attribute.

The command name MUST be `get` or `set` depending on whether they read or write the attribute.

The `get` MUST accept exactly one parameter and the `set` commands MUST accept exactly two parameters.
The first paramter MUST be the attribute name for both, `get` and `set` commands. 
The second parameter MUST be the attribute value to be set in case of a `set` command.

The response of a set command MUST always contain the command name plus all its parameters with an additional 
property/value list which MUST contain at least a `status` about the outcome of the set command: `set flow 20;status:ok`.

If state is `error` or `unknown` an additional `reason` field MAY bet set with more detailed information (error code, etc).

#### Response
The response of a `get` command MUST return the complete command as sent (including the attribute name).
If the value cannot be determined the value list MUST be empty.

Example in case of success:
```
get flow;value:50;status:ok
```

Example if value cannot be determined at the moment:
```
get flow;value:;status:unknown;reason:in_motion
```

## Complete example
* `-->` describes input the server sends to the component
* `<--` describes output the component returns as response to a command sent by the server to the component

```
--> introduce\n
<-- introduce;type:air_valve,fw:10223,protocol:10000;status:ok\n
--> attributes
<-- attributes;flow:rw[int/0..100],pressure:ro[int/10..20];status:ok
--> status\n
<-- status;flow:100;status:ok\n
--> set flow 50\n
<-- set flow 50;status:error;reason:value_out_of_range\n
--> set flow 50\n
<-- set flow 50;status:ok\n
--> get flow\n
<-- get flow;value:50;status:ok\n
```
