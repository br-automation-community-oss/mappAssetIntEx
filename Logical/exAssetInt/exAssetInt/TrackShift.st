// -------------------------------------------------------------------------------------------
// File version 1000
// -------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------			
// Handle shift change
FUNCTION TackShiftChange
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
			TackShiftChange := TRUE;

		ELSE
			TackShiftChange := FALSE;
			
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
	
END_FUNCTION