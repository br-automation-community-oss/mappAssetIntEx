PROGRAM _INIT
	gShift[0].Start.Hour := 6;
	gShift[0].Start.Minutes := 0;
	gShift[0].End.Hour := 14;
	gShift[0].End.Minutes := 0;
	gShift[1].Start.Hour := 14;
	gShift[1].Start.Minutes := 0;
	gShift[1].End.Hour := 22;
	gShift[1].End.Minutes := 0;
	gShift[2].Start.Hour := 22;
	gShift[2].Start.Minutes := 0;
	gShift[2].End.Hour := 6;
	gShift[2].End.Minutes := 0;

	MpAssetIntCoreConfig_0.Save := TRUE;	 
END_PROGRAM