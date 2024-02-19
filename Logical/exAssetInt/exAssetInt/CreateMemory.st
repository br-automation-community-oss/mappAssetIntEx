// -------------------------------------------------------------------------------------------
// Create internal memory
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK CreateMemory
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT enable THEN
		DatObjCreate_0.enable := FALSE;
		DatObjCreate_0();

		status := ERR_FUB_ENABLE_FALSE;
		state := 0;		
		RETURN;
	END_IF
	
	CASE state OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF EDGEPOS(enable) THEN
				idx := 0;
				tmpStr1 := 'AsMem_0';
				status := ERR_FUB_BUSY;
				Logger(exASSETINT_LOG_INFO, 'creating internal memory', logger);
				state := state + 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Generate new data module
		1:
			DatObjCreate_0.enable := TRUE;
			DatObjCreate_0.pName := ADR(tmpStr1);
			DatObjCreate_0.len := size;
			DatObjCreate_0.MemType := doTEMP;
			DatObjCreate_0.Option := doNO_CS;	
			DatObjCreate_0();
	
			// Data module created successful 
			IF DatObjCreate_0.status = ERR_OK THEN
				// Generate log entry
				tmpStr2 := 'created memory module ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				memory := DatObjCreate_0.pDatObjMem;
				status := ERR_OK;
				state := 0;
								
			// Data module already exists
			ELSIF DatObjCreate_0.status = doERR_DUPOBJECT  THEN
				// Generate log entry
				tmpStr2 := 'module already exists ';
				brsstrcat(ADR(tmpStr2), ADR(tmpStr1));
				Logger(exASSETINT_LOG_ALL, tmpStr2, logger);
				
				// Generate new module name
				idx := idx + 1;
				tmpStr1 := 'AsMem_';
				brsitoa(idx, ADR(tmpStr2));
				brsstrcat(ADR(tmpStr1), ADR(tmpStr2));
				
			// Error
			ELSIF DatObjCreate_0.status <> ERR_FUB_BUSY THEN
				status := DatObjCreate_0.status;
				state := 0;
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

