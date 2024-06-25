## Appendix

### How the data is stored

Short term data like piece counters are stored in the remanent variable of type `exAssetIntLinkType`. This structure is used for cross function block communication. The short term data will survive a power off but not a cold reboot. 

All long term data is stored in a ring buffer consisting of individual files on the user partition. The data is spread over multiple directories to speed up the reading process during boot-up. Data on this user partition will survive restarts and even program updates and be backed up if necessary. Each file contains one event. An event can be a production state, job or shift change or a downtime event. The total number of stored events can be adjusted with the constant `CORE_EVENT_NUM_MAX`. Keep in mind that all events must be loaded on boot-up which can take some time. As a ball park figure, it takes about 4 seconds to load 100 events.

### Constants

#### Common

| Name | Type | Value | Description |
|------|------|-------|-------------|
| CORE_EVENT_NUM_MAX | UINT | 500 | Maximum number of events |
| CORE_EVENT_DIR_MAX | UINT | 1000 | Maximum number of events in one directory |
| EVENT_ADDITONAL_DATA_LEN | UINT | 100 | Length of the event comment |
| EXPORT_BUFFER | UINT | 500 | Length of the buffer for the event export |
| EXPORT_JOB_TITEL | STRING[100] | 'AssetInt Job Statistics Export File' | Export file header |
| EXPORT_SHIFT_TITEL | STRING[100] | 'AssetInt Shift Statistics Export File' | Export file header |
| EXPORT_TIMELINE_TITEL | STRING[100] | 'AssetInt Timeline Statistics Export File' | Export file header |
| EXPORT_JOB_HEADER | STRING[400] | 'Job Start Time;Job End Time;Job Name;...' | Export file column headers |
| EXPORT_SHIFT_HEADER | STRING[400] | 'Job Start Time;Job End Time;Job Name;...' | Export file column headers |
| EXPORT_TIMELINE_HEADER | STRING[400] | 'Start Time;Shift ID;Production State;...' | Export file column headers |
| UI_SHIFT_LIST_IDX | UINT | 8 | Max index for list box entries for shift data |
| UI_JOB_LIST_IDX | UINT | 8 | Max index for list box entries for job data |
| LOG_LEN | UINT | 100 | Length of one log entry (minimum size is 50) |
| LOG_NUM | UINT | 50 | Number of log entries |
| LOG_LEVEL | exAssetIntLogLevelEnum | exASSETINT_LOG_ALL | Define log level details |
| CHAR_RETURN | USINT | 13 | Carriage return |

#### Errors

| Name | Type | Value | Description |
|------|------|-------|-------------|
| ERR_ASSET_LINK | DINT | -1064239102 | Input exLink is 0 pointer |
| ERR_ASSET_TEMP_MEMORY | DINT | -1064136704 | No temporary memory available, make sure core function block is enabled |
| ERR_ASSET_INF_WAIT_CORE_FB | DINT | 1083346949 | This component can only become active if MpAssetIntCore is active. |
| ERR_ASSET_READ_RECORD_SIZE | DINT | -2138009590 | Record size is not correct during reading event data |
| ERR_ASSET_READ_CRC | DINT | 100000 | Record CRC error during reading event data |
| ERR_ASSET_CONFIG | DINT | -1064239096 | Configuration link is 0 pointer |
| ERR_ASSET_SHIFT_CALC | DINT | -1064239097 | Invalid shift configured |