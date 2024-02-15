
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
		enable : BOOL;
		device : STRING[50];
		logger : {REDUND_UNREPLICABLE} UDINT; (*Address of log buffer*)
	END_VAR
	VAR_OUTPUT
		status : UINT;
	END_VAR
	VAR
		DirCreate_0 : DirCreate;
		tmpStr1 : STRING[100];
		tmpStr2 : STRING[100];
		idx : USINT;
		state : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION Logger : USINT
	VAR_INPUT
		log_level : exAssetIntLogLevelEnum; (*Log Level*)
		log_msg : STRING[LOG_LEN]; (*Log message*)
		log_buffer : UDINT; (*Address of log buffer*)
	END_VAR
	VAR
		rtc_gettime : RTCtime_typ;
		tmpSTR : STRING[20];
		last_msg : STRING[LOG_LEN];
	END_VAR
END_FUNCTION
