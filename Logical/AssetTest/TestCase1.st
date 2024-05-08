// What is this test case doing?
// 1. Set PLC time to first shift end minus 2 minutes
// 2. Wait 5 minutes for shift to change
// 3. Set PLC time to second shift end minus 2 minutes
// 4. Wait 5 minutes for shift to change
// 5. Set PLC time to third shift end minus 2 minutes
// 6. Wait 5 minutes for shift to change
// 
// What is this test case testing?
// Make sure shift changeover is handled correct
// Make sure gaps in shifts are handled correct
//
// What should be the preset?
// At least 3 shifts, a gap between one shift end and the next shift start

ACTION TestCase1: 
	TesMyId := 1;
	IF TestCase[1] THEN
		CASE TestState[TesMyId] OF
			0:
				AutoCount := TRUE;
				RTC_gettime(ADR(RTCtime_struct));
				TestIdle[TesMyId] := 0;
				
				TestState[TesMyId] := TestState[TesMyId] + 1;
			1:
				IF gShift[0].End.Minutes > 5 THEN
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[0].End.Hour);
					RTCtime_struct.minute := UDINT_TO_USINT(gShift[0].End.Minutes)-2;
				ELSE
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[0].End.Hour)-1;
					RTCtime_struct.minute := 58;
				END_IF
				RTC_settime(ADR(RTCtime_struct));

				TestState[TesMyId] := TestState[TesMyId] + 1;
			2:
				TestIdle[TesMyId] := TestIdle[TesMyId] + 1;
				IF TestIdle[TesMyId] > 100*60*5 THEN
					TestIdle[TesMyId] := 0;
					TestState[TesMyId] := TestState[TesMyId] + 1;
				END_IF					
			3:
				IF gShift[1].End.Minutes > 5 THEN
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[1].End.Hour);
					RTCtime_struct.minute := UDINT_TO_USINT(gShift[1].End.Minutes)-2;
				ELSE
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[1].End.Hour)-1;
					RTCtime_struct.minute := 58;
				END_IF
				RTC_settime(ADR(RTCtime_struct));

				TestState[TesMyId] := TestState[TesMyId] + 1;
			4:
				TestIdle[TesMyId] := TestIdle[TesMyId] + 1;
				IF TestIdle[TesMyId] > 100*60*5 THEN
					TestIdle[TesMyId] := 0;
					TestState[TesMyId] := TestState[TesMyId] + 1;
				END_IF					
			5:
				IF gShift[2].End.Minutes > 5 THEN
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[2].End.Hour);
					RTCtime_struct.minute := UDINT_TO_USINT(gShift[2].End.Minutes)-2;
				ELSE
					RTCtime_struct.hour := UDINT_TO_USINT(gShift[2].End.Hour)-1;
					RTCtime_struct.minute := 58;
				END_IF
				RTC_settime(ADR(RTCtime_struct));

				TestState[TesMyId] := TestState[TesMyId] + 1;
			6:
				TestIdle[TesMyId] := TestIdle[TesMyId] + 1;
				IF TestIdle[TesMyId] > 100*60*5 THEN
					TestCase[TesMyId] := FALSE;
					TestState[TesMyId] := 0;
				END_IF					
		END_CASE;
	END_IF
END_ACTION
