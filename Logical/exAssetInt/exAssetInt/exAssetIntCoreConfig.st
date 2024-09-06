// -------------------------------------------------------------------------------------------
// File version 1000
// -------------------------------------------------------------------------------------------
// Config function block
FUNCTION_BLOCK exAssetIntCoreConfig
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		Active := FALSE;
		StatusID := ERR_FUB_ENABLE_FALSE;
		Internal.State := exASSETINT_STATE_INIT_1;
		CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('function block disabled'), Logger);
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
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('ERR: exLink is 0'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure core configuration link is valid
				IF ADR(Configuration) = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_CONFIG, ADR('ERR: configuration link is 0'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				
				// Transfer configuration link
				exLink.Configuration := ADR(Configuration);
				
				// Reset error and status
				CommandBusy := FALSE;
				CommandDone := FALSE;
				Error := FALSE;
				StatusID := ERR_OK;

				Internal.State := exASSETINT_STATE_IDLE;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:
			Active := TRUE;
			
			// Handle configuration load command
			IF EDGEPOS(Load) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('command load configuration'), Logger);
				CommandBusy := TRUE;
				CommandDone := FALSE;
				
				Internal.State := exASSETINT_STATE_LOAD_CFG;
			END_IF

			// Handle configuration save command
			IF EDGEPOS(Save) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('command save configuration'), Logger);
				CommandBusy := TRUE;
				CommandDone := FALSE;

				Internal.State := exASSETINT_STATE_SAVE_CFG;
			END_IF
			
			IF Load = FALSE AND Save = FALSE THEN
				CommandDone := FALSE;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Save configuration
		exASSETINT_STATE_LOAD_CFG:
			Internal.ReadConfiguration.Enable := TRUE;
			Internal.ReadConfiguration.Device := ADR(DeviceName);
			Internal.ReadConfiguration.Logger := Logger;
			Internal.ReadConfiguration();
		
			// Event successful created
			IF Internal.ReadConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('load configuration ok'), Logger);				
				Configuration := Internal.ReadConfiguration.Configuration;
				
				CommandBusy := FALSE;
				CommandDone := TRUE;
				StatusID := ERR_OK;

				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.ReadConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.ReadConfiguration.Status, ADR('ERR: load configuration'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF

			// -------------------------------------------------------------------------------------------
			// Save configuration
		exASSETINT_STATE_SAVE_CFG:
			Internal.WriteConfiguration.Enable := TRUE;
			Internal.WriteConfiguration.Device := ADR(DeviceName);
			Internal.WriteConfiguration.Logger := Logger;
			Internal.WriteConfiguration.Configuration := Configuration;
			Internal.WriteConfiguration();
		
			// Event successful created
			IF Internal.WriteConfiguration.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('save configuration ok'), Logger);				

				CommandBusy := FALSE;
				CommandDone := TRUE;
				StatusID := ERR_OK;		

				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.WriteConfiguration.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.WriteConfiguration.Status, ADR('ERR: save configuration'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
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

