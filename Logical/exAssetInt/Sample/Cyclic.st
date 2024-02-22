
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------------
	// Asset configuration
	AssetIntConfig.Shifts[0].Name := gShift[0].Name; 
	AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000));
	AssetIntConfig.Shifts[0].TotalTime.End := UDINT_TO_TOD((gShift[0].End.Hour * 3600000) + (gShift[0].End.Minutes * 60000));
	AssetIntConfig.Shifts[1].Name := gShift[1].Name; 
	AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000));
	AssetIntConfig.Shifts[1].TotalTime.End := UDINT_TO_TOD((gShift[1].End.Hour * 3600000) + (gShift[1].End.Minutes * 60000));
	AssetIntConfig.Shifts[2].Name := gShift[2].Name; 
	AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000));
	AssetIntConfig.Shifts[2].TotalTime.End := UDINT_TO_TOD((gShift[2].End.Hour * 3600000) + (gShift[2].End.Minutes * 60000));
   
	IF (AssetIntConfig.Shifts[1].TotalTime.Start = AssetIntConfig.Shifts[0].TotalTime.End) AND (AssetIntConfig.Shifts[1].TotalTime.End <> AssetIntConfig.Shifts[1].TotalTime.Start) THEN
		AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (AssetIntConfig.Shifts[2].TotalTime.Start = AssetIntConfig.Shifts[1].TotalTime.End) AND (AssetIntConfig.Shifts[2].TotalTime.End <> AssetIntConfig.Shifts[2].TotalTime.Start)  THEN
		AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (AssetIntConfig.Shifts[0].TotalTime.Start = AssetIntConfig.Shifts[2].TotalTime.End) THEN
		AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 1);
	END_IF
	
	exAssetIntConfig_0.Enable := TRUE;
	exAssetIntConfig_0.exLink := ADR(exAssetIntLink);
	exAssetIntConfig_0.DeviceName := ADR('ARsim');
	exAssetIntConfig_0.Configuration := ADR(AssetIntConfig);
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
	exAssetIntCore_0.Configuration := ADR(AssetIntConfig);
	exAssetIntCore_0.DeviceName := ADR('ARsim');
	exAssetIntCore_0.DowntimeReason := ADR(gDowntimeReason);
	exAssetIntCore_0.Downtime := gDowntime;
	exAssetIntCore_0.PieceCounter := gPieceCounter;
	exAssetIntCore_0.RejectCounter := gRejectCounter;
	exAssetIntCore_0.Update := gCommandUpdate;
	exAssetIntCore_0();
	
	IF EDGEPOS(exAssetIntCore_0.UpdateDone) THEN
		gCommandUpdate := FALSE;
	END_IF
	
	// --------------------------------------------------------------------------------------------------------------------------
	// UI function blocks
	exAssetIntJobListUI_0.Enable := TRUE;
	exAssetIntJobListUI_0.exLink := ADR(exAssetIntLink);
	exAssetIntJobListUI_0.UIConnect := ADR(JobListUIConnect);
	exAssetIntJobListUI_0();
	 
END_PROGRAM
