
FUNCTION_BLOCK exAssetIntCore (*mapp function block which can be used for asset intensity calculation.*) (* $GROUP=mapp Services,$CAT=Asset Intensity,$GROUPICON=Icon_mapp.png,$CATICON=Icon_exOee.png *)
	VAR_INPUT
		exLink : REFERENCE TO exAssetIntLinkType; (*Incoming communication handle (mapp standard interface)*) (* *) (*#PAR#;*)
		Enable : BOOL; (*Enables/Disables the function block (mapp standard interface)*) (* *) (*#PAR#;*)
		ErrorReset : BOOL; (*Resets all function block errors (mapp standard interface)*) (* *) (*#PAR#;*)
		Parameters : REFERENCE TO exAssetIntParType; (*Function block parameters (mapp standard interface)*) (* *) (*#PAR#; *)
		Configuration : REFERENCE TO exAssetIntCoreConfigType;
		Logger : UDINT;
		Update : BOOL; (*Updates the parameters (mapp standard interface)*) (* *) (*#PAR#; *)
		Downtime : exAssetIntDowntimeEnum; (*The machine is in down time*) (* *) (*#CMD#; *)
		DowntimeReason : REFERENCE TO STRING[50]; (*The reason for down time*) (* *) (*#CMD#; *)
		PieceCounter : UDINT; (*Total pieces counter.*) (* *) (*#CMD#; *)
		RejectCounter : UDINT; (*Reject pieces counter*) (* *) (*#CMD#; *)
		DeviceName : REFERENCE TO STRING[50]; (*Address of the exported device name*) (* *) (*#CMD#; *)
		Export : BOOL; (*Export the saved information to file*) (* *) (*#CMD#; *)
		Reset : BOOL; (*Reset the data buffer*) (* *) (*#CMD#; *)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Function block is active (mapp standard interface)*) (* *) (*#PAR#;*)
		Error : BOOL; (*Indicates an error (mapp standard interface)*) (* *) (*#PAR#;*)
		StatusID : DINT; (*Error/Status information (mapp standard interface)*) (* *) (*#PAR#; *)
		UpdateDone : BOOL; (*Update of parameters done (mapp standard interface)*) (* *) (*#PAR#; *)
		CommandBusy : BOOL; (*Function block is busy processing a command*) (* *) (*#CMD#OPT#;*)
		CommandDone : BOOL; (*True if a command finshed successfully.*) (* *) (*#CMD#OPT#;*)
		CurrentProductionRate : REAL; (*Current production rate [products / h] based on calculation time base*) (* *) (*#CYC#*)
		ScheduledDowntimeRate : REAL; (*Percentage of scheduled downtime [%]*) (* *) (*#CYC#;*)
		UnscheduledDowntimeRate : REAL; (*Percentage of unscheduled downtime [%]*) (* *) (*#CYC#;*)
		NominalProductionTimeRate : REAL; (*Percentage of running time at nominal production speed [%]*) (* *) (*#CYC#;*)
		BadPieceRate : REAL; (*Percentage of bad products [%]*) (* *) (*#CYC#;*)
		ExportDone : BOOL; (*Export command was succesfuly finished*) (* *) (*#CMD#; *)
		Info : exAssetIntCoreInfoType; (*Provide any further useful information as function block output.(mapp standard interface)*) (* *) (*#CMD#; *)
	END_VAR
	VAR
		Internal : {REDUND_UNREPLICABLE} exCoreInternalDataType; (*Internal data*)
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
		zzEdge00002 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK exAssetIntCoreConfig
	VAR_INPUT
		exLink : REFERENCE TO exAssetIntLinkType; (*Incoming communication handle (mapp standard interface)*) (* *) (*#PAR#;*)
		Enable : BOOL; (*Enables/Disables the function block (mapp standard interface)*) (* *) (*#PAR#;*)
		ErrorReset : BOOL; (*Resets all function block errors (mapp standard interface)*) (* *) (*#PAR#;*)
		DeviceName : REFERENCE TO STRING[50]; (*Address of the exported device name*) (* *) (*#CMD#; *)
		Configuration : REFERENCE TO exAssetIntCoreConfigType;
		Logger : UDINT;
		Load : {REDUND_UNREPLICABLE} BOOL; (* *) (* *) (*#PAR#;*)
		Save : BOOL; (* *) (* *) (*#PAR#;*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Function block is active (mapp standard interface)*) (* *) (*#PAR#;*)
		Error : BOOL; (*Indicates an error (mapp standard interface)*) (* *) (*#PAR#;*)
		StatusID : DINT; (*Error/Status information (mapp standard interface)*) (* *) (*#PAR#; *)
		UpdateDone : BOOL; (*Update of parameters done (mapp standard interface)*) (* *) (*#PAR#; *)
		CommandBusy : BOOL; (*Function block is busy processing a command*) (* *) (*#CMD#OPT#;*)
		CommandDone : BOOL; (*True if a command finshed successfully.*) (* *) (*#CMD#OPT#;*)
		Info : exAssetIntInfoType; (*Provide any further useful information as function block output.(mapp standard interface)*) (* *) (*#CMD#; *)
	END_VAR
	VAR
		Internal : {REDUND_UNREPLICABLE} exConfigInternalDataType; (*Internal data*)
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
		zzEdge00002 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK exAssetIntJobListUI (*mapp function block which can be used for showing shift statistics in a list *)
	VAR_INPUT
		exLink : REFERENCE TO exAssetIntLinkType; (*Incoming communication handle (mapp standard interface)*) (* *) (*#PAR#;*)
		Enable : BOOL; (*Enables/Disables the function block (mapp standard interface)*) (* *) (*#PAR#;*)
		ErrorReset : BOOL; (*Resets all function block errors (mapp standard interface)*) (* *) (*#PAR#;*)
		Logger : UDINT;
		UISetup : exAssetIntJobListUISetupType; (*Setup UI connection - must be configured before enabling the FB*) (* *) (*#PAR#; *)
		UIConnect : REFERENCE TO exAssetIntJobListUIConnectType; (*Connection structure for VC4 User interface*) (* *) (*#CMD#; *)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Function block is active (mapp standard interface)*) (* *) (*#PAR#;*)
		Error : BOOL; (*Indicates an error (mapp standard interface)*) (* *) (*#PAR#;*)
		StatusID : DINT; (*Error/Status information (mapp standard interface)*) (* *) (*#PAR#; *)
		Info : exAssetIntInfoType; (*Provide any further useful information as function block output.(mapp standard interface)*) (* *) (*#CMD#; *)
	END_VAR
	VAR
		Internal : {REDUND_UNREPLICABLE} exJobUIInternalDataType; (*Internal data*)
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK CreateDirStructure
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
	END_VAR
	VAR_OUTPUT
		Status : DINT;
	END_VAR
	VAR
		DirCreate_0 : DirCreate;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		DirCount : USINT;
		State : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK CreateMemory
	VAR_INPUT
		Enable : BOOL;
		Size : UDINT;
		Logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
	END_VAR
	VAR_OUTPUT
		MemoryDb : UDINT;
		MemoryJob : UDINT;
		MemoryShift : UDINT;
		Status : UINT;
	END_VAR
	VAR
		DatObjCreate_0 : DatObjCreate;
		MemoryType : exAssetIntMemoryEnum;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		Cnt : USINT;
		State : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ReadConfiguration
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
		Configuration : exAssetIntCoreConfigType;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		FileOpen_0 : FileOpen;
		FileClose_0 : FileClose;
		FileRead_0 : FileRead;
		State : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WriteConfiguration
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : UDINT; (*Address of log buffer*)
		Configuration : exAssetIntCoreConfigType;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		FileCreate_0 : FileCreate;
		FileOpen_0 : FileOpen;
		FileClose_0 : FileClose;
		FileWrite_0 : FileWrite;
		Ident : UDINT;
		State : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ReadEventData
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
		Memory : UDINT;
		RecordSize : UDINT;
	END_VAR
	VAR_OUTPUT
		RecordCount : UINT;
		Status : DINT;
	END_VAR
	VAR
		DirOpen_0 : DirOpen;
		DirReadEx_0 : DirReadEx;
		DirClose_0 : DirClose;
		DirName : STRING[100];
		DirCount : USINT;
		FileOpen_0 : FileOpen;
		FileClose_0 : FileClose;
		FileRead_0 : FileRead;
		FileName : STRING[100];
		FileInfo_0 : fiDIR_READ_EX_DATA;
		RecordData : exCoreInternalRecordType;
		TimeFirst : DATE_AND_TIME;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		State : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WriteEventData
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : UDINT; (*Address of log buffer*)
		RecordData : exCoreInternalRecordType;
		RecordNext : UINT;
	END_VAR
	VAR_OUTPUT
		Status : DINT;
	END_VAR
	VAR
		FileCreate_0 : FileCreate;
		FileOpen_0 : FileOpen;
		FileClose_0 : FileClose;
		FileWrite_0 : FileWrite;
		RecordDataIntern : exCoreInternalRecordType;
		FileName : STRING[100];
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		Ident : UDINT;
		State : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION InsertEventData : USINT
	VAR_INPUT
		Memory : UDINT;
		RecordCount : UINT;
		RecordData : exCoreInternalRecordType;
	END_VAR
	VAR
		RecordMemory : REFERENCE TO exCoreInternalRecordType;
		sort : UDINT;
		x : INT;
		y : INT;
	END_VAR
END_FUNCTION

FUNCTION CreateLoggerEntry : USINT
	VAR_INPUT
		LogLevel : exAssetIntLogLevelEnum; (*Log Level*)
		LogMsg : UDINT; (*Log message*)
		LogBuffer : UDINT; (*Address of log buffer*)
	END_VAR
	VAR
		RtcGettime : RTCtime_typ;
		TmpStr : STRING[20];
		LastMsg : STRING[LOG_LEN];
	END_VAR
END_FUNCTION

FUNCTION CreateErrorState : DINT
	VAR_INPUT
		ErrorID : DINT;
		ErrorMsg : UDINT; (*Log message*)
		Logger : UDINT;
		Severity : exComSeveritiesEnum;
		StateError : REFERENCE TO exAssetIntStateEnum;
		State : REFERENCE TO exAssetIntStateEnum;
		DiagStatusID : REFERENCE TO exAssetIntStatusIDType;
	END_VAR
END_FUNCTION

FUNCTION CalcStatsJob : USINT
	VAR_INPUT
		exLink : exAssetIntLinkType; (*Incoming communication handle (mapp standard interface)*) (* *) (*#PAR#;*)
		Downtime : exAssetIntDowntimeEnum;
		Parameter : exAssetIntParType; (*Log Level*)
		JobStatistics : REFERENCE TO exAssetIntJobStatisticsType; (*Log message*)
	END_VAR
	VAR
		TotalTime : UDINT;
		Uptime : UDINT;
		NominalProductionTime : UDINT;
		DowntimeScheduled : UDINT;
		DowntimeUnscheduled : UDINT;
		GoodProductionTime : UDINT;
		DTGetTime_0 : DTGetTime;
	END_VAR
END_FUNCTION

FUNCTION FindInstr : UDINT
	VAR_INPUT
		string1 : UDINT;
		string2 : UDINT;
	END_VAR
	VAR
		idx : UDINT;
	END_VAR
END_FUNCTION
