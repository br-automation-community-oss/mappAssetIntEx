// -------------------------------------------------------------------------------------------
// Calculate current job statistics
FUNCTION CalcStatsJob
	DTGetTime_0(enable := TRUE);

	// -------------------------------------------------------------------------------------------
	// Calculate total time
	exLink.JobTotalTime := DiffDT(DTGetTime_0.DT1, exLink.CoreStartTime) + DiffToCore;
	JobStatistics.TotalTime.Hours := exLink.JobTotalTime/3600;
	JobStatistics.TotalTime.Minutes := UDINT_TO_USINT((exLink.JobTotalTime - JobStatistics.TotalTime.Hours*3600)/60);
	JobStatistics.TotalTime.Seconds := UDINT_TO_USINT(exLink.JobTotalTime - JobStatistics.TotalTime.Hours*3600 - JobStatistics.TotalTime.Minutes*60);
	// Calculate scheduled downtime
	IF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
		DowntimeScheduled := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart);
		JobStatistics.ScheduledDowntime.Hours := DowntimeScheduled/3600;
		JobStatistics.ScheduledDowntime.Minutes := UDINT_TO_USINT((DowntimeScheduled - JobStatistics.ScheduledDowntime.Hours*3600)/60);
		JobStatistics.ScheduledDowntime.Seconds := UDINT_TO_USINT(DowntimeScheduled - JobStatistics.ScheduledDowntime.Hours*3600 - JobStatistics.ScheduledDowntime.Minutes*60);
	END_IF
	// Calculate undscheduled downtime
	IF Downtime = exASSETINT_UNSCHEDULED_DOWNTIME THEN
		DowntimeUnscheduled := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart);
		JobStatistics.UnscheduledDowntime.Hours := DowntimeUnscheduled/3600;
		JobStatistics.UnscheduledDowntime.Minutes := UDINT_TO_USINT((DowntimeUnscheduled - JobStatistics.UnscheduledDowntime.Hours*3600)/60);
		JobStatistics.UnscheduledDowntime.Seconds := UDINT_TO_USINT(DowntimeUnscheduled - JobStatistics.UnscheduledDowntime.Hours*3600 - JobStatistics.UnscheduledDowntime.Minutes*60);
	END_IF
	// Calculate uptime
	IF Downtime = exASSETINT_NO_DOWNTIME THEN
		Uptime := exLink.JobTotalTime - DowntimeScheduled - DowntimeUnscheduled;
		JobStatistics.Uptime.Hours := Uptime/3600;
		JobStatistics.Uptime.Minutes := UDINT_TO_USINT((Uptime - JobStatistics.Uptime.Hours*3600)/60);
		JobStatistics.Uptime.Seconds := UDINT_TO_USINT(Uptime - JobStatistics.Uptime.Hours*3600 - JobStatistics.Uptime.Minutes*60);
	END_IF
	
	// -------------------------------------------------------------------------------------------
	// Calculate counters
	JobStatistics.TotalPieces := exLink.PieceCounter;
	JobStatistics.RejectPieces := exLink.RejectCounter;
	IF exLink.PieceCounter > exLink.RejectCounter THEN
		JobStatistics.GoodPieces := exLink.PieceCounter - exLink.RejectCounter;
	ELSE
		JobStatistics.GoodPieces := 0;
		JobStatistics.RejectPieces := exLink.PieceCounter;		
	END_IF	
	IF JobStatistics.TotalPieces > 0 THEN
		JobStatistics.BadPieceRate := UDINT_TO_REAL(exLink.RejectCounter)/UDINT_TO_REAL(JobStatistics.TotalPieces);
	END_IF

	// -------------------------------------------------------------------------------------------
	// Additional times and rates
	NominalProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(JobStatistics.TotalPieces)*(3600/Parameter.NominalProductionRate));
	JobStatistics.NominalProductionTime.Hours := NominalProductionTime/3600;
	JobStatistics.NominalProductionTime.Minutes := UDINT_TO_USINT((NominalProductionTime - JobStatistics.NominalProductionTime.Hours*3600)/60);
	JobStatistics.NominalProductionTime.Seconds := UDINT_TO_USINT(NominalProductionTime - JobStatistics.NominalProductionTime.Hours*3600 - JobStatistics.NominalProductionTime.Minutes*60);
	
	GoodProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(JobStatistics.GoodPieces)*(3600/Parameter.NominalProductionRate));
	JobStatistics.GoodProductionTime.Hours := GoodProductionTime/3600;
	JobStatistics.GoodProductionTime.Minutes := UDINT_TO_USINT((GoodProductionTime - JobStatistics.GoodProductionTime.Hours*3600)/60);
	JobStatistics.GoodProductionTime.Seconds := UDINT_TO_USINT(GoodProductionTime - JobStatistics.GoodProductionTime.Hours*3600 - JobStatistics.GoodProductionTime.Minutes*60);
	
	IF DowntimeScheduled > 0 THEN
		JobStatistics.ScheduledDowntimeRate := UDINT_TO_REAL(DowntimeScheduled)/UDINT_TO_REAL(exLink.JobTotalTime);
	END_IF
	IF DowntimeUnscheduled > 0 THEN
		JobStatistics.UnscheduledDowntimeRate := UDINT_TO_REAL(DowntimeUnscheduled)/UDINT_TO_REAL(exLink.JobTotalTime);
	END_IF
	IF Uptime > 0 THEN
		JobStatistics.NominalProductionTimeRate := UDINT_TO_REAL(NominalProductionTime)/UDINT_TO_REAL(Uptime);
	END_IF
	IF exLink.JobTotalTime > 0 THEN
		JobStatistics.CurrentProductionRate := UDINT_TO_REAL(JobStatistics.TotalPieces)/UDINT_TO_REAL(exLink.JobTotalTime);
	END_IF
	
	CalcStatsJob := TRUE;
