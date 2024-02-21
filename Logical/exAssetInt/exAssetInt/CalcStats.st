// -------------------------------------------------------------------------------------------
// Calculate current job statistics
FUNCTION CalcStatsJob
	DTGetTime_0(enable := TRUE);
	// Transfer parameter data
	JobStatistics.JobName := Parameter.Job;
	JobStatistics.CurrentUser := Parameter.CurrentUser;
	JobStatistics.AdditionalData := Parameter.AdditionalData;
	// Calculate total time
	JobStatistics.TotalTime.Hours := DiffDT(DTGetTime_0.DT1, exLink.JobStart)/3600;
	JobStatistics.TotalTime.Minutes := UDINT_TO_USINT((DiffDT(DTGetTime_0.DT1, exLink.JobStart) - JobStatistics.TotalTime.Hours*3600)/60);
	JobStatistics.TotalTime.Seconds := UDINT_TO_USINT(DiffDT(DTGetTime_0.DT1, exLink.JobStart) - JobStatistics.TotalTime.Hours*3600 - JobStatistics.TotalTime.Minutes*60);
	// Calculate scheduled downtime
	IF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
		JobStatistics.ScheduledDowntime.Hours := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart)/3600;
		JobStatistics.ScheduledDowntime.Minutes := UDINT_TO_USINT((DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart) - JobStatistics.TotalTime.Hours*3600)/60);
		JobStatistics.ScheduledDowntime.Seconds := UDINT_TO_USINT(DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart) - JobStatistics.TotalTime.Hours*3600 - JobStatistics.TotalTime.Minutes*60);
	END_IF
	// Calculate undscheduled downtime
	IF Downtime = exASSETINT_ALM_UNSCH_DOWNTIME THEN
		JobStatistics.UnscheduledDowntime.Hours := DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart)/3600;
		JobStatistics.UnscheduledDowntime.Minutes := UDINT_TO_USINT((DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart) - JobStatistics.TotalTime.Hours*3600)/60);
		JobStatistics.UnscheduledDowntime.Seconds := UDINT_TO_USINT(DiffDT(DTGetTime_0.DT1, exLink.DowntimeStart) - JobStatistics.TotalTime.Hours*3600 - JobStatistics.TotalTime.Minutes*60);
	END_IF
	// Calculate uptime
	JobStatistics.Uptime.Hours := 0;
	//	JobStatistics.NominalProductionTime := 0;
//	JobStatistics.GoodProductionTime := 0;
//	JobStatistics.ScheduledDowntimeRate := 0;
//	JobStatistics.UnscheduledDowntimeRate := 0;
//	JobStatistics.NominalProductionTimeRate := 0;
	
	JobStatistics.TotalPieces := exLink.PieceCounter;
	JobStatistics.RejectPieces := exLink.RejectCounter;
	IF exLink.PieceCounter > exLink.RejectCounter THEN
		JobStatistics.GoodPieces := exLink.PieceCounter - exLink.RejectCounter;
	ELSE
		JobStatistics.GoodPieces := 0;
		JobStatistics.RejectPieces := exLink.PieceCounter;		
	END_IF	
	IF JobStatistics.TotalPieces > 0 THEN
		JobStatistics.BadPieceRate := 1.0*exLink.RejectCounter/JobStatistics.TotalPieces;
	END_IF
	JobStatistics.CurrentProductionRate := 0;
END_FUNCTION