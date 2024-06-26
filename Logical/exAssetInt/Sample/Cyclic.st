
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------------
	// Asset configuration
	exAssetIntConfig.Shifts[0].Name := 'Morning';
	exAssetIntConfig.Shifts[0].TotalTime.Start := TOD#08:00:00;
	exAssetIntConfig.Shifts[0].TotalTime.End := TOD#14:00:00;
	exAssetIntConfig.Shifts[0].ScheduledDowntime[0].Start := TOD#09:00:00;
	exAssetIntConfig.Shifts[0].ScheduledDowntime[0].End := TOD#10:00:00;
	exAssetIntConfig.Shifts[0].ScheduledDowntime[0].Reason := 'Breakfast';

	exAssetIntConfig.Shifts[1].Name := 'Afternoon'; 
	exAssetIntConfig.Shifts[1].TotalTime.Start := TOD#14:00:00;
	exAssetIntConfig.Shifts[1].TotalTime.End := TOD#22:00:00;

	exAssetIntConfig.Shifts[2].Name := 'Night'; 
	exAssetIntConfig.Shifts[2].TotalTime.Start := TOD#22:00:00;
	exAssetIntConfig.Shifts[2].TotalTime.End := TOD#08:00:00;
	
	exAssetIntConfig.Export.ShiftStatistics := TRUE;
	exAssetIntConfig.Export.ShiftStatisticsFileNamePattern := 'ShiftStatistics_%Y_%m_%d_%H_%M.csv';
   
	exAssetIntConfig_0.Enable := exAssetIntCore_0.Active;
	exAssetIntConfig_0.exLink := ADR(exAssetIntLink);
	exAssetIntConfig_0.DeviceName := gDeviceName;
	exAssetIntConfig_0.Configuration := ADR(exAssetIntConfig);
	exAssetIntConfig_0.Logger := ADR(LoggerConfig);
	exAssetIntConfig_0();
	
	// --------------------------------------------------------------------------------------------------------------------------
	// Transfer global parameters
	exAssetIntPar.NominalProductionRate := gNominalProductionRate;
	exAssetIntPar.AdditionalData := gAdditionalData;
	exAssetIntPar.CurrentUser := gCurrentUser;
	exAssetIntPar.Job := gJobName;

	exAssetIntCore_0.Enable := gEnable;
	exAssetIntCore_0.exLink := ADR(exAssetIntLink);
	exAssetIntCore_0.Parameters := ADR(exAssetIntPar);
	exAssetIntCore_0.Configuration := ADR(exAssetIntConfig);
	exAssetIntCore_0.DeviceName := ADR(gDeviceName);
	exAssetIntCore_0.DowntimeReason := ADR(gDowntimeReason);
	exAssetIntCore_0.Downtime := gDowntime;
	exAssetIntCore_0.PieceCounter := gPieceCounter;
	exAssetIntCore_0.RejectCounter := gRejectCounter;
	exAssetIntCore_0.Logger := ADR(LoggerCore);
	exAssetIntCore_0.Update := gCommandUpdate;
	exAssetIntCore_0.Reset := gCommandReset;
	exAssetIntCore_0.Export := gCommandExport;
	exAssetIntCore_0.ErrorReset := gCommandResetError;
	exAssetIntCore_0();
	
	IF EDGEPOS(exAssetIntCore_0.UpdateDone) THEN
		gCommandUpdate := FALSE;
	END_IF
	
	// --------------------------------------------------------------------------------------------------------------------------
	// UI function blocks
	exAssetIntJobListUI_0.Enable := exAssetIntCore_0.Active;
	exAssetIntJobListUI_0.exLink := ADR(exAssetIntLink);
	exAssetIntJobListUI_0.UIConnect := ADR(JobListUIConnect);
	exAssetIntJobListUI_0.Logger := ADR(LoggerUIJob);
	exAssetIntJobListUI_0();

	exAssetIntShiftListUI_0.Enable := exAssetIntCore_0.Active;
	exAssetIntShiftListUI_0.exLink := ADR(exAssetIntLink);
	exAssetIntShiftListUI_0.UIConnect := ADR(ShiftListUIConnect);
	exAssetIntShiftListUI_0.Logger := ADR(LoggerUIShift);
	exAssetIntShiftListUI_0();
	
	exAssetIntTimelineUI_0.Enable := exAssetIntCore_0.Active;
	exAssetIntTimelineUI_0.exLink :=  ADR(exAssetIntLink);
	exAssetIntTimelineUI_0.UIConnect := ADR(TimelineUIConnect);
	exAssetIntTimelineUI_0.Logger := ADR(LoggerUITimeline);
	exAssetIntTimelineUI_0();

END_PROGRAM
