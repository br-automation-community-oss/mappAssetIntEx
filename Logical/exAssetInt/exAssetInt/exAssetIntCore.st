
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
		// Create internal memory
		exASSETINT_STATE_INIT_3:
			Internal.CreateMemory.enable := TRUE;
			Internal.CreateMemory.size := CORE_EVENT_NUM_MAX*SIZEOF(Internal.Record);
			Internal.CreateMemory.logger := ADR(Internal.Logger);
			Internal.CreateMemory();
		
			// Folder structure successful created
			IF Internal.CreateMemory.status = ERR_OK THEN
				Logger(exASSETINT_LOG_INFO, 'created internal memory', ADR(Internal.Logger));
				Internal.Memory := Internal.CreateMemory.memory;
				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.CreateMemory.status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				Logger(exASSETINT_LOG_ERROR, 'error creating internal memory', ADR(Internal.Logger));
				StatusID := Internal.CreateMemory.status;
				Internal.StateError := Internal.State;
				Internal.State := exASSETINT_STATE_ERROR;
			END_IF

			// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:
			// Handle piece and reject counter
			IF PieceCounter <> Internal.Record.PieceCounter OR RejectCounter <> Internal.Record.RejectCounter THEN
				Internal.Record.PieceCounter := PieceCounter;
				Internal.Record.RejectCounter := RejectCounter;
				brsmemcpy(exLink, ADR(Internal.Record), SIZEOF(Internal.Record));
			END_IF
			
			// Handle job, shift or information change
			IF Parameters.NominalProductionRate <> Internal.Record.NominalProductionRate OR Parameters.Job <> Internal.Record.Job OR Parameters.CurrentUser <> Internal.Record.CurrentUser OR Parameters.AdditionalData <> Internal.Record.AdditionalData THEN
				Internal.Record.NominalProductionRate := Parameters.NominalProductionRate;
				Internal.Record.Job := Parameters.Job;
				Internal.Record.CurrentUser := Parameters.CurrentUser;
				Internal.Record.AdditionalData := Parameters.AdditionalData;
				
				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_STORE_EVENT_1:
			Internal.StoreEvent.enable := TRUE;
			Internal.StoreEvent.device := DeviceName;
			Internal.StoreEvent.logger := ADR(Internal.Logger);
			Internal.StoreEvent.record := Internal.Record;
			Internal.StoreEvent();
		
			// Event successful created
			IF Internal.StoreEvent.status = ERR_OK THEN
				Logger(exASSETINT_LOG_INFO, 'created new event', ADR(Internal.Logger));
				
				// Calculate new event ID
				Internal.Record.ID := Internal.Record.ID + 1;
				IF Internal.Record.ID > CORE_EVENT_NUM_MAX THEN
					Internal.Record.ID := 0;
				END_IF
				
				Internal.State := exASSETINT_STATE_IDLE;
			
			// Error
			ELSIF Internal.StoreEvent.status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				Logger(exASSETINT_LOG_ERROR, 'error creating event', ADR(Internal.Logger));
				StatusID := Internal.StoreEvent.status;
				Internal.StateError := Internal.State;
				Internal.State := exASSETINT_STATE_ERROR;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Error state
		exASSETINT_STATE_ERROR:
			Internal.CreateDirStructure.enable := FALSE;
			Internal.CreateDirStructure();
			Internal.StoreEvent.enable := FALSE;
			Internal.StoreEvent();
			
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK
