
PROGRAM _CYCLIC
	exAssetIntCore_0.exLink := ADR(exBuffer);
	exAssetIntCore_0.Enable := 1;
	exAssetIntCore_0.Parameters := ADR(exAssetIntPar);
	exAssetIntCore_0.DeviceName := ADR('ARsim');
	exAssetIntCore_0();
	 
END_PROGRAM
