
// -------------------------------------------------------------------------------------------
// Core function block
FUNCTION_BLOCK exAssetIntCore
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		StatusID := ERR_FUB_ENABLE_FALSE;
		Internal.State := exASSETINT_STATE_INIT_1;
		RETURN;
	END_IF
	
	CASE Internal.State OF

		// -------------------------------------------------------------------------------------------
		// Wait for enable
		exASSETINT_STATE_INIT_1:
			IF EDGEPOS(Enable) THEN
				Logger(exASSETINT_LOG_INFO, 'function block enabled', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_INIT_2;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Create folder structure
		exASSETINT_STATE_INIT_2:
			Internal.CreateDirStructure.enable := TRUE;
			Internal.CreateDirStructure.device := DeviceName;
			Internal.CreateDirStructure.logger := ADR(Internal.Logger);
			Internal.CreateDirStructure();
		
			// Folder structure successful created
			IF Internal.CreateDirStructure.status = ERR_OK THEN
				Logger(exASSETINT_LOG_INFO, 'created folder structure', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_INIT_3;
			
			// Error
			ELSIF Internal.CreateDirStructure.status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				Logger(exASSETINT_LOG_ERROR, 'error creating folder structure', ADR(Internal.Logger));
				StatusID := Internal.CreateDirStructure.status;
				Internal.StateError := Internal.State;
				Internal.State := exASSETINT_STATE_ERROR;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Error state
		exASSETINT_STATE_ERROR:
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK

// -------------------------------------------------------------------------------------------
// Create folder structure
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK CreateDirStructure
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT enable THEN
		DirCreate_0.enable := FALSE;
		DirCreate_0();

		status := ERR_FUB_ENABLE_FALSE;
		state := 0;		
		RETURN;
	END_IF
	
	CASE state OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF EDGEPOS(enable) THEN
				idx := 0;
				tmpStr1 := 'events0';
				status := ERR_FUB_BUSY;
				Logger(exASSETINT_LOG_INFO, 'creating folder structure', logger);
				state := state + 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Create folders
		1:
			DirCreate_0.enable := TRUE;
			DirCreate_0.pDevice := ADR(device);
			DirCreate_0.pName := ADR(tmpStr1);
			DirCreate_0();
	
			// Folder created successful or folder already exsist
			IF DirCreate_0.status = ERR_OK OR DirCreate_0.status = fiERR_DIR_ALREADY_EXIST THEN
				// Generate log entry
				tmpStr2 := 'created folder ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Create folders for 100 events each, finish when all folders are created
				idx := idx + 1;
				IF idx > CORE_EVENT_NUM_MAX / 100 THEN
					status := ERR_OK;
					state := 0;
					
				// Generate next folder name
				ELSE
					tmpStr1 := 'events';
					brsitoa(idx, ADR(tmpStr2));
					brsstrcat(ADR(tmpStr1), ADR(tmpStr2));
				END_IF
				
			// Error
			ELSIF DirCreate_0.status <> ERR_FUB_BUSY THEN
				status := DirCreate_0.status;
				state := 0;
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

