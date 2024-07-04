
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------------
	// Asset configuration
	FOR x := 0 TO SIZEOF(exAssetIntConfig.Shifts)/SIZEOF(exAssetIntConfig.Shifts[0]) DO
		exAssetIntConfig.Shifts[x].Name := gShift[x].Name;
		FOR y := 0 TO SIZEOF(exAssetIntConfig.Shifts[x].ScheduledDowntime)/SIZEOF(exAssetIntConfig.Shifts[x].ScheduledDowntime[0]) DO
			exAssetIntConfig.Shifts[x].ScheduledDowntime[y].Reason := gShift[x].ScheduledDowntime[y].Reason;
			exAssetIntConfig.Shifts[x].ScheduledDowntime[y].Start := UDINT_TO_TOD((gShift[x].ScheduledDowntime[y].Start.Hour * 3600000) + (gShift[x].ScheduledDowntime[y].Start.Minutes * 60000));
			exAssetIntConfig.Shifts[x].ScheduledDowntime[y].End := UDINT_TO_TOD((gShift[x].ScheduledDowntime[y].End.Hour * 3600000) + (gShift[x].ScheduledDowntime[y].End.Minutes * 60000));
		END_FOR;
		exAssetIntConfig.Shifts[x].TotalTime.Start := UDINT_TO_TOD((gShift[x].Start.Hour * 3600000) + (gShift[x].Start.Minutes * 60000));
		exAssetIntConfig.Shifts[x].TotalTime.End := UDINT_TO_TOD((gShift[x].End.Hour * 3600000) + (gShift[x].End.Minutes * 60000));
	END_FOR;

	
	// --------------------------------------------------------------------------------------------------------------------------
	// Import or export configuration
	exAssetIntConfig_0.Enable := exAssetIntCore_0.Active;
	exAssetIntConfig_0.exLink := ADR(exAssetIntLink);
	exAssetIntConfig_0.DeviceName := DeviceName;
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
	exAssetIntCore_0.DeviceName := ADR(DeviceName);
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
	// UI function blocks for shift, job and timeline
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
