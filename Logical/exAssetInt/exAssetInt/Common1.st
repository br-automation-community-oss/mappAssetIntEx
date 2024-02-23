// -------------------------------------------------------------------------------------------
// Handle error state
FUNCTION CreateErrorState
	CreateLoggerEntry(exASSETINT_LOG_ERROR, ErrorMsg, ADR(Logger));

	StateError := State;
	State := exASSETINT_STATE_ERROR;
	
	DiagStatusID.ID := ErrorID;
	DiagStatusID.Code := UDINT_TO_UINT(StateError);
	DiagStatusID.Severity := Severity;
	
	CreateErrorState := ErrorID;
END_FUNCTION

// -------------------------------------------------------------------------------------------
// Handle log buffer
FUNCTION CreateLoggerEntry
	// Make sure we dont flood Logger
	IF LogMsg <> LastMsg AND LogLevel <= LOG_LEVEL THEN
		// Make sure log message fits
		IF brsstrlen(ADR(LogMsg)) > LOG_LEN THEN
			LogMsg := '*** log meassage exceeds maximum length ***';
		END_IF
		// Move ring buffer around
		brsmemmove(LogBuffer+LOG_LEN+1, LogBuffer, LOG_LEN*(LOG_NUM-1));
		brsstrcpy(LogBuffer, ADR(''));
		// Create time information
		RTC_gettime(ADR(RtcGettime)); 
		IF(RtcGettime.day < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.day, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsitoa(RtcGettime.day, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR('.'));
		IF(RtcGettime.month < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.month, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(' '));
		IF(RtcGettime.hour < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.hour, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(':'));
		IF(RtcGettime.minute < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.minute, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(':'));
		IF(RtcGettime.second < 10) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.second, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR('.'));
		IF(RtcGettime.millisec < 10) THEN
			brsstrcat(LogBuffer, ADR('00'));
		ELSIF(RtcGettime.millisec < 100) THEN
			brsstrcat(LogBuffer, ADR('0'));
		END_IF
		brsitoa(RtcGettime.millisec, ADR(TmpStr));
		brsstrcat(LogBuffer, ADR(TmpStr));
		// Add log message
		brsstrcat(LogBuffer, ADR(' '));
		brsstrcat(LogBuffer, ADR(LogMsg));
	END_IF
	LastMsg := LogMsg;

END_FUNCTION