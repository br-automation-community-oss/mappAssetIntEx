
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	// Auto count pieces
	IF gAutoCount THEN
		AutoCountTime.IN := TRUE;
		AutoCountTime.PT := gAutoCountCycle / 10;
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
	
	// Copy internal memory buffer to structure for debugging
//	IF exAssetIntLink.Memory <> 0 THEN
//		brsmemcpy(ADR(Memory), exAssetIntLink.Memory, SIZEOF(Memory));
//	ELSE
//		brsmemset(ADR(Memory), 0, SIZEOF(Memory));		
//	END_IF
//	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

