
PROGRAM _CYCLIC
    MpDataRecorder_0.MpLink := ADR(gDataRecorder);
    MpDataRecorder_0.Enable := TRUE;
    MpDataRecorder_0.Trigger := CmdRecord;
    MpDataRecorder_0.Record := MpDataRegPar_0.Active;
    MpDataRecorder_0();
    
    MpDataRegPar_0.MpLink := ADR(gDataRecorder);
    MpDataRegPar_0.Enable := MpDataRecorder_0.Active;
    MpDataRegPar_0.PVName := ADR('ShiftStatistics');
    MpDataRegPar_0.Description := ADR('xxx');
    MpDataRegPar_0.Unit := ADR('[°C]');
    MpDataRegPar_0();
    
//    MpDataTableUI_0.MpLink := ADR(gDataRecorder);
//    MpDataTableUI_0.Enable := MpDataRegPar_0.Active;
//    MpDataTableUI_0.UIConnect := ADR(gMpDataTableUIConnect);
//    MpDataTableUI_0();	 
    
END_PROGRAM
