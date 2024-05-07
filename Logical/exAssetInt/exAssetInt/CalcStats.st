// -------------------------------------------------------------------------------------------
// Calculate current job statistics
FUNCTION CalcStatsJob
	// -------------------------------------------------------------------------------------------
	// Calculate total time, remember total time in milliseconds for accuaracy but convert to seconds for local calculations
	exLink.JobTotalTime := exLink.JobTotalTime + DiffLastCall;
	JobTotalTime := LREAL_TO_UDINT(exLink.JobTotalTime/1000);

	JobStatistics.TotalTime.Hours := JobTotalTime/3600;
	JobStatistics.TotalTime.Minutes := UDINT_TO_USINT((JobTotalTime - JobStatistics.TotalTime.Hours*3600)/60);
	JobStatistics.TotalTime.Seconds := UDINT_TO_USINT(JobTotalTime - JobStatistics.TotalTime.Hours*3600 - JobStatistics.TotalTime.Minutes*60);
	
	// Calculate scheduled downtime
	IF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
		exLink.JobDowntimeScheduled := exLink.JobDowntimeScheduled + DiffLastCall;
		JobStatistics.ScheduledDowntime.Hours := exLink.JobDowntimeScheduled/3600000;
		JobStatistics.ScheduledDowntime.Minutes := UDINT_TO_USINT((exLink.JobDowntimeScheduled - JobStatistics.ScheduledDowntime.Hours*3600000)/60000);
		JobStatistics.ScheduledDowntime.Seconds := UDINT_TO_USINT(exLink.JobDowntimeScheduled - JobStatistics.ScheduledDowntime.Hours*3600000 - JobStatistics.TotalTime.Minutes*60000);
	END_IF

	// Calculate scheduled downtime
	IF Downtime = exASSETINT_UNSCHEDULED_DOWNTIME THEN
		exLink.JobDowntimeUnscheduled := exLink.JobDowntimeUnscheduled + DiffLastCall;
		JobStatistics.UnscheduledDowntime.Hours := exLink.JobDowntimeUnscheduled/3600000;
		JobStatistics.UnscheduledDowntime.Minutes := UDINT_TO_USINT((exLink.JobDowntimeUnscheduled - JobStatistics.UnscheduledDowntime.Hours*3600000)/60000);
		JobStatistics.UnscheduledDowntime.Seconds := UDINT_TO_USINT(exLink.JobDowntimeUnscheduled - JobStatistics.UnscheduledDowntime.Hours*3600000 - JobStatistics.TotalTime.Minutes*60000);
	END_IF
	
	// Calculate uptime
	IF Downtime = exASSETINT_NO_DOWNTIME THEN
		Uptime := JobTotalTime - exLink.JobDowntimeScheduled - exLink.JobDowntimeUnscheduled;
		JobStatistics.Uptime.Hours := Uptime/3600;
		JobStatistics.Uptime.Minutes := UDINT_TO_USINT((Uptime - JobStatistics.Uptime.Hours*3600)/60);
		JobStatistics.Uptime.Seconds := UDINT_TO_USINT(Uptime - JobStatistics.Uptime.Hours*3600 - JobStatistics.Uptime.Minutes*60);
	END_IF
	
	// -------------------------------------------------------------------------------------------
	// Calculate counters
	JobStatistics.TotalPieces := exLink.JobPieceCounter;
	JobStatistics.RejectPieces := exLink.JobRejectCounter;
	IF exLink.JobPieceCounter > exLink.JobRejectCounter THEN
		JobStatistics.GoodPieces := exLink.JobPieceCounter - exLink.JobRejectCounter;
	ELSE
		JobStatistics.GoodPieces := 0;
		JobStatistics.RejectPieces := exLink.JobPieceCounter;		
	END_IF	
	IF JobStatistics.TotalPieces > 0 THEN
		JobStatistics.BadPieceRate := UDINT_TO_REAL(exLink.JobRejectCounter)/UDINT_TO_REAL(JobStatistics.TotalPieces);
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
	
	IF exLink.JobDowntimeScheduled > 0 THEN
		JobStatistics.ScheduledDowntimeRate := UDINT_TO_REAL(exLink.JobDowntimeScheduled/JobTotalTime);
	END_IF
	IF exLink.JobDowntimeUnscheduled > 0 THEN
		JobStatistics.UnscheduledDowntimeRate := UDINT_TO_REAL(exLink.JobDowntimeUnscheduled/JobTotalTime);
	END_IF
	IF Uptime > 0 THEN
		JobStatistics.NominalProductionTimeRate := UDINT_TO_REAL(NominalProductionTime)/UDINT_TO_REAL(Uptime);
	END_IF
	IF JobTotalTime > 0 THEN
		JobStatistics.CurrentProductionRate := JobStatistics.TotalPieces/UDINT_TO_REAL(JobTotalTime)*3600;
	END_IF
	
	CalcStatsJob := TRUE;
