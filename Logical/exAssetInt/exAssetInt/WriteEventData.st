// -------------------------------------------------------------------------------------------
// Write event data
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK WriteEventData
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		Status := ERR_FUB_ENABLE_FALSE;
		State := 0;		
		RETURN;
	END_IF
	
	CASE State OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF Enable THEN
				RecordDataIntern := RecordData;
				
				// Reset function blocks
				FileOpen_0.enable := FALSE;
				FileOpen_0();
				FileCreate_0.enable := FALSE;
				FileCreate_0();
				FileWrite_0.enable := FALSE;
				FileWrite_0();
				FileClose_0.enable := FALSE;
				FileClose_0();

				// Generate file name
				FileName := 'events';
				brsitoa(RecordNext/CORE_EVENT_DIR_MAX, ADR(TmpStr2));
				brsstrcat(ADR(FileName), ADR(TmpStr2));
				brsstrcat(ADR(FileName), ADR('/event#'));
				brsitoa(RecordNext, ADR(TmpStr2));
				brsstrcat(ADR(FileName), ADR(TmpStr2));
				
				Status := ERR_FUB_BUSY;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'creating new event', Logger);
				State := 1;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Open file
		1:
			FileOpen_0.enable := TRUE;
			FileOpen_0.pDevice := ADR(Device);
			FileOpen_0.pFile := ADR(FileName);
			FileOpen_0.mode := fiREAD_WRITE;
			FileOpen_0();
	
			// File opened successful
			IF FileOpen_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr2 := 'open event file ok -> ';
				brsstrcat(ADR(TmpStr2), ADR(FileName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				// Remember ident go to next step
				Ident := FileOpen_0.ident;
				State := 3;

				// Create event file when it does not exist
			ELSIF FileOpen_0.status = fiERR_FILE_NOT_FOUND  THEN
				State := 2;

				// Error
			ELSIF FileOpen_0.status <> ERR_FUB_BUSY THEN
				Status := FileOpen_0.status;
				State := 0;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Create file
		2:
			FileCreate_0.enable := TRUE;
			FileCreate_0.pDevice := ADR(Device);
			FileCreate_0.pFile := ADR(FileName);
			FileCreate_0();
	
			// File created successful
			IF FileCreate_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr2 := 'create event file -> ';
				brsstrcat(ADR(TmpStr2), ADR(FileName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				// Remember ident go to next step
				Ident := FileCreate_0.ident;
				State := 3;
				
				// Error
			ELSIF FileCreate_0.status <> ERR_FUB_BUSY THEN
				Status := FileCreate_0.status;
				State := 0;
			END_IF
		
		
			// -------------------------------------------------------------------------------------------
			// Write data
		3:
			// Add file name to record
			RecordDataIntern.FileName := FileName;
			
			FileWrite_0.enable := TRUE;
			FileWrite_0.ident := Ident;
			FileWrite_0.pSrc := ADR(RecordDataIntern);
			FileWrite_0.len := SIZEOF(RecordDataIntern);
			FileWrite_0();
	
			// File created successful
			IF FileWrite_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr2 := 'write event file ok -> ';
				brsstrcat(ADR(TmpStr2), ADR(TmpStr1));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				// Go to next step
				State := 4;
				
				// Error
			ELSIF FileWrite_0.status <> ERR_FUB_BUSY THEN
				Status := FileWrite_0.status;
				State := 0;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Close file
		4:
			FileClose_0.enable := TRUE;
			FileClose_0.ident := Ident;
			FileClose_0();
	
			// File created successful
			IF FileClose_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr2 := 'close event file ok -> ';
				brsstrcat(ADR(TmpStr2), ADR(TmpStr1));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				// Finish up
				Status := ERR_OK;
				State := 0;
				
				// Error
			ELSIF FileClose_0.status <> ERR_FUB_BUSY THEN
				Status := FileClose_0.status;
				State := 0;
			END_IF
	END_CASE;

END_FUNCTION_BLOCK

