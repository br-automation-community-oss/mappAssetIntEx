
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------------
	// Asset configuration
	exAssetIntConfig.Shifts[0].Name := gShift[0].Name; 
	exAssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[0].TotalTime.End := UDINT_TO_TOD((gShift[0].End.Hour * 3600000) + (gShift[0].End.Minutes * 60000));
	exAssetIntConfig.Shifts[1].Name := gShift[1].Name; 
	exAssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[1].TotalTime.End := UDINT_TO_TOD((gShift[1].End.Hour * 3600000) + (gShift[1].End.Minutes * 60000));
	exAssetIntConfig.Shifts[2].Name := gShift[2].Name; 
	exAssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[2].TotalTime.End := UDINT_TO_TOD((gShift[2].End.Hour * 3600000) + (gShift[2].End.Minutes * 60000));
   
	IF (exAssetIntConfig.Shifts[1].TotalTime.Start = exAssetIntConfig.Shifts[0].TotalTime.End) AND (exAssetIntConfig.Shifts[1].TotalTime.End <> exAssetIntConfig.Shifts[1].TotalTime.Start) THEN
		exAssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (exAssetIntConfig.Shifts[2].TotalTime.Start = exAssetIntConfig.Shifts[1].TotalTime.End) AND (exAssetIntConfig.Shifts[2].TotalTime.End <> exAssetIntConfig.Shifts[2].TotalTime.Start)  THEN
		exAssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (exAssetIntConfig.Shifts[0].TotalTime.Start = exAssetIntConfig.Shifts[2].TotalTime.End) THEN
		exAssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 1);
	END_IF
	
	exAssetIntConfig_0.Enable := exAssetIntCore_0.Active;
	exAssetIntConfig_0.exLink := ADR(exAssetIntLink);
	exAssetIntConfig_0.DeviceName := ADR('USER_HD');
	exAssetIntConfig_0.Configuration := ADR(exAssetIntConfig);
	exAssetIntConfig_0.Logger := ADR(LoggerConfig);
	exAssetIntConfig_0();
	
	// --------------------------------------------------------------------------------------------------------------------------
	// Transfer global parameters
	exAssetIntPar.NominalProductionRate := gNominalProductionRate;
	exAssetIntPar.AdditionalData := gAdditionalData;
	exAssetIntPar.CurrentUser := gCurrentUser;
	exAssetIntPar.Job := gJobName;

	exAssetIntCore_0.Enable := TRUE;
	exAssetIntCore_0.exLink := ADR(exAssetIntLink);
	exAssetIntCore_0.Parameters := ADR(exAssetIntPar);
	exAssetIntCore_0.Configuration := ADR(exAssetIntConfig);
	exAssetIntCore_0.DeviceName := ADR('USER_HD');
	exAssetIntCore_0.DowntimeReason := ADR(gDowntimeReason);
	exAssetIntCore_0.Downtime := gDowntime;
	exAssetIntCore_0.PieceCounter := gPieceCounter;
	exAssetIntCore_0.RejectCounter := gRejectCounter;
	exAssetIntCore_0.Logger := ADR(LoggerCore);
	exAssetIntCore_0.Update := gCommandUpdate;
	exAssetIntCore_0.Reset := gCommandReset;
	exAssetIntCore_0();
	
	IF EDGEPOS(exAssetIntCore_0.UpdateDone) THEN
		gCommandUpdate := FALSE;
	END_IF
	
	// --------------------------------------------------------------------------------------------------------------------------
	// UI function blocks
	exAssetIntJobListUI_0.Enable := exAssetIntCore_0.Active;
	exAssetIntJobListUI_0.exLink := ADR(exAssetIntLink);
	exAssetIntJobListUI_0.UIConnect := ADR(JobListUIConnect);
	exAssetIntJobListUI_0();
	 
END_PROGRAM
