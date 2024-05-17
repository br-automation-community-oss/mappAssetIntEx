## FAQs

### What task class should be used?
It is recommended to use task class #8 with a 10ms cycle time.

### How do I increase the number of events stored?

The constant `CORE_EVENT_NUM_MAX` defines the maximum number of events that can be stored. This number can be increased to store more events. Keep in mind that all events must be loaded on boot-up which can take some time. The constant `CORE_EVENT_DIR_MAX` defines the maximum number of events in one directory. Do not change this constant unless you know what you are doing.

### How can I diagnose a problem with the function block?

Most function blocks have an additional Logger input. This logger provides detailed information about events that occur inside the framework. The log level can be set with the constant `LOG_LEVEL`. The default log level is `exASSETINT_LOG_ERROR`. The log level can be set to `exASSETINT_LOG_OFF` to disable logging. The log level can be set to `exASSETINT_LOG_ALL` to log everything. The log level can be set to `exASSETINT_LOG_INFO` to log errors, warnings, and information messages. The log level can be set to `exASSETINT_LOG_ALL` to log everything. Only use `exASSETINT_LOG_ALL` for debugging purposes as it can slow down the system.

All functions blocks have an additional `StatusID` output. Check the appendix for the corresponding error numbers. 

Most function blocks have an additional `Info` output. This structure contains additional information about the function block. 