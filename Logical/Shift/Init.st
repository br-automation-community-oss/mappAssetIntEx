

PROGRAM _INIT
Shift[0].Start.Hour := 6;
Shift[0].Start.Minutes := 0;
Shift[0].End.Hour := 14;
Shift[0].End.Minutes := 0;
Shift[1].Start.Hour := 14;
Shift[1].Start.Minutes := 0;
Shift[1].End.Hour := 22;
Shift[1].End.Minutes := 0;
Shift[2].Start.Hour := 22;
Shift[2].Start.Minutes := 0;
Shift[2].End.Hour := 6;
Shift[2].End.Minutes := 0;

AssetIntPar.AdditionalData := TmpAdditionalData;
MpAssetIntCoreConfig_0.Save := TRUE;	 
END_PROGRAM