END_FUNCTION

// -------------------------------------------------------------------------------------------
// Calculate current shift statistics
FUNCTION CalcStatsShift
	// -------------------------------------------------------------------------------------------
	// Calculate total time, remember total time in milliseconds for accuaracy but convert to seconds for local calculations
	exLink.ShiftTotalTime := exLink.ShiftTotalTime + DiffLastCall;
	ShiftTotalTime := LREAL_TO_UDINT(exLink.ShiftTotalTime/1000);
	
	ShiftStatistics.TotalTime.Hours := ShiftTotalTime/3600;
	ShiftStatistics.TotalTime.Minutes := UDINT_TO_USINT((ShiftTotalTime - ShiftStatistics.TotalTime.Hours*3600)/60);
	ShiftStatistics.TotalTime.Seconds := UDINT_TO_USINT(ShiftTotalTime - ShiftStatistics.TotalTime.Hours*3600 - ShiftStatistics.TotalTime.Minutes*60);

	// Calculate scheduled downtime
	IF Downtime = exASSETINT_SCHEDULED_DOWNTIME THEN
		exLink.ShiftDowntimeScheduled := exLink.ShiftDowntimeScheduled + DiffLastCall;
		ShiftStatistics.ScheduledDowntime.Hours := exLink.ShiftDowntimeScheduled/3600000;
		ShiftStatistics.ScheduledDowntime.Minutes := UDINT_TO_USINT((exLink.ShiftDowntimeScheduled - ShiftStatistics.ScheduledDowntime.Hours*3600000)/60000);
		ShiftStatistics.ScheduledDowntime.Seconds := UDINT_TO_USINT(exLink.ShiftDowntimeScheduled - ShiftStatistics.ScheduledDowntime.Hours*3600000 - ShiftStatistics.TotalTime.Minutes*60000);
	END_IF

	// Calculate scheduled downtime
	IF Downtime = exASSETINT_UNSCHEDULED_DOWNTIME THEN
		exLink.ShiftDowntimeUnscheduled := exLink.ShiftDowntimeUnscheduled + DiffLastCall;
		ShiftStatistics.UnscheduledDowntime.Hours := exLink.ShiftDowntimeUnscheduled/3600000;
		ShiftStatistics.UnscheduledDowntime.Minutes := UDINT_TO_USINT((exLink.ShiftDowntimeUnscheduled - ShiftStatistics.UnscheduledDowntime.Hours*3600000)/60000);
		ShiftStatistics.UnscheduledDowntime.Seconds := UDINT_TO_USINT(exLink.ShiftDowntimeUnscheduled - ShiftStatistics.UnscheduledDowntime.Hours*3600000 - ShiftStatistics.TotalTime.Minutes*60000);
	END_IF
	
	// Calculate uptime
	IF Downtime = exASSETINT_NO_DOWNTIME THEN
		Uptime := ShiftTotalTime - exLink.ShiftDowntimeScheduled - exLink.ShiftDowntimeUnscheduled;
		ShiftStatistics.Uptime.Hours := Uptime/3600;
		ShiftStatistics.Uptime.Minutes := UDINT_TO_USINT((Uptime - ShiftStatistics.Uptime.Hours*3600)/60);
		ShiftStatistics.Uptime.Seconds := UDINT_TO_USINT(Uptime - ShiftStatistics.Uptime.Hours*3600 - ShiftStatistics.Uptime.Minutes*60);
	END_IF
	
	// -------------------------------------------------------------------------------------------
	// Calculate counters
	ShiftStatistics.TotalPieces := exLink.ShiftPieceCounter;
	ShiftStatistics.TargetPieces := LREAL_TO_UDINT(ShiftTotalTime/3600*Parameter.NominalProductionRate);
	ShiftStatistics.RejectPieces := exLink.ShiftRejectCounter;
	IF exLink.ShiftPieceCounter > exLink.ShiftRejectCounter THEN
		ShiftStatistics.GoodPieces := exLink.ShiftPieceCounter - exLink.ShiftRejectCounter;
	ELSE
		ShiftStatistics.GoodPieces := 0;
		ShiftStatistics.RejectPieces := exLink.ShiftPieceCounter;		
	END_IF	
	IF ShiftStatistics.TotalPieces > 0 THEN
		ShiftStatistics.BadPieceRate := UDINT_TO_REAL(exLink.ShiftRejectCounter)/UDINT_TO_REAL(ShiftStatistics.TotalPieces);
	END_IF

	// -------------------------------------------------------------------------------------------
	// Additional times and rates
	NominalProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(ShiftStatistics.TotalPieces)*(3600/Parameter.NominalProductionRate));
	ShiftStatistics.NominalProductionTime.Hours := NominalProductionTime/3600;
	ShiftStatistics.NominalProductionTime.Minutes := UDINT_TO_USINT((NominalProductionTime - ShiftStatistics.NominalProductionTime.Hours*3600)/60);
	ShiftStatistics.NominalProductionTime.Seconds := UDINT_TO_USINT(NominalProductionTime - ShiftStatistics.NominalProductionTime.Hours*3600 - ShiftStatistics.NominalProductionTime.Minutes*60);
	
	GoodProductionTime := REAL_TO_UDINT(UDINT_TO_REAL(ShiftStatistics.GoodPieces)*(3600/Parameter.NominalProductionRate));
	ShiftStatistics.GoodProductionTime.Hours := GoodProductionTime/3600;
	ShiftStatistics.GoodProductionTime.Minutes := UDINT_TO_USINT((GoodProductionTime - ShiftStatistics.GoodProductionTime.Hours*3600)/60);
	ShiftStatistics.GoodProductionTime.Seconds := UDINT_TO_USINT(GoodProductionTime - ShiftStatistics.GoodProductionTime.Hours*3600 - ShiftStatistics.GoodProductionTime.Minutes*60);
	
	IF exLink.ShiftDowntimeScheduled > 0 THEN
		ShiftStatistics.ScheduledDowntimeRate := UDINT_TO_REAL(exLink.ShiftDowntimeScheduled/ShiftTotalTime);
	END_IF
	IF exLink.ShiftDowntimeUnscheduled > 0 THEN
		ShiftStatistics.UnscheduledDowntimeRate := UDINT_TO_REAL(exLink.ShiftDowntimeUnscheduled/ShiftTotalTime);
	END_IF
	IF Uptime > 0 THEN
		ShiftStatistics.NominalProductionTimeRate := UDINT_TO_REAL(NominalProductionTime)/UDINT_TO_REAL(Uptime);
	END_IF
	IF ShiftTotalTime > 0 THEN
		ShiftStatistics.CurrentProductionRate := UDINT_TO_REAL(ShiftStatistics.TotalPieces)/UDINT_TO_REAL(ShiftTotalTime)*3600;
	END_IF
	
	CalcStatsShift := TRUE;
END_FUNCTION