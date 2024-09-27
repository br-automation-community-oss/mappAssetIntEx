// -------------------------------------------------------------------------------------------
// File version 1000
// -------------------------------------------------------------------------------------------
// Read configuration
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK ReadLinkData
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
				// Reset function blocks
				FileOpen_0.enable := FALSE;
				FileOpen_0();
				FileRead_0.enable := FALSE;
				FileRead_0();
				FileClose_0.enable := FALSE;
				FileClose_0();
			
				Status := ERR_FUB_BUSY;
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('reading link data'), Logger);
				State := 1;
			END_IF
		
		// -------------------------------------------------------------------------------------------
		// Open event file
		1:		
			// Open file
			FileOpen_0.enable := TRUE;
			FileOpen_0.pDevice := ADR(Device);
			FileOpen_0.pFile := ADR('exAssetLink');
			FileOpen_0.mode := fiREAD_ONLY;
			FileOpen_0();
	
			// File opened successful
			IF FileOpen_0.status = ERR_OK THEN
				// Generate log entry
				CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('open link data ok'), Logger);
				
				// Go to next step
				State := 5;

			// Error
			ELSIF FileOpen_0.status <> ERR_FUB_BUSY THEN
				Status := FileOpen_0.status;
				State := 0;
			END_IF	
		
		// -------------------------------------------------------------------------------------------
		// Read configuration data
		5:
			FileRead_0.enable := TRUE;
			FileRead_0.ident := FileOpen_0.ident;
			FileRead_0.pDest := ADR(Link);
			FileRead_0.len := FileOpen_0.filelen;
			FileRead_0();
	
			// File read successful
			IF FileRead_0.status = ERR_OK THEN
				// Generate log entry
				CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('read link data ok'), Logger);

				State := 6;
				
			// Error
			ELSIF FileRead_0.status <> ERR_FUB_BUSY THEN
				Status := FileRead_0.status;
				State := 0;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Close file
		6:
			FileClose_0.enable := TRUE;
			FileClose_0.ident := FileOpen_0.ident;
			FileClose_0();
	
			// File closed successful
			IF FileClose_0.status = ERR_OK THEN
				// Generate log entry
				CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('closed link data ok'), Logger);
				
				// Go to next step
				Status := ERR_OK;
				State := 0;
				
				// Error
			ELSIF FileClose_0.status <> ERR_FUB_BUSY THEN
				Status := FileClose_0.status;
				State := 0;
			END_IF
	END_CASE;

END_FUNCTION_BLOCK

