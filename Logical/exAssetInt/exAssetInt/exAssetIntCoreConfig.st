
// -------------------------------------------------------------------------------------------
// Config function block
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
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('function block enabled'), Logger);

				// Make sure we have remanent buffer
				IF ADR(exLink) = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('error exLink is 0'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure we have temporary buffer
				IF exLink.MemoryDb = 0 OR exLink.MemoryJob = 0 OR exLink.MemoryJob = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_TEMP_MEMORY, ADR('error no temp memory'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure core function block is active
				IF NOT exLink.IsCoreActive THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(mpASSETINT_INF_WAIT_CORE_FB, ADR('error core is not active'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				
				// Reset error and status
				Error := FALSE;
				StatusID := ERR_OK;

				Internal.State := exASSETINT_STATE_IDLE;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:		
			// Handle configuration load command
			IF EDGEPOS(Load) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('command load configuration'), Logger);
				Internal.State := exASSETINT_STATE_LOAD_CFG;
			END_IF

			// Handle configuration save command
			IF EDGEPOS(Save) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('command save configuration'), Logger);
				Internal.State := exASSETINT_STATE_SAVE_CFG;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Save configuration
		exASSETINT_STATE_LOAD_CFG:
			Internal.ReadConfiguration.Enable := TRUE;
			Internal.ReadConfiguration.Device := DeviceName;
			Internal.ReadConfiguration.Logger := Logger;
			Internal.ReadConfiguration();
		
			// Event successful created
			IF Internal.ReadConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('load configuration ok'), Logger);				
				Configuration := Internal.ReadConfiguration.Configuration;
				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.ReadConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.ReadConfiguration.Status, ADR('load configuration error'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF

			// -------------------------------------------------------------------------------------------
			// Save configuration
		exASSETINT_STATE_SAVE_CFG:
			Internal.WriteConfiguration.Enable := TRUE;
			Internal.WriteConfiguration.Device := DeviceName;
			Internal.WriteConfiguration.Logger := Logger;
			Internal.WriteConfiguration.Configuration := Configuration;
			Internal.WriteConfiguration();
		
			// Event successful created
			IF Internal.WriteConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('save configuration ok'), Logger);				
				StatusID := ERR_OK;		
				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.WriteConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.WriteConfiguration.Status, ADR('save configuration error'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Error state
		exASSETINT_STATE_ERROR:
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

