

// -------------------------------------------------------------------------------------------
// Handle log buffer
FUNCTION Logger
	// Make sure we dont flood logger
	IF log_msg <> last_msg AND log_level <= LOG_LEVEL THEN
		// Make sure log message fits
		IF brsstrlen(ADR(log_msg)) > LOG_LEN THEN
			log_msg := '*** log meassage exceeds maximum length ***';
		END_IF
		// Move ring buffer around
		brsmemmove(log_buffer+LOG_LEN+1, log_buffer, LOG_LEN*(LOG_NUM-1));
		brsstrcpy(log_buffer, ADR(''));
		// Create time information
		RTC_gettime(ADR(rtc_gettime)); 
		IF(rtc_gettime.day < 10) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.day, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		brsitoa(rtc_gettime.day, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR('.'));
		IF(rtc_gettime.month < 10) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.month, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(' '));
		IF(rtc_gettime.hour < 10) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.hour, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(':'));
		IF(rtc_gettime.minute < 10) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.minute, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(':'));
		IF(rtc_gettime.second < 10) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.second, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR('.'));
		IF(rtc_gettime.millisec < 10) THEN
			brsstrcat(log_buffer, ADR('00'));
		ELSIF(rtc_gettime.millisec < 100) THEN
			brsstrcat(log_buffer, ADR('0'));
		END_IF
		brsitoa(rtc_gettime.millisec, ADR(tmpSTR));
		brsstrcat(log_buffer, ADR(tmpSTR));
		// Add log message
		brsstrcat(log_buffer, ADR(' '));
		brsstrcat(log_buffer, ADR(log_msg));
	END_IF
	last_msg := log_msg;

END_FUNCTION