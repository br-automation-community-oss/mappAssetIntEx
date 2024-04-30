
// -------------------------------------------------------------------------------------------
// Core function block
FUNCTION_BLOCK exAssetIntCore
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
				
				// Remember start time
				Internal.DTGetTime_0(enable := TRUE);
				exLink.CoreStartTime := Internal.DTGetTime_0.DT1;
				Internal.JobDiffToCore := exLink.JobTotalTime;
				Internal.ShiftTotalTimeStart := exLink.ShiftTotalTime;
				
				IF exLink.JobStart = DT#1970-01-01-00:00:00 THEN 
					exLink.JobStart := Internal.DTGetTime_0.DT1; 
				END_IF
				
				// Transfer start values
				Info.JobStatistics.JobName := Parameters.Job;
				Info.JobStatistics.CurrentUser := Parameters.CurrentUser;
				Info.JobStatistics.AdditionalData := Parameters.AdditionalData;
				Internal.JobPieceCounterOld := PieceCounter;
				Internal.JobRejectCounterOld := RejectCounter;

				Info.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				Info.ShiftStatistics.AdditionalData := Parameters.AdditionalData;
				Internal.ShiftPieceCounterOld := PieceCounter;
				Internal.ShiftRejectCounterOld := RejectCounter;

				// Reset error, status and function and internal blocks
				Error := FALSE;
				StatusID := ERR_OK;
				Internal.CreateDirStructure(Enable := FALSE);
				Internal.CreateMemory(Enable := FALSE);
				Internal.ReadEventData(Enable := FALSE);
				Internal.WriteEventData(Enable := FALSE);
				Internal.ReadEventData(Enable := FALSE);
				Internal.WriteEventData(Enable := FALSE);
								
				// Create folder structure and read event data only after boot
				IF Internal.InitAfterBoot THEN
					Internal.State := exASSETINT_STATE_IDLE;
				ELSE
					Internal.State := exASSETINT_STATE_INIT_2;
				END_IF
			END_IF

			// -------------------------------------------------------------------------------------------
			// Create folder structure
		exASSETINT_STATE_INIT_2:
			Internal.CreateDirStructure.Enable := TRUE;
			Internal.CreateDirStructure.Device := DeviceName;
			Internal.CreateDirStructure.Logger := Logger;
			Internal.CreateDirStructure();
		
			// Folder structure successful created
			IF Internal.CreateDirStructure.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('create folder structure ok'), Logger);
				Internal.State := exASSETINT_STATE_INIT_3;
			
				// Error
			ELSIF Internal.CreateDirStructure.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.CreateDirStructure.Status, ADR('ERR: create folder structure'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Create internal memory
		exASSETINT_STATE_INIT_3:
			Internal.CreateMemory.Enable := TRUE;
			Internal.CreateMemory.Size := CORE_EVENT_NUM_MAX*SIZEOF(Internal.RecordData);
			Internal.CreateMemory.Logger := Logger;
			Internal.CreateMemory();
		
			// Memory structure successful created
			IF Internal.CreateMemory.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('create internal memory ok'), Logger);
				exLink.MemoryDb := Internal.CreateMemory.MemoryDb;
				exLink.MemoryJob := Internal.CreateMemory.MemoryJob;
				exLink.MemoryShift := Internal.CreateMemory.MemoryShift;
				Internal.State := exASSETINT_STATE_INIT_4;
			
				// Error
			ELSIF Internal.CreateMemory.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.CreateMemory.Status, ADR('ERR: create internal memory'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Read event data
		exASSETINT_STATE_INIT_4:
			Internal.ReadEventData.Enable := TRUE;
			Internal.ReadEventData.Device := DeviceName;
			Internal.ReadEventData.Memory := exLink.MemoryDb;
			Internal.ReadEventData.Logger := Logger;
			Internal.ReadEventData();
		
			// Read events successful
			IF Internal.ReadEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('read stored events ok'), Logger);
				
				// Get record count, calculate next entry
				exLink.RecordCount := Internal.ReadEventData.RecordCount;
				IF exLink.RecordCount > 0 THEN
					// Get last entry, make correction if necessary
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (exLink.RecordCount - 1)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
					brsstrcpy(ADR(Internal.TmpStr), ADR(Internal.RecordData.FileName) + FindInstr(ADR(Internal.RecordData.FileName), ADR('#')) + 1);
					Internal.RecordNext := DINT_TO_UINT(brsatoi(ADR(Internal.TmpStr))) + 1;
					IF Internal.RecordNext >= CORE_EVENT_NUM_MAX THEN
						Internal.RecordNext := 0;
					END_IF
				END_IF
				
				// Refresh UI data, finish up
				exLink.RefreshJobUI := TRUE;
				exLink.RefreshShiftUI := TRUE;
				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.ReadEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.ReadEventData.Status, ADR('ERR: read stored events'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF

			// -------------------------------------------------------------------------------------------
			// Wait for new event
		exASSETINT_STATE_IDLE:
			// Set core active, reset read write function blocks
			Active := TRUE;
			
			Internal.ReadEventData(Enable := FALSE);
			Internal.WriteEventData(Enable := FALSE);
			
			// Update time information
			Internal.DTGetTime_0(enable := TRUE);
			DT_TO_DTStructure(Internal.DTGetTime_0.DT1, ADR(Internal.DT_TO_DTStructure_0));          
			Internal.TimeOfDay := UDINT_TO_TOD((USINT_TO_UDINT(Internal.DT_TO_DTStructure_0.hour) * 3600000) + (USINT_TO_UDINT(Internal.DT_TO_DTStructure_0.minute) * 60000));
			
			// Set stats timer
			Internal.StatsRefresh.IN := TRUE;
			Internal.StatsRefresh.PT := Configuration.CalculationTimeBase/10;	
			Internal.StatsRefresh();
			
			// Track current shift
			Info.ShiftStatistics.ShiftName := '';
			FOR Internal.x := 0 TO SIZEOF(Configuration.Shifts)/SIZEOF(Configuration.Shifts[0]) DO
				// Shift ends on same day
				IF Configuration.Shifts[Internal.x].TotalTime.Start < Configuration.Shifts[Internal.x].TotalTime.End THEN
					IF Internal.TimeOfDay >= Configuration.Shifts[Internal.x].TotalTime.Start AND Internal.TimeOfDay <= Configuration.Shifts[Internal.x].TotalTime.End THEN
						Info.ShiftStatistics.ShiftName := Configuration.Shifts[Internal.x].Name;
						EXIT;
					END_IF
				// Shift ends next day
				ELSE
					IF Internal.TimeOfDay >= Configuration.Shifts[Internal.x].TotalTime.Start OR Internal.TimeOfDay <= Configuration.Shifts[Internal.x].TotalTime.End THEN
						Info.ShiftStatistics.ShiftName := Configuration.Shifts[Internal.x].Name;
						EXIT;
					END_IF
				END_IF
			END_FOR;
			// Make sure we found a shift name
			IF Info.ShiftStatistics.ShiftName = '' THEN
				CreateLoggerEntry(ERR_ASSET_SHIFT_CALC, ADR('no shift active'), Logger);
				RETURN;
			END_IF
			
			// Handle shift change
			IF Info.ShiftStatistics.ShiftName <> exLink.ShiftName THEN	
				Internal.TmpStr := 'new shift started ';
				brsstrcat(ADR(Internal.TmpStr), ADR(Info.ShiftStatistics.ShiftName));
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr), Logger);
				UpdateDone := FALSE;

				// Transfer stats to record, make sure structures are allignent
				brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));
				
				// Collect data for record
				Internal.RecordData.EventType := RecordTypeShift;
				Internal.RecordData.TimeStart := exLink.ShiftStart;
				Internal.RecordData.TimeEnd := Internal.DTGetTime_0.DT1;
				Internal.RecordData.CurrentUser := Info.ShiftStatistics.CurrentUser;
				Internal.RecordData.AdditionalData := Info.ShiftStatistics.AdditionalData;
				Internal.RecordData.ShiftName := Info.ShiftStatistics.ShiftName;
				Internal.RecordData.JobName := Info.JobStatistics.JobName;
				Internal.RecordData.TotalPieces := Info.ShiftStatistics.TotalPieces;
				Internal.RecordData.GoodPieces := Info.ShiftStatistics.GoodPieces;
				Internal.RecordData.RejectPieces := Info.ShiftStatistics.RejectPieces;
				Internal.RecordData.BadPieceRate := Info.ShiftStatistics.BadPieceRate;
				Internal.RecordData.TargetPieces := Info.ShiftStatistics.TargetPieces;
				Internal.RecordData.TotalTime := Info.ShiftStatistics.TotalTime;
				Internal.RecordData.ScheduledDowntime := Info.ShiftStatistics.ScheduledDowntime;
				Internal.RecordData.UnscheduledDowntime := Info.ShiftStatistics.UnscheduledDowntime;
				Internal.RecordData.Uptime := Info.ShiftStatistics.Uptime;
				Internal.RecordData.GoodProductionTime := Info.ShiftStatistics.GoodProductionTime;
				Internal.RecordData.NominalProductionTime := Info.ShiftStatistics.NominalProductionTime;
				Internal.RecordData.NominalProductionTimeRate := Info.ShiftStatistics.NominalProductionTimeRate;
				Internal.RecordData.UnscheduledDowntimeRate := Info.ShiftStatistics.UnscheduledDowntimeRate;
				Internal.RecordData.CurrentProductionRate := Info.ShiftStatistics.CurrentProductionRate;					
			
				// Reset stats and remember new start time
				exLink.ShiftStart := Internal.DTGetTime_0.DT1;
				exLink.ShiftName := Info.ShiftStatistics.ShiftName;				
				exLink.ShiftPieceCounter := 0;
				exLink.ShiftRejectCounter := 0;
				brsmemset(ADR(Info.ShiftStatistics), 0, SIZEOF(Info.ShiftStatistics));

				// Transfer data to shift stats
				Info.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				Info.ShiftStatistics.AdditionalData := Parameters.AdditionalData;
				
				Internal.State := exASSETINT_STATE_STORE_EVENT_1;
				
			END_IF
			
			// Calculate new stats
			IF Internal.StatsRefresh.Q AND Info.ShiftStatistics.ShiftName <> '' THEN
				// Transfer job counter data, reset timer
				IF Internal.JobPieceCounterOld <= PieceCounter THEN					
					exLink.JobPieceCounter := exLink.JobPieceCounter + (PieceCounter - Internal.JobPieceCounterOld);
				ELSE
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('job piece count overflow'), Logger);
					exLink.JobPieceCounter := exLink.JobPieceCounter + (16#FFFFFFFF - Internal.JobPieceCounterOld + PieceCounter);
				END_IF
				
				IF Internal.JobRejectCounterOld <= RejectCounter THEN					
					exLink.JobRejectCounter := exLink.JobRejectCounter + (RejectCounter - Internal.JobRejectCounterOld);
				ELSE
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('job reject count overflow'), Logger);
					exLink.JobRejectCounter := exLink.JobRejectCounter + (16#FFFFFFFF - Internal.JobRejectCounterOld + RejectCounter);
				END_IF
				Internal.JobPieceCounterOld := PieceCounter;
				Internal.JobRejectCounterOld := RejectCounter;
				CalcStatsJob(exLink, Internal.JobDiffToCore, Downtime, Parameters, ADR(Info.JobStatistics));
				
				// Transfer shift counter data, reset timer
				IF Internal.ShiftPieceCounterOld <= PieceCounter THEN					
					exLink.ShiftPieceCounter := exLink.ShiftPieceCounter + (PieceCounter - Internal.ShiftPieceCounterOld);
				ELSE
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('shift piece count overflow'), Logger);
					exLink.ShiftPieceCounter := exLink.ShiftPieceCounter + (16#FFFFFFFF - Internal.ShiftPieceCounterOld + PieceCounter);
				END_IF
				
				IF Internal.ShiftRejectCounterOld <= RejectCounter THEN					
					exLink.ShiftRejectCounter := exLink.ShiftRejectCounter + (RejectCounter - Internal.ShiftRejectCounterOld);
				ELSE
					CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('shift reject count overflow'), Logger);
					exLink.ShiftRejectCounter := exLink.ShiftRejectCounter + (16#FFFFFFFF - Internal.ShiftRejectCounterOld + RejectCounter);
				END_IF
				Internal.ShiftPieceCounterOld := PieceCounter;
				Internal.ShiftRejectCounterOld := RejectCounter;
				CalcStatsShift(exLink, Internal.ShiftDiffToCore, Downtime, Parameters, ADR(Info.ShiftStatistics));

				Internal.StatsRefresh.IN := FALSE;
				Internal.StatsRefresh();
	
			END_IF
			
			// Handle downtime changes
			IF Downtime <> Internal.DowntimeOld THEN
				// Create log message
				Internal.TmpStr := 'downtime changed from ';
				IF Internal.DowntimeOld = exASSETINT_NO_DOWNTIME THEN
					brsstrcat(ADR(Internal.TmpStr), ADR('no downtime to '));
				ELSIF Internal.DowntimeOld = exASSETINT_SCHEDULED_DOWNTIME THEN
					brsstrcat(ADR(Internal.TmpStr), ADR('scheduled to '));
				ELSE
					brsstrcat(ADR(Internal.TmpStr), ADR('unscheduled to '));
				END_IF
				IF Downtime = exASSETINT_NO_DOWNTIME THEN
					brsstrcat(ADR(Internal.TmpStr), ADR('no downtime with reason '));
				ELSIF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
					brsstrcat(ADR(Internal.TmpStr), ADR('scheduled with reason '));
				ELSE
					brsstrcat(ADR(Internal.TmpStr), ADR('unscheduled with reason '));
				END_IF
				brsstrcat(ADR(Internal.TmpStr), ADR(DowntimeReason));
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr), Logger);
				
				// Remember downtime start
				IF Downtime > exASSETINT_NO_DOWNTIME THEN
					exLink.DowntimeStart := Internal.DTGetTime_0.DT1;
				END_IF
				
				Internal.DowntimeOld := Downtime;
			END_IF

			// Handle reset command
			IF EDGEPOS(Reset) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('reset command triggered'), Logger);
				
				// Reset stats and remember new start time
				exLink.JobStart := Internal.DTGetTime_0.DT1;
				exLink.JobTotalTime := 0;
				exLink.JobPieceCounter := 0;
				exLink.JobRejectCounter := 0;

				exLink.ShiftStart := Internal.DTGetTime_0.DT1;
				exLink.ShiftTotalTime := 0;
				exLink.ShiftPieceCounter := 0;
				exLink.ShiftRejectCounter := 0;
			END_IF
			
			// Handle update command
			IF EDGEPOS(Update) THEN	
				// Job has changed
				IF Parameters.Job <> Info.JobStatistics.JobName THEN
					Internal.TmpStr := 'new job started ';
					brsstrcat(ADR(Internal.TmpStr), ADR(Parameters.Job));
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr), Logger);
					UpdateDone := FALSE;

					// Transfer stats to record, make sure structures are allignent
					brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));
					
					// Collect data for record
					Internal.RecordData.EventType := RecordTypeJob;
					Internal.RecordData.TimeStart := exLink.JobStart;
					Internal.RecordData.TimeEnd := Internal.DTGetTime_0.DT1;
					Internal.RecordData.CurrentUser := Info.JobStatistics.CurrentUser;
					Internal.RecordData.AdditionalData := Info.JobStatistics.AdditionalData;
					Internal.RecordData.ShiftName := Info.ShiftStatistics.ShiftName;
					Internal.RecordData.JobName := Info.JobStatistics.JobName;				
					Internal.RecordData.TotalPieces := Info.JobStatistics.TotalPieces;
					Internal.RecordData.GoodPieces := Info.JobStatistics.GoodPieces;
					Internal.RecordData.RejectPieces := Info.JobStatistics.RejectPieces;
					Internal.RecordData.BadPieceRate := Info.JobStatistics.BadPieceRate;
					Internal.RecordData.TotalTime := Info.JobStatistics.TotalTime;
					Internal.RecordData.ScheduledDowntime := Info.JobStatistics.ScheduledDowntime;
					Internal.RecordData.UnscheduledDowntime := Info.JobStatistics.UnscheduledDowntime;
					Internal.RecordData.Uptime := Info.JobStatistics.Uptime;
					Internal.RecordData.GoodProductionTime := Info.JobStatistics.GoodProductionTime;
					Internal.RecordData.NominalProductionTime := Info.JobStatistics.NominalProductionTime;
					Internal.RecordData.NominalProductionTimeRate := Info.JobStatistics.NominalProductionTimeRate;
					Internal.RecordData.UnscheduledDowntimeRate := Info.JobStatistics.UnscheduledDowntimeRate;
					Internal.RecordData.CurrentProductionRate := Info.JobStatistics.CurrentProductionRate;								
				
					// Reset stats and remember new start time
					exLink.JobStart := Internal.DTGetTime_0.DT1;
					exLink.JobPieceCounter := 0;
					exLink.JobRejectCounter := 0;
					brsmemset(ADR(Info.JobStatistics), 0, SIZEOF(Info.JobStatistics));

					// Transfer data to job stats
					Internal.JobDiffToCore := -DiffDT(Internal.DTGetTime_0.DT1, exLink.CoreStartTime);					
					Info.JobStatistics.JobName := Parameters.Job;
					Info.JobStatistics.CurrentUser := Parameters.CurrentUser;
					Info.JobStatistics.AdditionalData := Parameters.AdditionalData;
					
					Internal.State := exASSETINT_STATE_STORE_EVENT_1;
				END_IF
			END_IF

			// -------------------------------------------------------------------------------------------
			// Store new event
		exASSETINT_STATE_STORE_EVENT_1:
			Internal.WriteEventData.Enable := TRUE;
			Internal.WriteEventData.Device := DeviceName;
			Internal.WriteEventData.Logger := Logger;
			Internal.WriteEventData.RecordData := ADR(Internal.RecordData);
			Internal.WriteEventData.RecordNext := Internal.RecordNext;
			Internal.WriteEventData();
		
			// Event successful created
			IF Internal.WriteEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('create new event ok'), Logger);
				
				// Calculate new last record and record count
				Internal.RecordNext := Internal.RecordNext + 1;
				IF Internal.RecordNext >= CORE_EVENT_NUM_MAX THEN
					Internal.RecordNext := 0;
				END_IF
				// Copy new record into memeory
				IF exLink.RecordCount < CORE_EVENT_NUM_MAX THEN
					exLink.RecordCount := exLink.RecordCount + 1;
				ELSE
					brsmemmove(exLink.MemoryDb, exLink.MemoryDb + SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData)*(exLink.RecordCount - 1));										
				END_IF
				brsmemcpy(exLink.MemoryDb + SIZEOF(Internal.RecordData)*(exLink.RecordCount - 1), ADR(Internal.RecordData), SIZEOF(Internal.RecordData));					
				
				// Refrehs UI data, finish up
				exLink.RefreshJobUI := TRUE;
				exLink.RefreshShiftUI := TRUE;
				UpdateDone := TRUE;
				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.WriteEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.WriteEventData.Status, ADR('ERR: create new event'), Logger, exCOM_SEV_ERROR, ADR(Internal.StateError), ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Error state
		exASSETINT_STATE_ERROR:
			
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
	
	// Transfer active state
	exLink.IsCoreActive := Active;

END_FUNCTION_BLOCK



