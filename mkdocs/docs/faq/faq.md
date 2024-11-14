## FAQs

### How is the data recorded?

Data is only recorded when the PLC is running and the current time is within the configured shift times and there is no scheduled or unscheduled downtime. Is the PLC is turned of during a shift the time is not considered downtime. 

### How and where is the data stored?

Short term data like piece counters are stored in the remanent variable of type `exAssetIntLinkType`. This structure is used for cross function block communication. The short term data will survive a power off but not a cold reboot. 

All long term data is stored in a ring buffer consisting of individual files on the user partition. Data on this user partition will survive restarts and even program updates and be backed up if necessary. Each file contains one event. An event can be job or shift change or a downtime event. The total number of stored events can be adjusted with the constant `CORE_EVENT_NUM_MAX`. Keep in mind that all events must be loaded on boot-up which can take some time. As a ball park figure, it takes about 4 seconds to load 100 events.

When the data is loaded all files are checked against a CRC as well as the file size. If a file is corrupt it is deleted and the error is logged. To recover from this error the input `ErrorReset` must be set to true. When there are no more corrupt files the system will recover and continue to load the remaining files. Only one file is deleted at a time.

### What task class should be used?
It is recommended to use task class #8 with a 10ms cycle time.

### How do I increase the number of events stored?

The constant `CORE_EVENT_NUM_MAX` defines the maximum number of events that can be stored. This number can be increased to store more events. Keep in mind that all events must be loaded on boot-up which can take some time.

### How can I diagnose a problem with the function block?

Most function blocks have an additional Logger input. This logger provides detailed information about events that occur inside the framework. The log level can be set with the constant `LOG_LEVEL`. The default log level is `exASSETINT_LOG_ERROR`. The log level can be set to `exASSETINT_LOG_OFF` to disable logging. The log level can be set to `exASSETINT_LOG_ALL` to log everything. The log level can be set to `exASSETINT_LOG_INFO` to log errors, warnings, and information messages. The log level can be set to `exASSETINT_LOG_ALL` to log everything. Only use `exASSETINT_LOG_ALL` for debugging purposes as it can slow down the system.

All functions blocks have an additional `StatusID` output. Check the appendix for the corresponding error numbers. 

Most function blocks have an additional `Info` output. This structure contains additional information about the function block. 