// -------------------------------------------------------------------------------------------
// File version 1001
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
				// Make sure backup data has correct size
				IF FileOpen_0.filelen <> SIZEOF(LinkRead) THEN
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('link backup data size is incorrect'), Logger);
					StatusRead := ERR_ASSET_LINK_SIZE;
						
					State := 6;
				ELSE
					CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('open link data ok'), Logger);
					State := 5;
				END_IF
				
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
			FileRead_0.pDest := ADR(LinkRead);
			FileRead_0.len := FileOpen_0.filelen;
			FileRead_0();
	
			// File read successful
			IF FileRead_0.status = ERR_OK THEN
				// Make sure backup version is correct
				IF LinkRead.Version <> EXLINK_VERSION THEN
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('link backup data version is incorrect'), Logger);
					StatusRead := ERR_ASSET_LINK_VERSION;
						
				ELSE
					brsmemcpy(ADR(Link), ADR(LinkRead), SIZEOF(LinkRead));
					CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('open link data ok'), Logger);
				END_IF

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
				// Auto delete corrupt file 
				IF StatusRead <> 0 THEN
					State := 7;						
				ELSE
					// Generate log entry
					CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('closed link data ok'), Logger);
				
					// Go to next step
					Status := ERR_OK;
					State := 0;
				END_IF
				
				
			// Error
			ELSIF FileClose_0.status <> ERR_FUB_BUSY THEN
				Status := FileClose_0.status;
				State := 0;
			END_IF
						
			// -------------------------------------------------------------------------------------------
			// Delete corrupt file
		7:
			FileDelete_0.enable := TRUE;
			FileDelete_0.pDevice := ADR(Device);
			FileDelete_0.pName := ADR('exAssetLink');
			FileDelete_0();
		
			// File delete successful
			IF FileDelete_0.status = ERR_OK THEN
				// Generate log entry
				CreateLoggerEntry(exASSETINT_LOG_ALL, ADR('delete corrupt link backup file ok'), Logger);
				
				Status := StatusRead;
				State := 0;
					
				// Error
			ELSIF FileDelete_0.status <> ERR_FUB_BUSY THEN
				Status := FileDelete_0.status;
				State := 0;
			END_IF
	END_CASE;

END_FUNCTION_BLOCK

