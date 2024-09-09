
// -------------------------------------------------------------------------------------------
// File version 1001
// -------------------------------------------------------------------------------------------
// Core function block
FUNCTION_BLOCK exAssetIntCore
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		Active := FALSE;
		exLink.IsCoreActive := FALSE;
		StatusID := ERR_FUB_ENABLE_FALSE;
		Internal.State := exASSETINT_STATE_INIT_1;
		CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('function block disabled'), Logger);
		RETURN;
	END_IF
	
	CASE Internal.State OF

		// -------------------------------------------------------------------------------------------
		// Wait for enable
		// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_INIT_1:
			IF Enable THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('function block enabled'), Logger);

				// Make sure we have remanent buffer
				IF ADR(exLink) = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('ERR: exLink is 0'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;			
				END_IF
				// Make sure we have a configuration
				IF ADR(exLink.Configuration) = 0 THEN
					// Set status, remember state, go to error state
					StatusID := CreateErrorState(ERR_ASSET_LINK, ADR('ERR: No configuation attached'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
					RETURN;			
				END_IF
							
				// -------------------------------------------------------------------------------------------
				// Transfer start values
				exLink.RecordCount := 0;
				exLink.JobStatistics.JobName := Parameters.Job;
				exLink.JobStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.JobStatistics.AdditionalData := Parameters.AdditionalData;
				Internal.JobPieceCounterOld := PieceCounter;
				Internal.JobRejectCounterOld := RejectCounter;

				exLink.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.ShiftStatistics.AdditionalData := Parameters.AdditionalData;
				Internal.ShiftPieceCounterOld := PieceCounter;
				Internal.ShiftRejectCounterOld := RejectCounter;
				
				// Transfer configuration
				brsmemcpy(ADR(exLink.Configuration), ADR(Configuration), SIZEOF(Configuration));				

				// -------------------------------------------------------------------------------------------
				// Reset error, status and function and internal blocks
				Error := FALSE;
				StatusID := ERR_OK;
				Internal.CreateDirStructure(Enable := FALSE);
				Internal.CreateMemory(Enable := FALSE);
				Internal.ReadEventData(Enable := FALSE);
				Internal.WriteEventData(Enable := FALSE);
				Internal.ReadEventData(Enable := FALSE);
				Internal.WriteEventData(Enable := FALSE);
				
				// -------------------------------------------------------------------------------------------
				// Check shift configuration for errors
				IF NOT exAssetIntCheckShiftData(exLink.Configuration, Logger, ADR(Internal.State), ADR(StatusID), ADR(Info.Diag.StatusID)) THEN
					RETURN;
				END_IF
								
				// -------------------------------------------------------------------------------------------
				// Create folder structure and read event data only after boot
				IF Internal.InitAfterBoot THEN
					Internal.State := exASSETINT_STATE_INIT_4;
				ELSE
					Internal.State := exASSETINT_STATE_INIT_2;
				END_IF
			END_IF

			// -------------------------------------------------------------------------------------------
			// Create folder structure
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_INIT_2:
			Internal.CreateDirStructure.Enable := TRUE;
			Internal.CreateDirStructure.Device := DeviceName;
			Internal.CreateDirStructure.Logger := Logger;
			Internal.CreateDirStructure();
		
			// -------------------------------------------------------------------------------------------
			// Folder structure successful created
			IF Internal.CreateDirStructure.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('create folder structure ok'), Logger);
				Internal.State := exASSETINT_STATE_INIT_3;
			
				// Error
			ELSIF Internal.CreateDirStructure.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.CreateDirStructure.Status, ADR('ERR: create folder structure'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Create internal memory
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_INIT_3:
			Internal.CreateMemory.Enable := TRUE;
			Internal.CreateMemory.Size := CORE_EVENT_NUM_MAX*SIZEOF(Internal.RecordData);
			Internal.CreateMemory.Logger := Logger;
			Internal.CreateMemory();
			
			// -------------------------------------------------------------------------------------------
			// Memory structure successful created
			IF Internal.CreateMemory.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('create internal memory ok'), Logger);
				exLink.MemoryDb := Internal.CreateMemory.MemoryDb;
				exLink.MemoryJob := Internal.CreateMemory.MemoryJob; 
				exLink.MemoryShift := Internal.CreateMemory.MemoryShift;
				exLink.MemoryTimeline := Internal.CreateMemory.MemoryTimeline;
				Internal.InitAfterBoot := TRUE;
				Internal.State := exASSETINT_STATE_INIT_4;
			
				// Error
			ELSIF Internal.CreateMemory.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.CreateMemory.Status, ADR('ERR: create internal memory'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Read event data
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_INIT_4:
			Internal.ReadEventData.Enable := TRUE;
			Internal.ReadEventData.Device := DeviceName;
			Internal.ReadEventData.Memory := exLink.MemoryDb;
			Internal.ReadEventData.Logger := Logger;
			Internal.ReadEventData();
		
			// Read events successful
			IF Internal.ReadEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('read stored events ok'), Logger);
				
				// -------------------------------------------------------------------------------------------
				// Get record count, calculate next entry
				exLink.RecordCount := Internal.ReadEventData.RecordCount;
				IF exLink.RecordCount > 0 THEN
					// Get last entry, make correction if necessary
					brsmemcpy(ADR(Internal.RecordData), exLink.MemoryDb + (exLink.RecordCount - 1)*SIZEOF(Internal.RecordData), SIZEOF(Internal.RecordData));
					brsstrcpy(ADR(Internal.TmpStr1), ADR(Internal.RecordData.FileName) + FindInstr(ADR(Internal.RecordData.FileName), ADR('#')) + 1);
					Internal.RecordNext := DINT_TO_UINT(brsatoi(ADR(Internal.TmpStr1))) + 1;
					IF Internal.RecordNext >= CORE_EVENT_NUM_MAX THEN
						Internal.RecordNext := 0;
					END_IF
				END_IF
				
				// -------------------------------------------------------------------------------------------
				// Remember start called time
				Internal.TimeLastCallShift := clock_ms();
				Internal.TimeLastCallProduction := clock_ms();
				
				// -------------------------------------------------------------------------------------------
				// Refresh UI data, finish up
				exLink.RefreshJobUI := TRUE;
				exLink.RefreshShiftUI := TRUE;
				exLink.RefreshTimelineUI := TRUE;
				Internal.State := exASSETINT_STATE_IDLE;
				
				// Error
			ELSIF Internal.ReadEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.ReadEventData.Status, ADR('ERR: read stored events'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF

			// -------------------------------------------------------------------------------------------
			// Wait for new event
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_IDLE:
			// Set core active, reset read write function blocks
			Active := TRUE;
			exLink.IsCoreActive := TRUE;
			Internal.ReadEventData(Enable := FALSE);
			Internal.WriteEventData(Enable := FALSE);
			
			// Update time information
			Internal.DTGetTime_0(enable := TRUE);
			DT_TO_DTStructure(Internal.DTGetTime_0.DT1, ADR(Internal.DT_TO_DTStructure_0));          
			Internal.TimeOfDay := UDINT_TO_TOD((USINT_TO_UDINT(Internal.DT_TO_DTStructure_0.hour) * 3600000) + (USINT_TO_UDINT(Internal.DT_TO_DTStructure_0.minute) * 60000) + (USINT_TO_UDINT(Internal.DT_TO_DTStructure_0.second) * 1000));

			// Set stats timer
			Internal.StatsRefresh.IN := TRUE;
			Internal.StatsRefresh.PT := exLink.Configuration.CalculationTimeBase/10;	
			Internal.StatsRefresh();

			// -------------------------------------------------------------------------------------------
			// Track current shift
			Internal.ShiftName := '';
			Internal.ShiftId := -1;
			FOR Internal.x := 0 TO SIZEOF(exLink.Configuration.Shifts)/SIZEOF(exLink.Configuration.Shifts[0]) - 1 DO
				// Shift ends on same day
				IF exLink.Configuration.Shifts[Internal.x].TotalTime.Start < exLink.Configuration.Shifts[Internal.x].TotalTime.End THEN
					IF Internal.TimeOfDay >= exLink.Configuration.Shifts[Internal.x].TotalTime.Start AND Internal.TimeOfDay <= exLink.Configuration.Shifts[Internal.x].TotalTime.End THEN
						Internal.ShiftName := exLink.Configuration.Shifts[Internal.x].Name;
						Internal.ShiftId := UINT_TO_SINT(Internal.x);
						EXIT;
					END_IF
					// Shift ends next day
				ELSE
					IF Internal.TimeOfDay >= exLink.Configuration.Shifts[Internal.x].TotalTime.Start OR Internal.TimeOfDay <= exLink.Configuration.Shifts[Internal.x].TotalTime.End THEN
						Internal.ShiftName := exLink.Configuration.Shifts[Internal.x].Name;
						Internal.ShiftId := UINT_TO_SINT(Internal.x);
						EXIT;
					END_IF
				END_IF
			END_FOR;
			
			// -------------------------------------------------------------------------------------------
			// Track current shift scheduled downtime
			IF exLink.ShiftId >= 0 THEN
				FOR Internal.x := 0 TO SIZEOF(exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime)/SIZEOF(exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[0]) - 1 DO
					// Make sure we have a valid configuration
					IF TOD_TO_UDINT(exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Start) <> 0 OR TOD_TO_UDINT(exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].End) <> 0 THEN
						// Downtime ends on same day
						IF exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Start < exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].End THEN
							IF Internal.TimeOfDay >= exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Start AND Internal.TimeOfDay < exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].End THEN
								Internal.Downtime := exASSETINT_SCHEDULED_DOWNTIME;
								Internal.DowntimeReason := exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Reason;
								EXIT;
							END_IF
						ELSE
							IF Internal.TimeOfDay >= exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Start OR Internal.TimeOfDay < exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].End THEN
								Internal.Downtime := exASSETINT_SCHEDULED_DOWNTIME;
								Internal.DowntimeReason := exLink.Configuration.Shifts[exLink.ShiftId].ScheduledDowntime[Internal.x].Reason;
								EXIT;
							END_IF
						END_IF
					END_IF
				END_FOR;
			END_IF
					
			// -------------------------------------------------------------------------------------------
			// Handle shift change
			IF exLink.ShiftStatistics.ShiftName <> Internal.ShiftName THEN
				// Transfer stats to record, make sure structures are allignent
				brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));

				IF Internal.ShiftName <> '' THEN
					Internal.TmpStr1 := 'new shift started ';
					brsstrcat(ADR(Internal.TmpStr1), ADR(Internal.ShiftName));
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr1), Logger);
				ELSIF exLink.ShiftStatistics.ShiftName <> '' THEN
					Internal.TmpStr1 := 'shift ended ';
					brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ShiftStatistics.ShiftName));
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr1), Logger);
				END_IF
				
				// Only store data when shift name was not empty
				IF exLink.ShiftStatistics.ShiftName <> '' THEN
					// Collect data for record
					Internal.RecordData.EventType := RecordTypeShift;
					Internal.RecordData.TimeStart := exLink.ShiftStatistics.StartTime;
					Internal.DT_TO_DTStructure_0.hour := UDINT_TO_USINT(TOD_TO_UDINT(exLink.Configuration.Shifts[exLink.ShiftId].TotalTime.End)/3600000);
					Internal.DT_TO_DTStructure_0.minute := UDINT_TO_USINT((TOD_TO_UDINT(exLink.Configuration.Shifts[exLink.ShiftId].TotalTime.End) - Internal.DT_TO_DTStructure_0.hour*3600000)/60000);
					Internal.RecordData.TimeEnd := DTStructure_TO_DT(ADR(Internal.DT_TO_DTStructure_0));
					Internal.RecordData.CurrentUser := exLink.ShiftStatistics.CurrentUser;
					Internal.RecordData.AdditionalData := exLink.ShiftStatistics.AdditionalData;
					Internal.RecordData.ShiftName := exLink.ShiftStatistics.ShiftName;
					Internal.RecordData.JobName := exLink.JobStatistics.JobName;
					Internal.RecordData.TotalPieces := exLink.ShiftStatistics.TotalPieces;
					Internal.RecordData.GoodPieces := exLink.ShiftStatistics.GoodPieces;
					Internal.RecordData.RejectPieces := exLink.ShiftStatistics.RejectPieces;
					Internal.RecordData.BadPieceRate := exLink.ShiftStatistics.BadPieceRate;
					Internal.RecordData.TargetPieces := exLink.ShiftStatistics.TargetPieces;
					Internal.RecordData.TotalTime := exLink.ShiftStatistics.TotalTime;
					Internal.RecordData.ScheduledDowntime := exLink.ShiftStatistics.ScheduledDowntime;
					Internal.RecordData.UnscheduledDowntime := exLink.ShiftStatistics.UnscheduledDowntime;
					Internal.RecordData.Uptime := exLink.ShiftStatistics.Uptime;
					Internal.RecordData.GoodProductionTime := exLink.ShiftStatistics.GoodProductionTime;
					Internal.RecordData.NominalProductionTime := exLink.ShiftStatistics.NominalProductionTime;
					Internal.RecordData.NominalProductionTimeRate := exLink.ShiftStatistics.NominalProductionTimeRate;
					Internal.RecordData.UnscheduledDowntimeRate := exLink.ShiftStatistics.UnscheduledDowntimeRate;
					Internal.RecordData.CurrentProductionRate := exLink.ShiftStatistics.CurrentProductionRate;					
					
					Internal.State := exASSETINT_STATE_STORE_EVENT;
				END_IF				
				
				// Remember job start time
				IF exLink.JobStatistics.StartTime = DT#1970-01-01-00:00:00 THEN 
					exLink.JobStatistics.StartTime := Internal.DTGetTime_0.DT1; 
				END_IF
				
				// Reset stats
				brsmemset(ADR(Info.ShiftStatistics), 0, SIZEOF(Info.ShiftStatistics));
				brsmemset(ADR(exLink.ShiftStatistics), 0, SIZEOF(exLink.ShiftStatistics));

				exLink.ShiftTotalTime := 0;
				exLink.ShiftDowntimeScheduled := 0;
				exLink.ShiftDowntimeUnscheduled := 0;

				// Transfer data to shift stats
				exLink.ShiftId := Internal.ShiftId;
				exLink.ShiftStatistics.StartTime := Internal.DTGetTime_0.DT1;
				exLink.ShiftStatistics.ShiftName := Internal.ShiftName;
				exLink.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.ShiftStatistics.AdditionalData := Parameters.AdditionalData;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Calculate shift and job statistics
			IF Internal.ShiftName <> '' THEN
			
				// Calculate new stats
				IF Internal.StatsRefresh.Q THEN
					// Get time difference between calls
					Internal.DiffLastCallShift := DiffT(clock_ms(), Internal.TimeLastCallShift);
					Internal.TimeLastCallShift := clock_ms();
					
					// Handle diff timer overflow
					IF Internal.DiffLastCallShift = 16#FFFFFFFF THEN
						CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('diff timer overflow'), Logger);
					ELSE
					
						// Do not count when downtime is active
						IF Downtime = exASSETINT_NO_DOWNTIME THEN
							// Transfer job counter data
							IF Internal.JobPieceCounterOld <= PieceCounter THEN					
								exLink.JobStatistics.TotalPieces := exLink.JobStatistics.TotalPieces + (PieceCounter - Internal.JobPieceCounterOld);
							ELSE
								CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('job piece count overflow'), Logger);
								exLink.JobStatistics.TotalPieces := exLink.JobStatistics.TotalPieces + (16#FFFFFFFF - Internal.JobPieceCounterOld + PieceCounter);
							END_IF
							
							IF Internal.JobRejectCounterOld <= RejectCounter THEN					
								exLink.JobStatistics.RejectPieces := exLink.JobStatistics.RejectPieces + (RejectCounter - Internal.JobRejectCounterOld);
							ELSE
								CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('job reject count overflow'), Logger);
								exLink.JobStatistics.RejectPieces := exLink.JobStatistics.RejectPieces + (16#FFFFFFFF - Internal.JobRejectCounterOld + RejectCounter);
							END_IF
						END_IF
						Internal.JobPieceCounterOld := PieceCounter;
						Internal.JobRejectCounterOld := RejectCounter;
						CalcStatsJob(exLink, Internal.DiffLastCallShift, Downtime, Parameters, ADR(Info.JobStatistics));
						
						// Do not count when downtime is active
						IF Downtime = exASSETINT_NO_DOWNTIME THEN
							// Transfer shift counter data
							IF Internal.ShiftPieceCounterOld <= PieceCounter THEN					
								exLink.ShiftStatistics.TotalPieces := exLink.ShiftStatistics.TotalPieces + (PieceCounter - Internal.ShiftPieceCounterOld);
							ELSE
								CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('shift piece count overflow'), Logger);
								exLink.ShiftStatistics.TotalPieces := exLink.ShiftStatistics.TotalPieces + (16#FFFFFFFF - Internal.ShiftPieceCounterOld + PieceCounter);
							END_IF
							
							IF Internal.ShiftRejectCounterOld <= RejectCounter THEN					
								exLink.ShiftStatistics.RejectPieces := exLink.ShiftStatistics.RejectPieces + (RejectCounter - Internal.ShiftRejectCounterOld);
							ELSE
								CreateLoggerEntry(exASSETINT_LOG_ERROR, ADR('shift reject count overflow'), Logger);
								exLink.ShiftStatistics.RejectPieces := exLink.ShiftStatistics.RejectPieces + (16#FFFFFFFF - Internal.ShiftRejectCounterOld + RejectCounter);
							END_IF
						END_IF
						Internal.ShiftPieceCounterOld := PieceCounter;
						Internal.ShiftRejectCounterOld := RejectCounter;
						CalcStatsShift(exLink, Internal.DiffLastCallShift, Downtime, Parameters, ADR(Info.ShiftStatistics));
						
						// Transfer shift data to main function block
						CurrentProductionRate := exLink.ShiftStatistics.CurrentProductionRate;
						NominalProductionTimeRate := exLink.ShiftStatistics.NominalProductionTimeRate;
						BadPieceRate := exLink.ShiftStatistics.BadPieceRate;
						ScheduledDowntimeRate := exLink.ShiftStatistics.ScheduledDowntimeRate;
						UnscheduledDowntimeRate := exLink.ShiftStatistics.UnscheduledDowntimeRate;
						
					END_IF			
				END_IF
				
				// When no shift is active
			ELSE
				// Dont count when no shift is active, reset last call
				Internal.ShiftPieceCounterOld := PieceCounter;
				Internal.ShiftRejectCounterOld := RejectCounter;
				Internal.JobPieceCounterOld := PieceCounter;
				Internal.JobRejectCounterOld := RejectCounter;

				Internal.TimeLastCallShift := clock_ms();
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle production state change
			IF Internal.State <> exASSETINT_STATE_STORE_EVENT THEN
				IF (exLink.ShiftStatistics.ShiftName <> exLink.ProductionShiftName) OR (exLink.JobStatistics.JobName <> exLink.ProductionJobName AND exLink.ShiftId >= 0) OR (Downtime <> exLink.ProductionDowntime AND exLink.ShiftId >= 0) THEN
					// Create log message
					Internal.TmpStr1 := 'production state changed from ';
					IF exLink.ProductionState = exASSETINT_STATE_NO_SHIFT_ACTIVE THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('no shift to '));
					ELSIF exLink.ProductionState = exASSETINT_STATE_UPTIME THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('uptime to '));
					ELSIF exLink.ProductionState = exASSETINT_STATE_SCHDL_DOWNTIME THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('scheduled dt to '));
					ELSE
						brsstrcat(ADR(Internal.TmpStr1), ADR('unscheduled dt to '));
					END_IF
						
					// Transfer stats to record, make sure structures are allignent
					brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));
					
					// Collect data for record
					Internal.RecordData.TimeStart := exLink.ProductionStateStart;
					Internal.RecordData.TimeEnd := Internal.DTGetTime_0.DT1;
					Internal.RecordData.ShiftName := exLink.ProductionShiftName;
					Internal.RecordData.JobName := exLink.ProductionJobName;
					Internal.RecordData.EventType := UDINT_TO_UINT(exLink.ProductionState + 2);
				
					Internal.ProductionTotalTime := LREAL_TO_UDINT(exLink.ProductionTotalTime/1000);
					Internal.RecordData.TotalTime.Hours := Internal.ProductionTotalTime/3600;
					Internal.RecordData.TotalTime.Minutes := UDINT_TO_USINT((Internal.ProductionTotalTime - Internal.RecordData.TotalTime.Hours*3600)/60);
					Internal.RecordData.TotalTime.Seconds := UDINT_TO_USINT(Internal.ProductionTotalTime - Internal.RecordData.TotalTime.Hours*3600 - Internal.RecordData.TotalTime.Minutes*60);
	
					// State change is new job
					IF (exLink.JobStatistics.JobName <> exLink.ProductionJobName) THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('new job > '));
						brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.JobStatistics.JobName));
						exLink.ProductionState := exASSETINT_STATE_UPTIME;
	
						// State change is to no shift
					ELSIF (exLink.ProductionShiftName <> '' AND exLink.ShiftStatistics.ShiftName = '') THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('no shift'));
						exLink.ProductionState := exASSETINT_STATE_NO_SHIFT_ACTIVE;
	
						// State change is to uptime
					ELSIF (exLink.ProductionShiftName = '' AND exLink.ShiftStatistics.ShiftName <> '') THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('uptime'));
						exLink.ProductionState := exASSETINT_STATE_UPTIME;

						// State is shift change
					ELSIF (exLink.ProductionShiftName <> exLink.ShiftStatistics.ShiftName) THEN
						brsstrcat(ADR(Internal.TmpStr1), ADR('new shift'));
						exLink.ProductionState := exASSETINT_STATE_UPTIME;
						
						// State change is downtime 
					ELSE
						IF Downtime = exASSETINT_NO_DOWNTIME THEN
							brsstrcat(ADR(Internal.TmpStr1), ADR('no downtime'));
						ELSIF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
							brsstrcat(ADR(Internal.TmpStr1), ADR('scheduled dt > '));
							brsstrcat(ADR(Internal.TmpStr1), ADR(DowntimeReason));
						ELSE
							brsstrcat(ADR(Internal.TmpStr1), ADR('unscheduled dt > '));
							brsstrcat(ADR(Internal.TmpStr1), ADR(DowntimeReason));
						END_IF
	
						IF exLink.ProductionState = exASSETINT_STATE_SCHDL_DOWNTIME OR exLink.ProductionState = exASSETINT_STATE_UNSCH_DOWNTIME THEN
							Internal.RecordData.AdditionalData := DowntimeReason;
						END_IF
						exLink.ProductionState := UDINT_TO_UINT(Downtime + 1);				
					END_IF
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr1), Logger);
											
					exLink.ProductionShiftName :=exLink.ShiftStatistics.ShiftName;
					exLink.ProductionJobName := exLink.JobStatistics.JobName;
					exLink.ProductionDowntime := Downtime;
	
					// Skip after cold start
					IF exLink.ProductionStateStart <> DT#1970-01-01-00:00:00 THEN
						exLink.ProductionStateStart := Internal.DTGetTime_0.DT1;		
						exLink.ProductionTotalTime := 0;
	
						// Create new event
						Internal.State := exASSETINT_STATE_STORE_EVENT;
				
						// Just remember start time after cold start
					ELSE
						exLink.ProductionStateStart := Internal.DTGetTime_0.DT1;		
					END_IF
					
				END_IF
			END_IF
			// Remember production duration
			IF Internal.StatsRefresh.Q THEN
				// Get time difference between calls
				Internal.DiffLastCallProduction := DiffT(clock_ms(), Internal.TimeLastCallProduction);
				Internal.TimeLastCallProduction := clock_ms();
				IF Internal.DiffLastCallProduction = 16#FFFFFFFF THEN
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('diff timer overflow'), Logger);
				ELSE
					exLink.ProductionTotalTime := exLink.ProductionTotalTime + Internal.DiffLastCallProduction;					
				END_IF
			END_IF	
			
			// -------------------------------------------------------------------------------------------
			// Handle update command
			IF EDGEPOS(Update) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('update command triggered'), Logger);

				// -------------------------------------------------------------------------------------------
				// Check shift configuration for errors
				IF NOT exAssetIntCheckShiftData(exLink.Configuration, Logger, ADR(Internal.State), ADR(StatusID), ADR(Info.Diag.StatusID)) THEN
					RETURN;
				END_IF
				
				// Transfer username and additional data
				exLink.JobStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.JobStatistics.AdditionalData := Parameters.AdditionalData;

				exLink.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.ShiftStatistics.AdditionalData := Parameters.AdditionalData;
				
				// Transfer configuration
				brsmemcpy(ADR(exLink.Configuration), ADR(Configuration), SIZEOF(Configuration));				

				// Job has changed
				IF Parameters.Job <> exLink.JobStatistics.JobName THEN
					Internal.TmpStr1 := 'new job started ';
					brsstrcat(ADR(Internal.TmpStr1), ADR(Parameters.Job));
					CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr1), Logger);

					CommandBusy := TRUE;
					CommandDone := FALSE;
					UpdateDone := FALSE;

					// Transfer stats to record, make sure structures are allignent
					brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));
					
					// Collect data for record
					Internal.RecordData.EventType := RecordTypeJob;
					Internal.RecordData.TimeStart := exLink.JobStatistics.StartTime;
					Internal.RecordData.TimeEnd := Internal.DTGetTime_0.DT1;
					Internal.RecordData.CurrentUser := Parameters.CurrentUser;
					Internal.RecordData.AdditionalData := Parameters.AdditionalData;
					Internal.RecordData.ShiftName := exLink.ShiftStatistics.ShiftName;
					Internal.RecordData.JobName := exLink.JobStatistics.JobName;				
					Internal.RecordData.TotalPieces := exLink.JobStatistics.TotalPieces;
					Internal.RecordData.GoodPieces := exLink.JobStatistics.GoodPieces;
					Internal.RecordData.RejectPieces := exLink.JobStatistics.RejectPieces;
					Internal.RecordData.BadPieceRate := exLink.JobStatistics.BadPieceRate;
					Internal.RecordData.TotalTime := exLink.JobStatistics.TotalTime;
					Internal.RecordData.ScheduledDowntime := exLink.JobStatistics.ScheduledDowntime;
					Internal.RecordData.UnscheduledDowntime := exLink.JobStatistics.UnscheduledDowntime;
					Internal.RecordData.Uptime := exLink.JobStatistics.Uptime;
					Internal.RecordData.GoodProductionTime := exLink.JobStatistics.GoodProductionTime;
					Internal.RecordData.NominalProductionTime := exLink.JobStatistics.NominalProductionTime;
					Internal.RecordData.NominalProductionTimeRate := exLink.JobStatistics.NominalProductionTimeRate;
					Internal.RecordData.UnscheduledDowntimeRate := exLink.JobStatistics.UnscheduledDowntimeRate;
					Internal.RecordData.CurrentProductionRate := exLink.JobStatistics.CurrentProductionRate;								
				
					// Reset stats and remember new start time
					brsmemset(ADR(Info.JobStatistics), 0, SIZEOF(Info.JobStatistics));
					brsmemset(ADR(exLink.JobStatistics), 0, SIZEOF(exLink.JobStatistics));

					exLink.JobTotalTime := 0;
					exLink.JobDowntimeScheduled := 0;
					exLink.JobDowntimeUnscheduled := 0;
					
					// Transfer data to job stats
					exLink.JobStatistics.StartTime := Internal.DTGetTime_0.DT1;
					exLink.JobStatistics.JobName := Parameters.Job;
					exLink.JobStatistics.CurrentUser := Parameters.CurrentUser;
					exLink.JobStatistics.AdditionalData := Parameters.AdditionalData;
					
					Internal.State := exASSETINT_STATE_STORE_EVENT;
				ELSE
					CommandBusy := FALSE;
					CommandDone := TRUE;
					UpdateDone := TRUE;
				END_IF
				
			END_IF
			
			IF NOT Update THEN
				UpdateDone := FALSE;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Handle reset command
			IF EDGEPOS(Reset) THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('reset command triggered'), Logger);

				CommandBusy := TRUE;
				CommandDone := FALSE;
				
				// Reset stats
				brsmemset(ADR(Info.JobStatistics), 0, SIZEOF(Info.JobStatistics));
				brsmemset(ADR(exLink.JobStatistics), 0, SIZEOF(exLink.JobStatistics));

				exLink.JobTotalTime := 0;
				exLink.JobDowntimeScheduled := 0;
				exLink.JobDowntimeUnscheduled := 0;
					
				// Transfer data to job stats
				exLink.JobStatistics.StartTime := Internal.DTGetTime_0.DT1;
				exLink.JobStatistics.JobName := Parameters.Job;
				exLink.JobStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.JobStatistics.AdditionalData := Parameters.AdditionalData;

				// Reset stats
				brsmemset(ADR(Info.ShiftStatistics), 0, SIZEOF(Info.ShiftStatistics));
				brsmemset(ADR(exLink.ShiftStatistics), 0, SIZEOF(exLink.ShiftStatistics));

				exLink.ShiftTotalTime := 0;
				exLink.ShiftDowntimeScheduled := 0;
				exLink.ShiftDowntimeUnscheduled := 0;

				// Transfer data to shift stats
				exLink.ShiftId := Internal.ShiftId;			
				exLink.ShiftStatistics.StartTime := Internal.DTGetTime_0.DT1;
				exLink.ShiftStatistics.ShiftName := Internal.ShiftName;
				exLink.ShiftStatistics.CurrentUser := Parameters.CurrentUser;
				exLink.ShiftStatistics.AdditionalData := Parameters.AdditionalData;

				CommandBusy := FALSE;
				CommandDone := TRUE;
			END_IF
					
			// -------------------------------------------------------------------------------------------
			// Handle export command
			IF EDGEPOS(Export) THEN	

				CommandBusy := TRUE;
				CommandDone := FALSE;
				ExportDone := FALSE;
	
				Internal.State := exASSETINT_STATE_EXPORT_EVENTS;
			END_IF
			
			IF NOT Export THEN
				ExportDone := FALSE;
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Reset refresh timer
			IF Internal.StatsRefresh.Q THEN
				// Set stats timer
				Internal.StatsRefresh.IN := FALSE;
				Internal.StatsRefresh();
			END_IF
			
			IF Update = FALSE AND Export = FALSE AND Reset = FALSE THEN
				CommandDone := FALSE;
			END_IF

			// -------------------------------------------------------------------------------------------
			// Store new event
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_STORE_EVENT:
			Internal.WriteEventData.Enable := TRUE;
			Internal.WriteEventData.Device := StorageName;
			Internal.WriteEventData.Logger := Logger;
			Internal.WriteEventData.RecordData := ADR(Internal.RecordData);
			Internal.WriteEventData.RecordNext := Internal.RecordNext;
			Internal.WriteEventData();
		
			// -------------------------------------------------------------------------------------------
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
				exLink.RefreshTimelineUI := TRUE;

				UpdateDone := TRUE;
				CommandBusy := FALSE;
				CommandDone := TRUE;

				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.WriteEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.WriteEventData.Status, ADR('ERR: create new event'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Export all events
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_EXPORT_EVENTS:
			Internal.ExportEventData.Enable := TRUE;
			Internal.ExportEventData.Device := DeviceName;
			Internal.ExportEventData.Logger := Logger;
			Internal.ExportEventData.RecordCount := exLink.RecordCount;
			Internal.ExportEventData.Memory := exLink.MemoryDb;
			Internal.ExportEventData.Configuration := exLink.Configuration.Export;
			Internal.ExportEventData();
		
			// -------------------------------------------------------------------------------------------
			// Event successful created
			IF Internal.ExportEventData.Status = ERR_OK THEN
				CreateLoggerEntry(exASSETINT_LOG_INFO, ADR('export events ok'), Logger);
				
				ExportDone := TRUE;
				CommandBusy := FALSE;
				CommandDone := TRUE;

				StatusID := ERR_OK;
				Internal.State := exASSETINT_STATE_IDLE;
			
				// Error
			ELSIF Internal.ExportEventData.Status <> ERR_FUB_BUSY THEN
				// Set status, remember state, go to error state
				StatusID := CreateErrorState(Internal.ExportEventData.Status, ADR('ERR: export events'), Logger, exCOM_SEV_ERROR,  ADR(Internal.State), ADR(Info.Diag.StatusID));
			END_IF
			
			// -------------------------------------------------------------------------------------------
			// Error state
			// -------------------------------------------------------------------------------------------
		exASSETINT_STATE_ERROR:
			
			// Reset error state
			IF EDGEPOS(ErrorReset) THEN
				Internal.StateError := exASSETINT_STATE_NONE;
				Internal.State := exASSETINT_STATE_INIT_1;
			END_IF
	END_CASE;
	
END_FUNCTION_BLOCK



