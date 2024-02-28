
// -------------------------------------------------------------------------------------------
// Job UI function block
FUNCTION_BLOCK exAssetIntJobListUI
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
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'function block enabled', Logger);

				// Make sure we have remanent buffer
				IF ADR(exLink) = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_LINK, 'error exLink is 0', Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure we have temporary buffer
				IF exLink.MemoryDb = 0 OR exLink.MemoryJob = 0 OR exLink.MemoryJob = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_TEMP_MEMORY, 'error no temp memory', Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure core function block is active
				IF NOT exLink.IsCoreActive THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(mpASSETINT_INF_WAIT_CORE_FB, 'error core is not active', Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF

				// Reset error and status
				Error := FALSE;
				StatusID := ERR_OK;
				Internal.SortingStartTimeOld := UDINT_TO_DINT(16#FFFFFFFF);

				Internal.State := exASSETINT_STATE_IDLE;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:		
			// Reset record start when sorting direction changed
			IF UISetup.SortingStartTime <> Internal.SortingStartTimeOld THEN
				IF UISetup.SortingStartTime = exASSETINT_SORTING_ASC THEN
					Internal.RecordStart := 0;
				ELSE
					Internal.RecordStart := exLink.RecordCount;
				END_IF
			END_IF
			Internal.SortingStartTimeOld := UISetup.SortingStartTime;
				
			// Wait for core task to call update command
			IF exLink.RefreshJobUI AND exLink.RecordCount > 0 THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'refresh job data', Logger);
				
				// Make correction for DESC sorting when record count changes
				IF UISetup.SortingStartTime = exASSETINT_SORTING_DESC AND Internal.RecordStart + exLink.RecordCount - Internal.RecordCountOld <= exLink.RecordCount THEN
					Internal.RecordStart := Internal.RecordStart + exLink.RecordCount - Internal.RecordCountOld;
				END_IF
				Internal.RecordCountOld := exLink.RecordCount;
				
				// Clear array and copy new data
				brsmemset(ADR(UIConnect.Output), 0, SIZEOF(UIConnect.Output));
				
				// Check how much data is left for ascending
				IF UISetup.SortingStartTime = exASSETINT_SORTING_ASC AND Internal.RecordStart + UI_JOB_LIST_IDX > exLink.RecordCount  THEN
					Internal.RecordNum := exLink.RecordCount - Internal.RecordStart - 1;
				// Check how much data is left for descending
				ELSIF UISetup.SortingStartTime = exASSETINT_SORTING_DESC AND Internal.RecordStart <= UI_JOB_LIST_IDX THEN
					Internal.RecordNum := Internal.RecordStart;
				ELSE
					Internal.RecordNum := UI_JOB_LIST_IDX;
				END_IF
						
				Internal.x := 0;
				REPEAT
					IF UISetup.SortingStartTime = exASSETINT_SORTING_ASC THEN
						brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (Internal.x + Internal.RecordStart)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
					ELSE
						brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (Internal.RecordStart - Internal.x - 1)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
					END_IF
					
					UIConnect.Output.JobStartTime[Internal.x] := Internal.RecordData.TimeStart;
					UIConnect.Output.JobEndTime[Internal.x] := Internal.RecordData.TimeEnd;
					UIConnect.Output.JobName[Internal.x] := Internal.RecordData.JobName;
					UIConnect.Output.CurrentUser[Internal.x] := Internal.RecordData.CurrentUser;
					UIConnect.Output.AdditionalData[Internal.x] := Internal.RecordData.AdditionalData;
					UIConnect.Output.TotalPieces[Internal.x] := Internal.RecordData.TotalPieces;
					UIConnect.Output.GoodPieces[Internal.x] := Internal.RecordData.GoodPieces;
					UIConnect.Output.RejectPieces[Internal.x] := Internal.RecordData.RejectPieces;
					UIConnect.Output.BadPieceRate[Internal.x] := Internal.RecordData.BadPieceRate;
					UIConnect.Output.TotalTime[Internal.x] := Internal.RecordData.TotalTime;
					UIConnect.Output.ScheduledDowntime[Internal.x] := Internal.RecordData.ScheduledDowntime;
					UIConnect.Output.UnscheduledDowntime[Internal.x] := Internal.RecordData.UnscheduledDowntime;
					UIConnect.Output.Uptime[Internal.x] := Internal.RecordData.Uptime;
					UIConnect.Output.GoodProductionTime[Internal.x] := Internal.RecordData.GoodProductionTime;
					UIConnect.Output.NominalProductionTime[Internal.x] := Internal.RecordData.NominalProductionTime;
					UIConnect.Output.NominalProductionRate[Internal.x] := Internal.RecordData.NominalProductionTimeRate;
					UIConnect.Output.UnscheduledDowntimeRate[Internal.x] := Internal.RecordData.UnscheduledDowntimeRate;
					UIConnect.Output.ProductionRate[Internal.x] := Internal.RecordData.CurrentProductionRate;
					UIConnect.Output.ShiftName[Internal.x] := Internal.RecordData.ShiftName;
	  
					Internal.x := Internal.x + 1;
					
					UNTIL (Internal.x = Internal.RecordNum)
				END_REPEAT;
								
			END_IF
			exLink.RefreshJobUI := FALSE;
			
			// -------------------------------------------------------------------------------------------
			// Error state
		exASSETINT_STATE_ERROR:		
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK

