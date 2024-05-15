The axis configuration sample provides an example how to change a axis configuration during runtime. **After changing the axis parameters the PLC must be reboot for the changes to take affect.** The function block MC_BR_ProcessConfig used in this example does not check parameter values for correctness. It is therefore necessary to check the axis for errors after writing new parameters through the PLC logger or the function block MC_ReadAxisError.

<table style="width: 100%">
    <colgroup>
       <col span="1" style="width: 60%;">
    </colgroup>
    <tr>
        <td>
            <img src="./screenshot_as.png" />
        </td>
        <td>
            <img src="./screenshot_web.png" />
        </td>
    </tr>
</table>

Also see 

* Automation Studio help for a description of MC_BR_ProcessConfig (9c2eadae-8494-4e9a-b305-0afa2dabf1d4)
* Automation Studio help for a description of the axis parameter (18353d93-e907-436f-90d9-d2a80bd7f7ac)

## Repo Link
[Here](https://github.com/br-automation-com/mappMotion-Samples/tree/axis_cfg) is the link to the repository.

## Interface structure

The sample uses a variable structure to communicate with the outside world that can also be used to interact with other tasks. The structure looks as follows:

| Command | Function |
|---|---|
| CmdSetAxis | Set the new axis parameters |
| CmdGetAxis | Get the active axis parameters |
| CmdReboot | Reboot PLC |
| MpLink | The axis reference establishes the connection between the function block and an axis |
| ParAxis | Axis parameters for set command |
| StaAxis | Axis parameters get command |
| ErrId | Error ID |

## Program structure

<table style="width: 100%">
    <colgroup>
       <col span="1" style="width: 40%;">
    </colgroup>
    <tr>
        <td>
            <img src="./screenshot_package.png" />
        </td>
        <td>
            The axis parameter can be outsourced into an extra file with just the axis parameters. This has the advantage that the axis configuration can be changed easily without changing any source code in the proto type.
        </td>
    </tr>
</table>

The program consists of a state machine to execute the commands. The B&R function block that changed the axis configuration needs a name path and not just the MpLink. This name is constructed automatically in the step STATE_AXIS_CFG_PRE_SET. From this step the state machine goes to the read or write state. The axis parameter can be provided as a separate file or action (see example). It is also possible to set the parameters directly in the structure ParAxis.

After changing the axis parameters the PLC must be reboot for the changes to take affect.

## Sample code
Here is a sample snippet that can be used as a starting point.

##### Program init
```
PROGRAM _INIT
	// --------------------------------------------------------------------------
	// Axis configuration
	AxisCfg.MpLink := ADR(gAxis_1);			// MpLink for axis
	AxisConfigSample;						// Axis sample configuration
	 
END_PROGRAM
```

##### Program cyclic
```
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------
	// Call axis actions used for this drive
	AxisCfgAction;	    // Call axis configuration code
	 
END_PROGRAM
```

## Revision

Version 3

* Removed dependency from common
* New internal structure

Version 2

* Renamed function block 
* Don't read before write
* Minor tweaks

Version 1

* First release


