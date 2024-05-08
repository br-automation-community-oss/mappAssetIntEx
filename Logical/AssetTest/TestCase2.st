// What is this test case doing?
// 1. Set 3 scheduled downtimes for first shift
// 1. Set PLC time to first shift start
// 2. Wait 20 minutes for shift to change
// 
// What is this test case testing?
// Make sure preconfigured scheduled downtime is handled correct
//
// What should be the preset?
// At least 1 shift

ACTION TestCase2: 
	TesMyId := 2;
	IF TestCase[TesMyId] THEN
		CASE TestState[TesMyId] OF
			0:
				TestResult[TesMyId] := TestResultRunning;
				AutoCount := TRUE;
				RTC_gettime(ADR(RTCtime_struct));
				TestIdle[TesMyId] := 0;
				
				TestState[TesMyId] := TestState[TesMyId] + 1;
			1:
				gShift[0].ScheduledDowntime[0].Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*3);
				gShift[0].ScheduledDowntime[0].End := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*5);
				gShift[0].ScheduledDowntime[0].Reason := 'Test Reason 1';

				gShift[0].ScheduledDowntime[1].Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*8);
				gShift[0].ScheduledDowntime[1].End := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*10);
				gShift[0].ScheduledDowntime[1].Reason := 'Test Reason 2';

				gShift[0].ScheduledDowntime[2].Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*13);
				gShift[0].ScheduledDowntime[2].End := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*15);
				gShift[0].ScheduledDowntime[2].Reason := 'Test Reason 3';

				RTCtime_struct.hour := UDINT_TO_USINT(gShift[0].Start.Hour);
				RTCtime_struct.minute := UDINT_TO_USINT(gShift[0].Start.Minutes);
				RTC_settime(ADR(RTCtime_struct));

				TestState[TesMyId] := TestState[TesMyId] + 1;
			2:
				TestCase[TesMyId] := FALSE;
				TestState[TesMyId] := 0;
				IF exAssetIntCore_0.Info.ShiftStatistics.ScheduledDowntime.Minutes = 6 THEN
					TestResult[TesMyId] := TestResultPassed;
				ELSE
					TestResult[TesMyId] := TestResultFailed;
				END_IF
		END_CASE;
	END_IF
END_ACTION
