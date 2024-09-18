## Introduction
This is a substitute for the official mappAssetInt package. The goal is to provide a community version that almost matches the official version. 

## Compatibility

Here is a short list of differences between the official mappAssetInt and the community version. For the detailed description see the [compatibility](compatibility/compatibility.md) page.

### What is missing

* There is no configuration file in Automation Studio under the configuration view. The configuration is done in the task code.
* There is no integration for mappAlarmX. Since the official version only supported 3 alarms this was removed. The community version provides a rich set of status information that can be used to trigger alarms. See [appendix](appendix.md) for the corresponding error numbers and the [FAQ](faq/faq.md) for more information.

### What is different

#### General

* The prefix of all function block names was changed from Mp to ex. For example MpAssetIntCore was changed to exAssetIntCore.
* The prefix of all data type names was changed from Mp to ex. For example MpAssetIntCoreInfoType was changed to exAssetIntCoreInfoType. The new structures are identical to the official structures. All exceptions are documented in the [compatibility](compatibility/compatibility.md) page.
* The MpLink was replaced with a remanent variable of type exAssetIntLinkType. This structure is used to store important data during power off and for cross communication between function blocks.
* All data is stored in a ring buffer consisting of individual files. Each file contains one event. An event can be job or shift change or a downtime event. You can find more details about the data management in the [appendix](appendix.md).
* The parameter "EnableFileBackup" is no longer required and was removed from the core config structure. The data is always stored in the flash memory.
* The parameters "SaveInterval", "RecordMemory", "RecordingSizeShiftStatistics" and "RecordingSizeJobStatistics" are no longer required and were removed from the general config structure.
* The data structure "exAssetIntUITimelineOutputType" was adjusted to match the other UI structures. Al data from the parameter "Display" was moved one level up to "UIConnect.Output".

#### exAssetIntShiftListUI

* The parameter UISetup.OutputListSize was removed. The list size is now defined by the constant UI_SHIFT_LIST_IDX.
* The parameter UISetup.SortingStartTime was added to allow for ascending and descending sorting.

#### exAssetIntJobListUI

* The parameter UISetup.OutputListSize was removed. The list size is now defined by the constant UI_JOB_LIST_IDX.
* The parameter UISetup.SortingStartTime was added to allow for ascending and descending sorting.

#### exAssetIntTimelineUI

* The parameter UISetup.TimelineListSize was removed. The list size is now defined by the constant UI_TIMELINE_IDX.
* The parameter UISetup.SortingStartTime was added to allow for ascending and descending sorting.
* All parameters from UIConnect.Output.Display were move one level up to UIConnect.Output to harmonize the data structure with the other function blocks.

### What is new

* Most function blocks have an additional Logger input. This is used to log messages to the console. This is useful for debugging purposes.
* Job events can also be listed in the shift UI list. This can be changed with the UI_SHIFT_SHOW_JOBS constant.
* User name changes are logged in the timeline.
* User downtime reason changes are logged in the timeline.

## Future development
The goal for version 1.x is to have a complete set of functions that match the official mappAssetInt package. Version 2.x will focus on adding new features and improvements and will be optimized to work with mappView.

## Requirements
The sample was developed with Automation Studio 4.12 but may also work with versions below that.



