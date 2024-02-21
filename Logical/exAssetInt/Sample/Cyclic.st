
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------------
	// Asset configuration
	exAssetIntConfig_0.exLink := ADR(exAssetIntLink);
	exAssetIntConfig_0.Enable := TRUE;
	exAssetIntConfig_0.DeviceName := ADR('ARsim');
	exAssetIntConfig_0.Configuration := ADR(AssetIntConfig);
	exAssetIntConfig_0();
	
	// --------------------------------------------------------------------------------------------------------------------------
	// Transfer global parameters
	exAssetIntPar.NominalProductionRate := gNominalProductionRate;
	exAssetIntPar.AdditionalData := gAdditionalData;
	exAssetIntPar.CurrentUser := gCurrentUser;
	exAssetIntPar.Job := gJobName;

	exAssetIntCore_0.exLink := ADR(exAssetIntLink);
	exAssetIntCore_0.Enable := TRUE;
	exAssetIntCore_0.Parameters := ADR(exAssetIntPar);
	exAssetIntCore_0.Configuration := ADR(AssetIntConfig);
	exAssetIntCore_0.DeviceName := ADR('ARsim');
	exAssetIntCore_0.PieceCounter := gPieceCounter;
	exAssetIntCore_0.RejectCounter := gRejectCounter;
	exAssetIntCore_0();
	 
END_PROGRAM
