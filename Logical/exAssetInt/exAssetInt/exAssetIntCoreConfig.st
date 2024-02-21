
// -------------------------------------------------------------------------------------------
// Core function block
FUNCTION_BLOCK exAssetIntCoreConfig
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
			IF Enable THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'function block enabled', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_INIT_2;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Create folder structure
		exASSETINT_STATE_INIT_2:
			Internal.CreateDirStructure.Enable := TRUE;
			Internal.CreateDirStructure.Device := DeviceName;
			Internal.CreateDirStructure.Logger := ADR(Internal.Logger);
			Internal.CreateDirStructure();
		
			// Folder structure successful created
			IF Internal.CreateDirStructure.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'created folder structure', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_INIT_3;
			
				// Error
			ELSIF Internal.CreateDirStructure.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error creating folder structure', ADR(Internal.Logger));
				StatusID := CreateConfigErrorState(Internal.CreateDirStructure.Status, ADR(Internal));
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Create internal memory
		exASSETINT_STATE_INIT_3:
			Internal.CreateMemory.Enable := TRUE;
			Internal.CreateMemory.Size := CORE_EVENT_NUM_MAX*SIZEOF(Internal.RecordData);
			Internal.CreateMemory.Logger := ADR(Internal.Logger);
			Internal.CreateMemory();
		
			// Memory structure successful created
			IF Internal.CreateMemory.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'created internal memory', ADR(Internal.Logger));
				exLink.Memory := Internal.CreateMemory.Memory;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.CreateMemory.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error creating internal memory', ADR(Internal.Logger));
				StatusID := CreateConfigErrorState(Internal.CreateMemory.Status, ADR(Internal));
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:		
			// Handle configuration load command
			IF EDGEPOS(Load) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'command save configuration', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_LOAD_CFG;
			END_IF

			// Handle configuration save command
			IF EDGEPOS(Save) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'command save configuration', ADR(Internal.Logger));
				Internal.State := exASSETINT_STATE_SAVE_CFG;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Save configuration
		exASSETINT_STATE_LOAD_CFG:
			Internal.ReadConfiguration.Enable := TRUE;
			Internal.ReadConfiguration.Device := DeviceName;
			Internal.ReadConfiguration.Logger := ADR(Internal.Logger);
			Internal.ReadConfiguration();
		
			// Event successful created
			IF Internal.ReadConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'loaded configuration', ADR(Internal.Logger));				
				Configuration := Internal.ReadConfiguration.Configuration;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.ReadConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error loading configuration', ADR(Internal.Logger));
				StatusID := CreateConfigErrorState(Internal.ReadConfiguration.Status, ADR(Internal));
			END_IF

		// -------------------------------------------------------------------------------------------
		// Save configuration
		exASSETINT_STATE_SAVE_CFG:
			Internal.WriteConfiguration.Enable := TRUE;
			Internal.WriteConfiguration.Device := DeviceName;
			Internal.WriteConfiguration.Logger := ADR(Internal.Logger);
			Internal.WriteConfiguration.Configuration := Configuration;
			Internal.WriteConfiguration();
		
			// Event successful created
			IF Internal.WriteConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'saved configuration', ADR(Internal.Logger));				
			
				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.WriteConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error saving configuration', ADR(Internal.Logger));
				StatusID := CreateConfigErrorState(Internal.WriteConfiguration.Status, ADR(Internal));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Error state
		exASSETINT_STATE_ERROR:
			Internal.CreateDirStructure.Enable := FALSE;
			Internal.CreateDirStructure();
			Internal.CreateMemory.Enable := FALSE;
			Internal.CreateMemory();
			Internal.WriteConfiguration.Enable := FALSE;
			Internal.WriteConfiguration();
			Internal.ReadConfiguration.Enable := FALSE;
			Internal.ReadConfiguration();
			
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK

// -------------------------------------------------------------------------------------------
// Handle error state
FUNCTION CreateConfigErrorState
	Internal.StateError := Internal.State;
	Internal.State := exASSETINT_STATE_ERROR;
	CreateConfigErrorState := ErrorID;
END_FUNCTION
