

PROGRAM _INIT
    MpDataRecorder_0.DeviceName := ADR('CFCard');
    MpDataRecorder_0.RecordMode := mpDATA_RECORD_MODE_TRIGGER;//mpDATA_RECORD_MODE_TIME;// mpDATA_RECORD_MODE_TRIGGER;
    MpDataRecorder_0.SamplingTime := T#2s; //T#60s;
	 
END_PROGRAM