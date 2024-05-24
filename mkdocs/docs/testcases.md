## Test case
The following test cases were performed to verify the functionality of the AssetInt component.

#### Test case storage 1
This test verifies that the CRC is working correctly.

##### Preset
Trigger one event to create a file.

##### Test Steps
* Open the file
* Change a character in the file
* Close and save the file
* Power cycle PLC

##### Expected Result
* AssetInt should report an error and delete the corrupt file
* After ErrorReset or Enable 1->0->1 the AssetInt should recover

#### Test case storage 2
This test verifies that the file size is correct.

##### Preset
Trigger one event to create a file.

##### Test Steps
* Open the file
* Remove a character in the file
* Close and save the file
* Power cycle PLC

##### Expected Result
* AssetInt should report an error and delete the corrupt file
* After ErrorReset or Enable 1->0->1 the AssetInt should recover

#### Test case Shift 1
This test case verifies that the shift change is logged correctly.

##### Preset
Shift 1 start 06:00 end 14:00
Shift 2 start 14:30 end 22:00

##### Test Steps
* Set time to 13:55
* Let PLC run for 2 minutes
* Power off PLC for 5 minutes
* Turn PLC back on

##### Expected Result
* AssetInt should log shift with 3 minutes
* AssetInt should not log any data after power on since the time is 14:02 and there is no shift defined for this time



