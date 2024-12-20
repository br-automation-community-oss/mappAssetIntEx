// -------------------------------------------------------------------------------------------
// File version 1002
// -------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------			
// Handle production state change
FUNCTION TrackProductionState
	IF (exLink.ShiftStatistics.ShiftName <> exLink.ProductionShiftName) OR (exLink.JobStatistics.JobName <> exLink.ProductionJobName AND exLink.ShiftId >= 0) OR (exLink.JobStatistics.CurrentUser <> exLink.ProductionUserName AND exLink.ShiftId >= 0) OR (Internal.Downtime <> exLink.ProductionDowntime AND exLink.ShiftId >= 0) OR (Internal.DowntimeReason <> exLink.ProductionDowntimeReason AND exLink.ProductionDowntime > exASSETINT_NO_DOWNTIME) THEN

		// Transfer stats to record, make sure structures are allignent
		brsmemset(ADR(Internal.RecordData), 0, SIZEOF(Internal.RecordData));
					
		// Collect data for record
		Internal.RecordData.TimeStart := exLink.ProductionStateStart;
		Internal.RecordData.TimeEnd := Internal.CurrentTime.DT1;
		Internal.RecordData.ShiftName := exLink.ProductionShiftName;
		Internal.RecordData.JobName := exLink.ProductionJobName;
				
		Internal.ProductionTotalTime := LREAL_TO_UDINT(exLink.ProductionTotalTime/1000);
		Internal.RecordData.TotalTime.Hours := Internal.ProductionTotalTime/3600;
		Internal.RecordData.TotalTime.Minutes := UDINT_TO_USINT((Internal.ProductionTotalTime - Internal.RecordData.TotalTime.Hours*3600)/60);
		Internal.RecordData.TotalTime.Seconds := UDINT_TO_USINT(Internal.ProductionTotalTime - Internal.RecordData.TotalTime.Hours*3600 - Internal.RecordData.TotalTime.Minutes*60);

		// -------------------------------------------------------------------------------------------			
		// State change is shift
		IF exLink.ShiftStatistics.ShiftName <> exLink.ProductionShiftName THEN
			// Set event type
			Internal.RecordData.EventType := UDINT_TO_UINT(exLink.ProductionState + 2);
	
			// Create log message and production state
			Internal.TmpStr1 := 'shift changed from ';
			IF exLink.ProductionState = exASSETINT_STATE_NO_SHIFT_ACTIVE THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('no shift '));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ProductionShiftName));						
			END_IF
			brsstrcat(ADR(Internal.TmpStr1), ADR(' to '));
					
			// State change is to no shift
			IF exLink.ShiftStatistics.ShiftName = '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('no shift'));
				exLink.ProductionState := exASSETINT_STATE_NO_SHIFT_ACTIVE;
		
				// State change is to uptime
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ShiftStatistics.ShiftName));						
				exLink.ProductionState := UDINT_TO_UINT(Internal.Downtime + 1);	
			END_IF
					
			// Remember shift name
			exLink.ProductionShiftName := exLink.ShiftStatistics.ShiftName;
					
			// -------------------------------------------------------------------------------------------			
			// State change is job
		ELSIF exLink.JobStatistics.JobName <> exLink.ProductionJobName THEN
			// Set event type
			Internal.RecordData.EventType := UDINT_TO_UINT(exLink.ProductionState + 2);

			// Create log message
			Internal.TmpStr1 := 'job changed from ';
			IF exLink.ProductionJobName = '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('none '));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ProductionJobName));						
			END_IF
			brsstrcat(ADR(Internal.TmpStr1), ADR(' to '));
					
			// Job name is empty
			IF exLink.JobStatistics.JobName = '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('none'));
				// State change is to uptime
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.JobStatistics.JobName));						
			END_IF
					
			// Remember job name
			exLink.ProductionJobName := exLink.JobStatistics.JobName;
										
			// ----------------------------------------------------	
			// State change is new user
		ELSIF exLink.JobStatistics.CurrentUser <> exLink.ProductionUserName THEN
			// Set event type
			Internal.RecordData.EventType := RecordTypeUserChange;

			// Create log message
			Internal.TmpStr1 := 'user changed from ';
			IF exLink.ProductionUserName <> '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ProductionUserName));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR('none'));
			END_IF
			brsstrcat(ADR(Internal.TmpStr1), ADR(' to '));
					
			// User name is empty
			IF Parameters.CurrentUser = '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('none'));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR(Parameters.CurrentUser));
			END_IF

			// Remember use name
			exLink.ProductionUserName := exLink.JobStatistics.CurrentUser;
			Internal.RecordData.AdditionalData := LEFT(Internal.TmpStr1, SIZEOF(Internal.RecordData.AdditionalData));

			// ----------------------------------------------------	
			// State change is downtime					
		ELSIF Internal.Downtime <> exLink.ProductionDowntime THEN
			// Set event type
			Internal.RecordData.EventType := UDINT_TO_UINT(exLink.ProductionState + 2);

			// Create log message
			Internal.TmpStr1 := 'production state changed from ';
			IF exLink.ProductionState = exASSETINT_STATE_UPTIME THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('uptime to '));
			ELSIF exLink.ProductionState = exASSETINT_STATE_SCHDL_DOWNTIME THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('scheduled dt to '));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR('unscheduled dt to '));
			END_IF
					
			IF Internal.Downtime = exASSETINT_NO_DOWNTIME THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('no downtime'));
			ELSIF Internal.Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR('scheduled dt > '));
				brsstrcat(ADR(Internal.TmpStr1), ADR(Internal.DowntimeReason));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR('unscheduled dt > '));
				brsstrcat(ADR(Internal.TmpStr1), ADR(Internal.DowntimeReason));
			END_IF
	
			IF exLink.ProductionState = exASSETINT_STATE_SCHDL_DOWNTIME OR exLink.ProductionState = exASSETINT_STATE_UNSCH_DOWNTIME THEN
				Internal.RecordData.AdditionalData := exLink.ProductionDowntimeReason;
			END_IF
					
			// Remember downtime and reason, set production state
			exLink.ProductionDowntime := Internal.Downtime;
			exLink.ProductionDowntimeReason := Internal.DowntimeReason;
			exLink.ProductionState := UDINT_TO_UINT(Internal.Downtime + 1);		

			// ----------------------------------------------------	
			// State change is downtime reason				
		ELSE 
			// Set event type
			Internal.RecordData.EventType := UDINT_TO_UINT(exLink.ProductionState + 2);

			// Create log message
			Internal.TmpStr1 := 'dt reason changed from ';
			IF exLink.ProductionDowntimeReason <> '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR(exLink.ProductionDowntimeReason));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR('none'));
			END_IF
			brsstrcat(ADR(Internal.TmpStr1), ADR(' to '));
			IF Internal.DowntimeReason <> '' THEN
				brsstrcat(ADR(Internal.TmpStr1), ADR(Internal.DowntimeReason));
			ELSE
				brsstrcat(ADR(Internal.TmpStr1), ADR('none'));
			END_IF
					
			Internal.RecordData.AdditionalData := exLink.ProductionDowntimeReason;
					
			// Remember downtime reason
			exLink.ProductionDowntimeReason := Internal.DowntimeReason;
		END_IF
					
		CreateLoggerEntry(exASSETINT_LOG_INFO, ADR(Internal.TmpStr1), Logger);
										
		// Remember production start
		IF exLink.ProductionStateStart <> DT#1970-01-01-00:00:00 THEN
			exLink.ProductionStateStart := Internal.CurrentTime.DT1;		
			exLink.ProductionTotalTime := 0;
	
			// Create new event
			Internal.State := exASSETINT_STATE_STORE_EVENT;
				
			// Just remember start time after cold start
		ELSE
			exLink.ProductionStateStart := Internal.CurrentTime.DT1;		
		END_IF
		TrackProductionState := TRUE;
		
	ELSE
		TrackProductionState := FALSE;
				
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
	
	
END_FUNCTION