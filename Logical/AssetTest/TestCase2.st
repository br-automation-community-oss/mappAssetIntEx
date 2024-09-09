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
				gShift[0].ScheduledDowntime[0].Start.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[0].Start.Minutes := gShift[0].Start.Minutes + 3;
				gShift[0].ScheduledDowntime[0].End.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[0].End.Minutes := gShift[0].Start.Minutes + 5;
				gShift[0].ScheduledDowntime[0].Reason := 'Test Reason 1';

				gShift[0].ScheduledDowntime[1].Start.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[1].Start.Minutes := gShift[0].Start.Minutes + 3;
				gShift[0].ScheduledDowntime[1].End.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[1].End.Minutes := gShift[0].Start.Minutes + 5;
				gShift[0].ScheduledDowntime[1].Reason := 'Test Reason 2';

				gShift[0].ScheduledDowntime[2].Start.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[2].Start.Minutes := gShift[0].Start.Minutes + 3;
				gShift[0].ScheduledDowntime[2].End.Hour := gShift[0].Start.Hour;
				gShift[0].ScheduledDowntime[2].End.Minutes := gShift[0].Start.Minutes + 5;
				gShift[0].ScheduledDowntime[2].Reason := 'Test Reason 3';

				RTCtime_struct.hour := UDINT_TO_USINT(gShift[0].Start.Hour);
				RTCtime_struct.minute := UDINT_TO_USINT(gShift[0].Start.Minutes);
				RTC_settime(ADR(RTCtime_struct));

				TestState[TesMyId] := TestState[TesMyId] + 1;
			2:
				TestIdle[TesMyId] := TestIdle[TesMyId] + 1;
				IF TestIdle[TesMyId] > 100*60*17 THEN
					TestIdle[TesMyId] := 0;
					TestState[TesMyId] := TestState[TesMyId] + 1;
				END_IF					
			3:
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