END_FUNCTION

// -------------------------------------------------------------------------------------------
// Calculate current shift statistics
FUNCTION CalcStatsShift
//	
//	// -------------------------------------------------------------------------------------------
//	// Calculate total time
//	TotalTime := DiffDT(DTGetTime_0.DT1, exLink.ShiftStart);
//	ShiftStatistics.TotalTime.Hours := TotalTime/3600;
//	ShiftStatistics.TotalTime.Minutes := UDINT_TO_USINT((TotalTime - ShiftStatistics.TotalTime.Hours*3600)/60);
//	ShiftStatistics.TotalTime.Seconds := UDINT_TO_USINT(TotalTime - ShiftStatistics.TotalTime.Hours*3600 - ShiftStatistics.TotalTime.Minutes*60);
//	// Calculate scheduled downtime
//	IF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
//		DowntimeScheduled := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart);
//		ShiftStatistics.ScheduledDowntime.Hours := DowntimeScheduled/3600;
//		ShiftStatistics.ScheduledDowntime.Minutes := UDINT_TO_USINT((DowntimeScheduled - ShiftStatistics.ScheduledDowntime.Hours*3600)/60);
//		ShiftStatistics.ScheduledDowntime.Seconds := UDINT_TO_USINT(DowntimeScheduled - ShiftStatistics.ScheduledDowntime.Hours*3600 - ShiftStatistics.ScheduledDowntime.Minutes*60);
//	END_IF
//	// Calculate undscheduled downtime
//	IF Downtime = exASSETINT_UNSCHEDULED_DOWNTIME THEN
//		DowntimeUnscheduled := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart);
//		ShiftStatistics.UnscheduledDowntime.Hours := DowntimeUnscheduled/3600;
//		ShiftStatistics.UnscheduledDowntime.Minutes := UDINT_TO_USINT((DowntimeUnscheduled - ShiftStatistics.UnscheduledDowntime.Hours*3600)/60);
//		ShiftStatistics.UnscheduledDowntime.Seconds := UDINT_TO_USINT(DowntimeUnscheduled - ShiftStatistics.UnscheduledDowntime.Hours*3600 - ShiftStatistics.UnscheduledDowntime.Minutes*60);
//	END_IF
//	// Calculate uptime
//	IF Downtime = exASSETINT_NO_DOWNTIME THEN
//		Uptime := TotalTime - DowntimeScheduled - DowntimeUnscheduled;
//		ShiftStatistics.Uptime.Hours := Uptime/3600;
//		ShiftStatistics.Uptime.Minutes := UDINT_TO_USINT((Uptime - ShiftStatistics.Uptime.Hours*3600)/60);
//		ShiftStatistics.Uptime.Seconds := UDINT_TO_USINT(Uptime - ShiftStatistics.Uptime.Hours*3600 - ShiftStatistics.Uptime.Minutes*60);
//	END_IF
//	
//	// -------------------------------------------------------------------------------------------
//	// Calculate counters
//	ShiftStatistics.TotalPieces := exLink.PieceCounter;
//	ShiftStatistics.RejectPieces := exLink.RejectCounter;
//	IF exLink.PieceCounter > exLink.RejectCounter THEN
//		ShiftStatistics.GoodPieces := exLink.PieceCounter - exLink.RejectCounter;
//	ELSE
//		ShiftStatistics.GoodPieces := 0;
//		ShiftStatistics.RejectPieces := exLink.PieceCounter;		
//	END_IF	
//	IF ShiftStatistics.TotalPieces > 0 THEN
//		ShiftStatistics.BadPieceRate := UDINT_TO_REAL(exLink.RejectCounter)/UDINT_TO_REAL(ShiftStatistics.TotalPieces);
//	END_IF
//
//	// -------------------------------------------------------------------------------------------
//	// Additional times and rates
//	NominalProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(ShiftStatistics.TotalPieces)*(3600/Parameter.NominalProductionRate));
//	ShiftStatistics.NominalProductionTime.Hours := NominalProductionTime/3600;
//	ShiftStatistics.NominalProductionTime.Minutes := UDINT_TO_USINT((NominalProductionTime - ShiftStatistics.NominalProductionTime.Hours*3600)/60);
//	ShiftStatistics.NominalProductionTime.Seconds := UDINT_TO_USINT(NominalProductionTime - ShiftStatistics.NominalProductionTime.Hours*3600 - ShiftStatistics.NominalProductionTime.Minutes*60);
//	
//	GoodProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(ShiftStatistics.GoodPieces)*(3600/Parameter.NominalProductionRate));
//	ShiftStatistics.GoodProductionTime.Hours := GoodProductionTime/3600;
//	ShiftStatistics.GoodProductionTime.Minutes := UDINT_TO_USINT((GoodProductionTime - ShiftStatistics.GoodProductionTime.Hours*3600)/60);
//	ShiftStatistics.GoodProductionTime.Seconds := UDINT_TO_USINT(GoodProductionTime - ShiftStatistics.GoodProductionTime.Hours*3600 - ShiftStatistics.GoodProductionTime.Minutes*60);
//	
//	IF DowntimeScheduled > 0 THEN
//		ShiftStatistics.ScheduledDowntimeRate := UDINT_TO_REAL(DowntimeScheduled)/UDINT_TO_REAL(TotalTime);
//	END_IF
//	IF DowntimeUnscheduled > 0 THEN
//		ShiftStatistics.UnscheduledDowntimeRate := UDINT_TO_REAL(DowntimeUnscheduled)/UDINT_TO_REAL(TotalTime);
//	END_IF
//	IF Uptime > 0 THEN
//		ShiftStatistics.NominalProductionTimeRate := UDINT_TO_REAL(NominalProductionTime)/UDINT_TO_REAL(Uptime);
//	END_IF
//	IF TotalTime > 0 THEN
//		ShiftStatistics.CurrentProductionRate := UDINT_TO_REAL(ShiftStatistics.TotalPieces)/UDINT_TO_REAL(TotalTime);
//	END_IF
//	
//	CalcStatsJob := TRUE;
END_FUNCTION