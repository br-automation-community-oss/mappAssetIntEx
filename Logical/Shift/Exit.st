(*********************************************************************************
 * Copyright: Bernecker + Rainer
 * Author:    heinesm
 * Created:   11. August 2017/14:15 
 *********************************************************************************) 
PROGRAM _EXIT
MpAssetIntCore_0.Enable := 0;
MpAssetIntCore_0();
MpAssetIntCoreConfig_0.Enable := 0;	 
MpAssetIntCoreConfig_0();
MpAssetIntShiftListUI_0.Enable := 0;	 
MpAssetIntShiftListUI_0();
MpAssetIntJobListUI_0.Enable := 0;
MpAssetIntJobListUI_0();	 
END_PROGRAM