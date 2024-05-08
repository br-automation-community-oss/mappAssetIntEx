
PROGRAM _INIT
	PV_xgetadr(ADR('Sample:exAssetIntCore_0'), ADR(exAssetIntCoreAdr), ADR(exAssetIntCoreLen));
	exAssetIntCore_0 ACCESS exAssetIntCoreAdr;
	 
END_PROGRAM

PROGRAM _CYCLIC
	// Get current date and time
	IF GetDateTime THEN
		RTC_gettime(ADR(RTCtime_struct));
		GetDateTime := FALSE;
	END_IF

	// Set current date and time
	IF SetDateTime THEN
		RTC_settime(ADR(RTCtime_struct));
		SetDateTime := FALSE;
	END_IF

	// Auto count pieces
	IF AutoCount THEN
		AutoCountTime.IN := TRUE;
		AutoCountTime.PT := AutoCountCycle / 10;
		AutoCountTime();
		
		IF AutoCountTime.Q THEN
			AutoCountTime.IN := FALSE;
			AutoCountTime();
			
			gPieceCounter := gPieceCounter + 1;
			
			// Generate reject parts
			IF gPieceCounter MOD gRejectCounterRatio = 0 THEN
				gRejectCounter := gRejectCounter + 1;
			END_IF
		END_IF
	END_IF
	
	// Create new jobs
	IF AutoCreateJobs THEN
		AutoCount := TRUE;
		
		IF gPieceCounter > AutoCreatePieceCnt + AutoCreateJobsNum THEN
			AutoCreatePieceCnt := gPieceCounter;
			AutoCreateJobsCnt := AutoCreateJobsCnt + 1;
			
			// Create new job name
			TmpStr1 := 'Job';
			brsitoa(AutoCreateJobsCnt, ADR(TmpStr2));
			brsstrcat(ADR(TmpStr1), ADR(TmpStr2));
			gJobName := TmpStr1;
			gCommandUpdate := TRUE;
			
		END_IF
	
	END_IF
	
	// Copy internal memory buffer to structure for debugging
//	IF exAssetIntLink.Memory <> 0 THEN
//		brsmemcpy(ADR(Memory), exAssetIntLink.Memory, SIZEOF(Memory));
//	ELSE
//		brsmemset(ADR(Memory), 0, SIZEOF(Memory));		
//	END_IF

	
	TestCase1;
	TestCase2;
END_PROGRAM

