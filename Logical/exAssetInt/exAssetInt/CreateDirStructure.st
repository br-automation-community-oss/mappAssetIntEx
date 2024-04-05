// -------------------------------------------------------------------------------------------
// Create folder structure
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK CreateDirStructure
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
				DirCreate_0.enable := FALSE;
				DirCreate_0();

				DirCount := 0;
				TmpStr1 := 'events0';
				Status := ERR_FUB_BUSY;
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('creating folder structure'), Logger);
				State := 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Create folders
		1:
			DirCreate_0.enable := TRUE;
			DirCreate_0.pDevice := ADR(Device);
			DirCreate_0.pName := ADR(TmpStr1);
			DirCreate_0();
	
			// Folder created successful or folder already exsist
			IF DirCreate_0.status = ERR_OK OR DirCreate_0.status = fiERR_DIR_ALREADY_EXIST THEN
				// Generate log entry
				TmpStr2 := 'created folder ';
				brsstrcat(ADR(TmpStr2), ADR(TmpStr1));
				CreateLoggerEntry(exASSETINT_LOG_ALL, ADR(TmpStr2), Logger);
				
				// Create folders for 100 events each, finish when all folders are created
				DirCount := DirCount + 1;
				IF DirCount >= CORE_EVENT_NUM_MAX / CORE_EVENT_DIR_MAX THEN
					Status := ERR_OK;
					State := 0;
					
					// Generate next folder name
				ELSE
					TmpStr1 := 'events';
					brsitoa(DirCount, ADR(TmpStr2));
					brsstrcat(ADR(TmpStr1), ADR(TmpStr2));
				END_IF
				
				// Error
			ELSIF DirCreate_0.status <> ERR_FUB_BUSY THEN
				Status := DirCreate_0.status;
				State := 0;
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

