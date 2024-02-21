// -------------------------------------------------------------------------------------------
// Calculate current job statistics
FUNCTION CalcStatsJob
	JobStatistics.JobName := Parameter.Job;
	JobStatistics.CurrentUser := Parameter.CurrentUser;
	JobStatistics.AdditionalData := Parameter.AdditionalData;
	
//	JobStatistics.TotalTime := 0;
//	JobStatistics.ScheduledDowntime := 0;
//	JobStatistics.UnscheduledDowntime := 0;
//	JobStatistics.Uptime := 0;
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