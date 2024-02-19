// -------------------------------------------------------------------------------------------
// Create internal memory
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK CreateMemory
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		DatObjCreate_0.enable := FALSE;
		DatObjCreate_0();

		Status := ERR_FUB_ENABLE_FALSE;
		State := 0;		
		RETURN;
	END_IF
	
	CASE State OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF Enable THEN
				Cnt := 0;
				TmpStr1 := 'AsMem_0';
				Status := ERR_FUB_BUSY;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'creating internal memory', Logger);
				State := 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Generate new data module
		1:
			DatObjCreate_0.enable := TRUE;
			DatObjCreate_0.pName := ADR(TmpStr1);
			DatObjCreate_0.len := Size;
			DatObjCreate_0.MemType := doTEMP;
			DatObjCreate_0.Option := doNO_CS;	
			DatObjCreate_0();
	
			// Data module created successful 
			IF DatObjCreate_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr2 := 'created memory module ';
				brsstrcat(ADR(TmpStr2), ADR(TmpStr1));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				Memory := DatObjCreate_0.pDatObjMem;
				Status := ERR_OK;
				State := 0;
								
			// Data module already exists
			ELSIF DatObjCreate_0.status = doERR_DUPOBJECT  THEN
				// Generate log entry
				TmpStr2 := 'module already exists ';
				brsstrcat(ADR(TmpStr2), ADR(TmpStr1));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr2, Logger);
				
				// Generate new module name
				Cnt := Cnt + 1;
				TmpStr1 := 'AsMem_';
				brsitoa(Cnt, ADR(TmpStr2));
				brsstrcat(ADR(TmpStr1), ADR(TmpStr2));
				
			// Error
			ELSIF DatObjCreate_0.status <> ERR_FUB_BUSY THEN
				Status := DatObjCreate_0.status;
				State := 0;
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

