// -------------------------------------------------------------------------------------------
// Create folder structure
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK StoreEvent
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT enable THEN
		status := ERR_FUB_ENABLE_FALSE;
		state := 0;		
		RETURN;
	END_IF
	
	CASE state OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF enable THEN
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
				tmpStr1 := 'events';
				brsitoa(record.ID/100, ADR(tmpStr2));
				brsstrcat(ADR(tmpStr1), ADR(tmpStr2));
				brsstrcat(ADR(tmpStr1), ADR('/event'));
				brsitoa(record.ID, ADR(tmpStr2));
				brsstrcat(ADR(tmpStr1), ADR(tmpStr2));
				
				status := ERR_FUB_BUSY;
				Logger(exASSETINT_LOG_INFO, 'creating new event', logger);
				state := state + 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Open file
		1:
			FileOpen_0.enable := TRUE;
			FileOpen_0.pDevice := ADR(device);
			FileOpen_0.pFile := ADR(tmpStr1);
			FileOpen_0.mode := fiREAD_WRITE;
			FileOpen_0();
	
			// File opened successful
			IF FileOpen_0.status = ERR_OK THEN
				// Generate log entry
				tmpStr2 := 'opened event file ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Remember ident go to next step
				ident := FileOpen_0.ident;
				state := 3;

			// Create event file when it does not exist
			ELSIF FileOpen_0.status = fiERR_FILE_NOT_FOUND  THEN
				state := 2;

			// Error
			ELSIF FileOpen_0.status <> ERR_FUB_BUSY THEN
				status := FileOpen_0.status;
				state := 0;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Create file
		2:
			FileCreate_0.enable := TRUE;
			FileCreate_0.pDevice := ADR(device);
			FileCreate_0.pFile := ADR(tmpStr1);
			FileCreate_0();
	
			// File created successful
			IF FileCreate_0.status = ERR_OK THEN
				// Generate log entry
				tmpStr2 := 'created event file ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Remember ident go to next step
				ident := FileCreate_0.ident;
				state := 3;
				
			// Error
			ELSIF FileCreate_0.status <> ERR_FUB_BUSY THEN
				status := FileCreate_0.status;
				state := 0;
			END_IF
		
		
		// -------------------------------------------------------------------------------------------
		// Write data
		3:
			FileWrite_0.enable := TRUE;
			FileWrite_0.ident := ident;
			FileWrite_0.pSrc := ADR(record);
			FileWrite_0.len := SIZEOF(record);
			FileWrite_0();
	
			// File created successful
			IF FileWrite_0.status = ERR_OK THEN
				// Generate log entry
				tmpStr2 := 'wrote event file ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Go to next step
				state := 4;
				
			// Error
			ELSIF FileWrite_0.status <> ERR_FUB_BUSY THEN
				status := FileWrite_0.status;
				state := 0;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Close file
		4:
			FileClose_0.enable := TRUE;
			FileClose_0.ident := ident;
			FileClose_0();
	
			// File created successful
			IF FileClose_0.status = ERR_OK THEN
				// Generate log entry
				tmpStr2 := 'closed event file ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Finish up
				status := ERR_OK;
				state := 0;
				
			// Error
			ELSIF FileClose_0.status <> ERR_FUB_BUSY THEN
				status := FileWrite_0.status;
				state := 0;
			END_IF
	END_CASE;

END_FUNCTION_BLOCK

