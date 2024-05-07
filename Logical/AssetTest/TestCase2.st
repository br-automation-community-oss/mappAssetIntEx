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
	IF TestCase[2] THEN
		CASE TestState[2] OF
			0:
				AutoCount := TRUE;
				RTC_gettime(ADR(RTCtime_struct));
				TestIdle[2] := 0;
				
				TestState[2] := TestState[2] + 1;
			1:
				gShift[0].ScheduledDowntime[0].Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 60000*2);
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

				TestState[2] := TestState[2] + 1;
			2:
				TestIdle[2] := TestIdle[2] + 1;
				IF TestIdle[2] > 100*60*20 THEN
					TestIdle[2] := 0;
					TestState[2] := TestState[2] + 1;
				END_IF					
			6:
				TestCase[2] := FALSE;
				TestState[2] := 0;
		END_CASE;
	END_IF
END_ACTION
