
FUNCTION_BLOCK exAssetIntCore (*mapp function block which can be used for asset intensity calculation.*) (* $GROUP=mapp Services,$CAT=Asset Intensity,$GROUPICON=Icon_mapp.png,$CATICON=Icon_exOee.png *)
	VAR_INPUT
		exLink : REFERENCE TO UDINT; (*Incoming communication handle (mapp standard interface)*) (* *) (*#PAR#;*)
		Enable : BOOL; (*Enables/Disables the function block (mapp standard interface)*) (* *) (*#PAR#;*)
		ErrorReset : BOOL; (*Resets all function block errors (mapp standard interface)*) (* *) (*#PAR#;*)
		Parameters : REFERENCE TO exAssetIntParType; (*Function block parameters (mapp standard interface)*) (* *) (*#PAR#; *)
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
		Internal : {REDUND_UNREPLICABLE} exComInternalDataType; (*Internal data*)
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
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
		Memory : UDINT;
		Status : UINT;
	END_VAR
	VAR
		DatObjCreate_0 : DatObjCreate;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		Cnt : USINT;
		State : USINT;
		zzEdge00000 : BOOL;
		zzEdge1 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WriteEventData
	VAR_INPUT
		Enable : BOOL;
		Device : STRING[50];
		Logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
		RecordData : exComInternalRecordType;
		RecordNext : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		FileCreate_0 : FileCreate;
		FileOpen_0 : FileOpen;
		FileClose_0 : FileClose;
		FileWrite_0 : FileWrite;
		DTGetTime_0 : DTGetTime;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		Ident : UDINT;
		Cnt : USINT;
		State : USINT;
		zzEdge00000 : BOOL;
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
		RecordIdFirst : UINT;
		RecordIdLast : UINT;
		RecordCount : UINT;
		Status : UINT;
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
		FileInfo : fiDIR_READ_EX_DATA;
		RecordData : exComInternalRecordType;
		TimeFirst : DATE_AND_TIME;
		TimeDiff : UDINT;
		TmpStr1 : STRING[100];
		TmpStr2 : STRING[100];
		x : UINT;
		State : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION InsertEventData : USINT
	VAR_INPUT
		Memory : UDINT;
		RecordCount : UINT;
		RecordData : exComInternalRecordType;
	END_VAR
	VAR
		RecordMemory : REFERENCE TO exComInternalRecordType;
		sort : UDINT;
		x : INT;
		y : INT;
	END_VAR
END_FUNCTION

FUNCTION CreateLoggerEntry : USINT
	VAR_INPUT
		LogLevel : exAssetIntLogLevelEnum; (*Log Level*)
		LogMsg : STRING[LOG_LEN]; (*Log message*)
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
		Internal : REFERENCE TO exComInternalDataType;
	END_VAR
END_FUNCTION
