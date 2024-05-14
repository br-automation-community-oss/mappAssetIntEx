
// -------------------------------------------------------------------------------------------
// Job UI function block
FUNCTION_BLOCK exAssetIntJobListUI
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		StatusID := ERR_FUB_ENABLE_FALSE;
		Active := FALSE;
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
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('ERR: exLink is 0'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure we have temporary buffer
				IF exLink.MemoryDb = 0 OR exLink.MemoryJob = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_TEMP_MEMORY, ADR('ERR: no temp memory'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure core function block is active
				IF NOT exLink.IsCoreActive THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(mpASSETINT_INF_WAIT_CORE_FB, ADR('ERR: core is not active'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF

				// Reset error and status
				Error := FALSE;
				StatusID := ERR_OK;
				Internal.SortingStartTimeOld := UDINT_TO_DINT(16#FFFFFFFF);
				
				UISetup.OutputListSize := UI_SHIFT_LIST_IDX;			
				UIConnect.Filter.Dialog.LayerStatus := 1;
				UIConnect.Filter.DefaultLayerStatus := 0;
				UIConnect.Filter.Dialog.From.Year := 1970;
				UIConnect.Filter.Dialog.From.Month := 1;
				UIConnect.Filter.Dialog.From.Day := 1;
				UIConnect.Filter.Dialog.Until.Year := 1970;
				UIConnect.Filter.Dialog.Until.Month := 1;
				UIConnect.Filter.Dialog.Until.Day := 1;
				
				UISetup.OutputListSize := UI_JOB_LIST_IDX;

				Internal.State := exASSETINT_STATE_IDLE;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Wait for new event
		exASSETINT_STATE_IDLE:
			// -------------------------------------------------------------------------------------------
			// Handle dialog window
			IF EDGEPOS(UIConnect.Filter.ShowDialog) THEN
				UIConnect.Filter.Dialog.LayerStatus := 0;
				UIConnect.Filter.DefaultLayerStatus := 2;
				UIConnect.Filter.ShowDialog := FALSE;
			END_IF
			// Dialog is open
			IF UIConnect.Filter.Dialog.LayerStatus = 0 THEN
				// Button cancel
				IF EDGEPOS(UIConnect.Filter.Dialog.Cancel) THEN
					UIConnect.Filter.Dialog.LayerStatus := 1;
					UIConnect.Filter.DefaultLayerStatus := 0;
					UIConnect.Filter.Dialog.Cancel := 0;
				END_IF
				// Button ok
				IF EDGEPOS(UIConnect.Filter.Dialog.Confirm) THEN
					Internal.DT_TO_DTStructure_0.year := UIConnect.Filter.Dialog.From.Year;
					Internal.DT_TO_DTStructure_0.month := UIConnect.Filter.Dialog.From.Month;
					Internal.DT_TO_DTStructure_0.day := UIConnect.Filter.Dialog.From.Day;
					Internal.DT_TO_DTStructure_0.hour := UIConnect.Filter.Dialog.From.Hour;
					Internal.DT_TO_DTStructure_0.minute := UIConnect.Filter.Dialog.From.Minute;
					UIConnect.Filter.Current.From.DateTime := DTStructure_TO_DT(ADR(Internal.DT_TO_DTStructure_0));
					UIConnect.Filter.Current.From.Enable := UIConnect.Filter.Dialog.From.Enable;

					Internal.DT_TO_DTStructure_0.year := UIConnect.Filter.Dialog.Until.Year;
					Internal.DT_TO_DTStructure_0.month := UIConnect.Filter.Dialog.Until.Month;
					Internal.DT_TO_DTStructure_0.day := UIConnect.Filter.Dialog.Until.Day;
					Internal.DT_TO_DTStructure_0.hour := UIConnect.Filter.Dialog.Until.Hour;
					Internal.DT_TO_DTStructure_0.minute := UIConnect.Filter.Dialog.Until.Minute;
					UIConnect.Filter.Current.Until.DateTime := DTStructure_TO_DT(ADR(Internal.DT_TO_DTStructure_0));
					UIConnect.Filter.Current.Until.Enable := UIConnect.Filter.Dialog.Until.Enable;

					UIConnect.Filter.Dialog.LayerStatus := 1;
					UIConnect.Filter.DefaultLayerStatus := 0;
					UIConnect.Filter.Dialog.Confirm := 0;
					
					Internal.State := exASSETINT_STATE_UI_BUFFER;
				END_IF
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle sorting direction change
			IF UISetup.SortingStartTime <> Internal.SortingStartTimeOld AND exLink.RecordCount > 0 THEN
				Internal.State := exASSETINT_STATE_UI_BUFFER;
			END_IF
			Internal.SortingStartTimeOld := UISetup.SortingStartTime;
			
			// -------------------------------------------------------------------------------------------
			// Handle page up and down
			IF UIConnect.Output.PageUp THEN
				Internal.RecordStart := Internal.RecordStart - UI_JOB_LIST_IDX;
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			IF UIConnect.Output.PageDown THEN
				Internal.RecordStart := Internal.RecordStart + UI_JOB_LIST_IDX;					
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle step up and down
			IF UIConnect.Output.StepUp THEN
				Internal.RecordStart := Internal.RecordStart - 1;
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			IF UIConnect.Output.StepDown THEN
				Internal.RecordStart := Internal.RecordStart + 1;					
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Correction for step/page up/down
			IF Internal.RecordStart + UI_JOB_LIST_IDX > Internal.RecordCount THEN
				Internal.RecordStart := Internal.RecordCount - UI_JOB_LIST_IDX;
			END_IF
			IF Internal.RecordStart < 0 THEN
				Internal.RecordStart := 0;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Wait for core task to call update command
			IF exLink.RefreshJobUI AND exLink.RecordCount > 0 THEN			
				Internal.State := exASSETINT_STATE_UI_BUFFER;					
			END_IF
			
			UIConnect.Status := exASSETINT_UI_STATUS_IDLE;
			Active := TRUE;

		// -------------------------------------------------------------------------------------------
		// Copy job data from global buffer to job buffer
		exASSETINT_STATE_UI_BUFFER:
			CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('refresh job data'), Logger);
			UIConnect.Status := exASSETINT_UI_STATUS_UPDATE;

			brsmemset(exLink.MemoryJob, 0, CORE_EVENT_NUM_MAX*SIZEOF(Internal.RecordData));
			
			Internal.RecordCount := 0;
			Internal.y := 0;
			REPEAT
				// Check sorting direction
				IF UISetup.SortingStartTime = exASSETINT_SORTING_ASC THEN
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + Internal.y*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				ELSE
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (exLink.RecordCount - Internal.y - 1)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				END_IF
				
				// Only transfer job data
				IF Internal.RecordData.EventType = RecordTypeJob THEN
					// Only transfer data that matches filter
					IF (NOT UIConnect.Filter.Current.From.Enable AND NOT UIConnect.Filter.Current.Until.Enable) OR 
						(UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.From.DateTime <= Internal.RecordData.TimeStart AND NOT UIConnect.Filter.Current.Until.Enable) OR 	
						(NOT UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.Until.Enable AND UIConnect.Filter.Current.Until.DateTime >= Internal.RecordData.TimeEnd) OR 	
						(UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.From.DateTime <= Internal.RecordData.TimeStart AND UIConnect.Filter.Current.Until.Enable AND UIConnect.Filter.Current.Until.DateTime >= Internal.RecordData.TimeEnd) THEN	
						
						brsmemcpy(exLink.MemoryJob + Internal.RecordCount*SIZEOF(Internal.RecordData), ADR(Internal.RecordData), SIZEOF(Internal.RecordData));
						Internal.RecordCount := Internal.RecordCount + 1;
					END_IF
				END_IF
	  
				Internal.y := Internal.y + 1;
					
				UNTIL (Internal.y = exLink.RecordCount)
			END_REPEAT;
			
			Internal.State := exASSETINT_STATE_UI_DATA;	

		// -------------------------------------------------------------------------------------------
		// Transfer data from buffer to list array
		exASSETINT_STATE_UI_DATA:			
						
			Internal.x := 0;
			REPEAT
				brsmemcpy(ADR(Internal.RecordData), exLink.MemoryJob + (Internal.x + Internal.RecordStart)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				
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
				
				UNTIL (Internal.x = UI_JOB_LIST_IDX) OR (Internal.x + Internal.RecordStart > Internal.RecordCount)
			END_REPEAT;
											
			exLink.RefreshJobUI := FALSE;
			UIConnect.Output.PageUp := FALSE;
			UIConnect.Output.PageDown := FALSE;
			UIConnect.Output.StepUp := FALSE;
			UIConnect.Output.StepDown := FALSE;

			Internal.State := exASSETINT_STATE_IDLE;	
			
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
// Shift UI function block
FUNCTION_BLOCK exAssetIntShiftListUI
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		StatusID := ERR_FUB_ENABLE_FALSE;
		Active := FALSE;
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
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('ERR: exLink is 0'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure we have temporary buffer
				IF exLink.MemoryDb = 0 OR exLink.MemoryShift = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_TEMP_MEMORY, ADR('ERR: no temp memory'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF
				// Make sure core function block is active
				IF NOT exLink.IsCoreActive THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(mpASSETINT_INF_WAIT_CORE_FB, ADR('ERR: core is not active'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;				
				END_IF

				// Reset error and status
				Error := FALSE;
				StatusID := ERR_OK;
				Internal.SortingStartTimeOld := UDINT_TO_DINT(16#FFFFFFFF);
				
				UISetup.OutputListSize := UI_SHIFT_LIST_IDX;			
				UIConnect.Filter.Dialog.LayerStatus := 1;
				UIConnect.Filter.DefaultLayerStatus := 0;
				UIConnect.Filter.Dialog.From.Year := 1970;
				UIConnect.Filter.Dialog.From.Month := 1;
				UIConnect.Filter.Dialog.From.Day := 1;
				UIConnect.Filter.Dialog.Until.Year := 1970;
				UIConnect.Filter.Dialog.Until.Month := 1;
				UIConnect.Filter.Dialog.Until.Day := 1;
				
				UISetup.OutputListSize := UI_JOB_LIST_IDX;

				Internal.State := exASSETINT_STATE_IDLE;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Wait for new event
		exASSETINT_STATE_IDLE:		
			// -------------------------------------------------------------------------------------------
			// Handle dialog window
			IF EDGEPOS(UIConnect.Filter.ShowDialog) THEN
				UIConnect.Filter.Dialog.LayerStatus := 0;
				UIConnect.Filter.DefaultLayerStatus := 2;
				UIConnect.Filter.ShowDialog := FALSE;
			END_IF
			// Dialog is open
			IF UIConnect.Filter.Dialog.LayerStatus = 0 THEN
				// Button cancel
				IF EDGEPOS(UIConnect.Filter.Dialog.Cancel) THEN
					UIConnect.Filter.Dialog.LayerStatus := 1;
					UIConnect.Filter.DefaultLayerStatus := 0;
					UIConnect.Filter.Dialog.Cancel := 0;
				END_IF
				// Button ok
				IF EDGEPOS(UIConnect.Filter.Dialog.Confirm) THEN
					Internal.DT_TO_DTStructure_0.year := UIConnect.Filter.Dialog.From.Year;
					Internal.DT_TO_DTStructure_0.month := UIConnect.Filter.Dialog.From.Month;
					Internal.DT_TO_DTStructure_0.day := UIConnect.Filter.Dialog.From.Day;
					Internal.DT_TO_DTStructure_0.hour := UIConnect.Filter.Dialog.From.Hour;
					Internal.DT_TO_DTStructure_0.minute := UIConnect.Filter.Dialog.From.Minute;
					UIConnect.Filter.Current.From.DateTime := DTStructure_TO_DT(ADR(Internal.DT_TO_DTStructure_0));
					UIConnect.Filter.Current.From.Enable := UIConnect.Filter.Dialog.From.Enable;

					Internal.DT_TO_DTStructure_0.year := UIConnect.Filter.Dialog.Until.Year;
					Internal.DT_TO_DTStructure_0.month := UIConnect.Filter.Dialog.Until.Month;
					Internal.DT_TO_DTStructure_0.day := UIConnect.Filter.Dialog.Until.Day;
					Internal.DT_TO_DTStructure_0.hour := UIConnect.Filter.Dialog.Until.Hour;
					Internal.DT_TO_DTStructure_0.minute := UIConnect.Filter.Dialog.Until.Minute;
					UIConnect.Filter.Current.Until.DateTime := DTStructure_TO_DT(ADR(Internal.DT_TO_DTStructure_0));
					UIConnect.Filter.Current.Until.Enable := UIConnect.Filter.Dialog.Until.Enable;

					UIConnect.Filter.Dialog.LayerStatus := 1;
					UIConnect.Filter.DefaultLayerStatus := 0;
					UIConnect.Filter.Dialog.Confirm := 0;
					
					Internal.State := exASSETINT_STATE_UI_BUFFER;
				END_IF
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle sorting direction change
			IF UISetup.SortingStartTime <> Internal.SortingStartTimeOld AND exLink.RecordCount > 0 THEN
				Internal.State := exASSETINT_STATE_UI_BUFFER;
			END_IF
			Internal.SortingStartTimeOld := UISetup.SortingStartTime;
			
			// -------------------------------------------------------------------------------------------
			// Handle page up and down
			IF UIConnect.Output.PageUp THEN
				Internal.RecordStart := Internal.RecordStart - UI_SHIFT_LIST_IDX;
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			IF UIConnect.Output.PageDown THEN
				Internal.RecordStart := Internal.RecordStart + UI_SHIFT_LIST_IDX;					
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle step up and down
			IF UIConnect.Output.StepUp THEN
				Internal.RecordStart := Internal.RecordStart - 1;
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			IF UIConnect.Output.StepDown THEN
				Internal.RecordStart := Internal.RecordStart + 1;					
				Internal.State := exASSETINT_STATE_UI_DATA;					
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Correction for step/page up/down
			IF Internal.RecordStart + UI_SHIFT_LIST_IDX > Internal.RecordCount THEN
				Internal.RecordStart := Internal.RecordCount - UI_SHIFT_LIST_IDX;
			END_IF
			IF Internal.RecordStart < 0 THEN
				Internal.RecordStart := 0;
			END_IF
				
			// -------------------------------------------------------------------------------------------
			// Wait for core task to call update command
			IF exLink.RefreshShiftUI AND exLink.RecordCount > 0 THEN			
				Internal.State := exASSETINT_STATE_UI_BUFFER;					
			END_IF
			
			UIConnect.Status := exASSETINT_UI_STATUS_IDLE;
			Active := TRUE;

			// -------------------------------------------------------------------------------------------
			// Copy shift data from global buffer to shift buffer
		exASSETINT_STATE_UI_BUFFER:
			CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('refresh shift data'), Logger);
			UIConnect.Status := exASSETINT_UI_STATUS_UPDATE;

			brsmemset(exLink.MemoryShift, 0, CORE_EVENT_NUM_MAX*SIZEOF(Internal.RecordData));
			
			Internal.RecordCount := 0;
			Internal.y := 0;
			REPEAT
				// Check sorting direction
				IF UISetup.SortingStartTime = exASSETINT_SORTING_ASC THEN
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + Internal.y*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				ELSE
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (exLink.RecordCount - Internal.y - 1)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				END_IF
				
				// Only transfer shift data
				IF Internal.RecordData.EventType = RecordTypeShift THEN
					// Only transfer data that matches filter
					IF (NOT UIConnect.Filter.Current.From.Enable AND NOT UIConnect.Filter.Current.Until.Enable) OR 
					   (UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.From.DateTime <= Internal.RecordData.TimeStart AND NOT UIConnect.Filter.Current.Until.Enable) OR 	
					   (NOT UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.Until.Enable AND UIConnect.Filter.Current.Until.DateTime >= Internal.RecordData.TimeEnd) OR 	
   					   (UIConnect.Filter.Current.From.Enable AND UIConnect.Filter.Current.From.DateTime <= Internal.RecordData.TimeStart AND UIConnect.Filter.Current.Until.Enable AND UIConnect.Filter.Current.Until.DateTime >= Internal.RecordData.TimeEnd) THEN	
						
						brsmemcpy(exLink.MemoryShift + Internal.RecordCount*SIZEOF(Internal.RecordData), ADR(Internal.RecordData), SIZEOF(Internal.RecordData));
						Internal.RecordCount := Internal.RecordCount + 1;
					END_IF
				END_IF
	  
				Internal.y := Internal.y + 1;
					
				UNTIL (Internal.y = exLink.RecordCount)
			END_REPEAT;
			
			Internal.State := exASSETINT_STATE_UI_DATA;	

			// -------------------------------------------------------------------------------------------
			// Transfer data from buffer to list array
		exASSETINT_STATE_UI_DATA:	
						
			Internal.x := 0;
			brsmemset(ADR(UIConnect.Output), 0, SIZEOF(UIConnect.Output));
			REPEAT
				brsmemcpy(ADR(Internal.RecordData), exLink.MemoryShift + (Internal.x + Internal.RecordStart)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
				
				UIConnect.Output.StartTime[Internal.x] := Internal.RecordData.TimeStart;
				UIConnect.Output.EndTime[Internal.x] := Internal.RecordData.TimeEnd;
				UIConnect.Output.ShiftName[Internal.x] := Internal.RecordData.ShiftName;
				UIConnect.Output.CurrentUser[Internal.x] := Internal.RecordData.CurrentUser;
				UIConnect.Output.AdditionalData[Internal.x] := Internal.RecordData.AdditionalData;
				UIConnect.Output.TargetPieces[Internal.x] := Internal.RecordData.TargetPieces;
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
				UIConnect.Output.JobName[Internal.x] := Internal.RecordData.JobName;

				Internal.x := Internal.x + 1;
				
				UNTIL (Internal.x = UI_SHIFT_LIST_IDX) OR (Internal.x + Internal.RecordStart > Internal.RecordCount)
			END_REPEAT;
											
			exLink.RefreshShiftUI := FALSE;
			UIConnect.Output.PageUp := FALSE;
			UIConnect.Output.PageDown := FALSE;
			UIConnect.Output.StepUp := FALSE;
			UIConnect.Output.StepDown := FALSE;
			
			Internal.State := exASSETINT_STATE_IDLE;	
			
			// -------------------------------------------------------------------------------------------
			// Error state
		exASSETINT_STATE_ERROR:		
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
END_FUNCTION_BLOCK


