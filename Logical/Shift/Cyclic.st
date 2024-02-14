(*********************************************************************************
 * Copyright: Bernecker + Rainer
 * Author:    heinesm
 * Created:   11. August 2017/14:16 
 *********************************************************************************)
PROGRAM _CYCLIC
    AssetIntPar.NominalProductionRate := 3600;
    TmpAdditionalData := AssetIntPar.AdditionalData;	 
    
    IF (MpAssetIntCore_0.Info.ShiftStatistics.ShiftName <> ActShiftName) THEN
      ActShiftName := MpAssetIntCore_0.Info.ShiftStatistics.ShiftName;
      ShiftCount := ShiftCount + 1;
    END_IF
    IF (ShiftCount = 0) OR (ShiftCount > 5) THEN
      ShiftCount := 1;
    END_IF	 
    
    TmpCount := TmpCount + 1;
    IF (TmpCount > (100 * ShiftCount)) AND (MpAssetIntCore_0.Active = TRUE) THEN
        MpAssetIntCore_0.PieceCounter := MpAssetIntCore_0.PieceCounter + 1;
        IF ((MpAssetIntCore_0.PieceCounter MOD (10 + ShiftCount)) = 1) THEN
            MpAssetIntCore_0.RejectCounter :=  MpAssetIntCore_0.RejectCounter + 1;
        END_IF
        TmpCount := 0;
    END_IF    

    MpAssetIntCore_0.MpLink := ADR(gAssetIntCore);
    MpAssetIntCore_0.Enable := 1;
    MpAssetIntCore_0.Parameters := ADR(AssetIntPar);
    MpAssetIntCore_0.DeviceName := ADR('ARsim');
    MpAssetIntCore_0();
    
    ShiftStatistics := MpAssetIntCore_0.Info.ShiftStatistics;
    SizeShift := SIZEOF(ShiftStatistics);  
    
    AssetIntConfig.Export.DecimalMark := ',';
    AssetIntConfig.Export.ColumnSeparator := ';';
    brsstrcpy(ADR(AssetIntConfig.Export.JobStatisticsFileNamePattern), ADR('1234JobStatistics_%Y_%m_%d_%H_%M.csv'));
    brsstrcpy(ADR(AssetIntConfig.Export.ShiftStatisticsFileNamePattern), ADR('1234ShiftStatistics_%Y_%m_%d_%H_%M.csv'));
    brsstrcpy(ADR(AssetIntConfig.Export.TimelineFileNamePattern), ADR('1234Timeline_%Y_%m_%d_%H_%M.csv'));
    
    AssetIntConfig.Shifts[0].Name := 'Shift0'; 
    AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((Shift[0].Start.Hour * 3600000) + (Shift[0].Start.Minutes * 60000));
    AssetIntConfig.Shifts[0].TotalTime.End := UDINT_TO_TOD((Shift[0].End.Hour * 3600000) + (Shift[0].End.Minutes * 60000));
    AssetIntConfig.Shifts[1].Name := 'Shift1'; 
    AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((Shift[1].Start.Hour * 3600000) + (Shift[1].Start.Minutes * 60000));
    AssetIntConfig.Shifts[1].TotalTime.End := UDINT_TO_TOD((Shift[1].End.Hour * 3600000) + (Shift[1].End.Minutes * 60000));
    AssetIntConfig.Shifts[2].Name := 'Shift2'; 
    AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((Shift[2].Start.Hour * 3600000) + (Shift[2].Start.Minutes * 60000));
    AssetIntConfig.Shifts[2].TotalTime.End := UDINT_TO_TOD((Shift[2].End.Hour * 3600000) + (Shift[2].End.Minutes * 60000));
   
    IF (AssetIntConfig.Shifts[1].TotalTime.Start = AssetIntConfig.Shifts[0].TotalTime.End) AND (AssetIntConfig.Shifts[1].TotalTime.End <> AssetIntConfig.Shifts[1].TotalTime.Start) THEN
        AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((Shift[1].Start.Hour * 3600000) + (Shift[1].Start.Minutes * 60000) + 1);
    END_IF
    
    IF (AssetIntConfig.Shifts[2].TotalTime.Start = AssetIntConfig.Shifts[1].TotalTime.End) AND (AssetIntConfig.Shifts[2].TotalTime.End <> AssetIntConfig.Shifts[2].TotalTime.Start)  THEN
        AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((Shift[2].Start.Hour * 3600000) + (Shift[2].Start.Minutes * 60000) + 1);
    END_IF
    
    IF (AssetIntConfig.Shifts[0].TotalTime.Start = AssetIntConfig.Shifts[2].TotalTime.End) THEN
        AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((Shift[0].Start.Hour * 3600000) + (Shift[0].Start.Minutes * 60000) + 1);
    END_IF

    
    IF (MpAssetIntCoreConfig_0.Save = 1) AND (MpAssetIntCoreConfig_0.CommandDone = 1) AND (MpAssetIntCoreConfig_0.CommandBusy = 0) THEN
        MpAssetIntCoreConfig_0.Save := 0;
    END_IF
    
    MpAssetIntCoreConfig_0.MpLink :=  ADR(gAssetIntCore);
    MpAssetIntCoreConfig_0.Enable := MpAssetIntCore_0.Active;
    MpAssetIntCoreConfig_0.Configuration := ADR(AssetIntConfig);
    MpAssetIntCoreConfig_0();
    
    MpAssetIntShiftListUI_0.MpLink :=  ADR(gAssetIntCore);
    MpAssetIntShiftListUI_0.Enable := MpAssetIntCore_0.Active;
    MpAssetIntShiftListUI_0.UIConnect := ADR(ShiftListUIConnect);
    MpAssetIntShiftListUI_0();
    
    MpAssetIntJobListUI_0.MpLink :=  ADR(gAssetIntCore);
    MpAssetIntJobListUI_0.Enable := MpAssetIntCore_0.Active;
    MpAssetIntJobListUI_0.UIConnect := ADR(JobListUIConnect);
    MpAssetIntJobListUI_0();
     
END_PROGRAM
