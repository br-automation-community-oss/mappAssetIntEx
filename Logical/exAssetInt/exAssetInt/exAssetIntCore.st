
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
				Internal.State := exASSETINT_STATE_INIT_4;
			
				// Error
			ELSIF Internal.CreateMemory.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error creating internal memory', ADR(Internal.Logger));
				StatusID := CreateConfigErrorState(Internal.CreateMemory.Status, ADR(Internal));
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Read event data
		exASSETINT_STATE_INIT_4:
			Internal.ReadEventData.Enable := TRUE;
			Internal.ReadEventData.Device := DeviceName;
			Internal.ReadEventData.Memory := exLink.Memory;
			Internal.ReadEventData.RecordSize := SIZEOF(Internal.RecordData);
			Internal.ReadEventData.Logger := ADR(Internal.Logger);
			Internal.ReadEventData();
		
			// Read events successful
			IF Internal.ReadEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'reading stored events', ADR(Internal.Logger));
				Internal.RecordCount := Internal.ReadEventData.RecordCount;
				Internal.RecordNext := Internal.ReadEventData.RecordCount;
				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.ReadEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error reading stored events', ADR(Internal.Logger));
				StatusID := CreateCoreErrorState(Internal.ReadEventData.Status, ADR(Internal));
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:
			exLink.PieceCounter := PieceCounter;
			exLink.RejectCounter := RejectCounter;

			// Creat job and shift statistics
			CalcStatsJob(exLink, Parameters, ADR(Info.JobStatistics));
					
			// Handle nominal production rate change
			IF Parameters.NominalProductionRate <> Internal.RecordData.NominalProductionRate THEN
				Internal.RecordData.NominalProductionRate := Parameters.NominalProductionRate;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'new nominal production rate', ADR(Internal.Logger));

				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
			END_IF

			// Handle job change
			IF Parameters.Job <> Internal.RecordData.Job THEN
				Internal.RecordData.Job := Parameters.Job;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'new job name', ADR(Internal.Logger));
				
				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
			END_IF

			// Handle user change
			IF Parameters.CurrentUser <> Internal.RecordData.CurrentUser THEN
				Internal.RecordData.CurrentUser := Parameters.CurrentUser;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'new user name', ADR(Internal.Logger));
				
				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
			END_IF

			// Handle information change
			IF Parameters.AdditionalData <> Internal.RecordData.AdditionalData THEN
				Internal.RecordData.AdditionalData := Parameters.AdditionalData;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'new additional information', ADR(Internal.Logger));
				
				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Store new event
		exASSETINT_STATE_STORE_EVENT_1:
			Internal.WriteEventData.Enable := TRUE;
			Internal.WriteEventData.Device := DeviceName;
			Internal.WriteEventData.Logger := ADR(Internal.Logger);
			Internal.WriteEventData.RecordData := Internal.RecordData;
			Internal.WriteEventData.RecordNext := Internal.RecordNext;
			Internal.WriteEventData();
		
			// Event successful created
			IF Internal.WriteEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'created new event', ADR(Internal.Logger));
				
				// Calculate new last record and record count
				Internal.RecordNext := Internal.RecordNext + 1;
				IF Internal.RecordNext > CORE_EVENT_NUM_MAX THEN
					Internal.RecordNext := 0;
				END_IF
				IF Internal.RecordCount < CORE_EVENT_NUM_MAX THEN
					Internal.RecordCount := Internal.RecordCount + 1;
				END_IF
				
				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.WriteEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				CreateLoggerEntry(exASSETINT_LOG_ERROR, 'error creating event', ADR(Internal.Logger));
				StatusID := CreateCoreErrorState(Internal.WriteEventData.Status, ADR(Internal));
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Error state
		exASSETINT_STATE_ERROR:
			Internal.CreateDirStructure.Enable := FALSE;
			Internal.CreateDirStructure();
			Internal.CreateMemory.Enable := FALSE;
			Internal.CreateMemory();
			Internal.WriteEventData.Enable := FALSE;
			Internal.WriteEventData();
			Internal.ReadEventData.Enable := FALSE;
			Internal.ReadEventData();
			
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK


// -------------------------------------------------------------------------------------------
// Handle error state
FUNCTION CreateCoreErrorState
	Internal.StateError := Internal.State;
	Internal.State := exASSETINT_STATE_ERROR;
	CreateCoreErrorState := ErrorID;
END_FUNCTION
