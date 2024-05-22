## Test case
The following test cases were performed to verify the functionality of the AssetInt component.

#### Test Case 1

##### Preset
Shift 1 start 06:00 end 14:00
Shift 2 start 14:30 end 22:00

##### Test Steps
* Set time to 13:55
* Let PLC run for 2 minutes
* Power off PLC for 5 minutes
* Turn PLC back on

##### Expected Result
* PLC should log shift with 3 minutes
* PLC should not log any data after power on since the timne is 14:02 and there is no shift defined for this time



