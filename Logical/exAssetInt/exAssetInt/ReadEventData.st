// -------------------------------------------------------------------------------------------
// Read event data
// -------------------------------------------------------------------------------------------
FUNCTION_BLOCK ReadEventData
	// -------------------------------------------------------------------------------------------
	// Reset everything when enable is false
	IF NOT Enable THEN
		Status := ERR_FUB_ENABLE_FALSE;
		State := 0;		
		RETURN;
	END_IF
	
	CASE State OF
		// -------------------------------------------------------------------------------------------
		// Wait for enable
		0:
			IF Enable THEN
				// Reset function blocks
				DirOpen_0.enable := FALSE;
				DirOpen_0();
				DirReadEx_0.enable := FALSE;
				DirReadEx_0();
				DirClose_0.enable := FALSE;
				DirClose_0();
				FileOpen_0.enable := FALSE;
				FileOpen_0();
				FileRead_0.enable := FALSE;
				FileRead_0();
				FileClose_0.enable := FALSE;
				FileClose_0();

				// Generate folder name
				DirCount := 0;
				TimeFirst := 0;
				DirName := 'events0';
				
				Status := ERR_FUB_BUSY;
				CreateLoggerEntry(exASSETINT_LOG_INFO, 'raeding all events', Logger);
				State := 1;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Start reading folder
		1:
			DirOpen_0.enable := TRUE;
			DirOpen_0.pDevice := ADR(Device);
			DirOpen_0.pName := ADR(DirName);
			DirOpen_0();
	
			// File created successful
			IF DirOpen_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'opened dir ';
				brsstrcat(ADR(TmpStr1), ADR(DirName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);
				
				// Go to next step
				State := 2;
				
			// Error
			ELSIF DirOpen_0.status <> ERR_FUB_BUSY THEN
				Status := DirOpen_0.status;
				State := 0;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Read next file ebtry
		2:
			DirReadEx_0.enable := TRUE;
			DirReadEx_0.ident := DirOpen_0.ident;
			DirReadEx_0.pData := ADR(FileInfo);
			DirReadEx_0.data_len := SIZEOF(FileInfo);
			DirReadEx_0();
	
			// New file found
			IF DirReadEx_0.status = ERR_OK THEN
				IF brsstrcmp(ADR(FileInfo.Filename), ADR('.')) <> 0 AND brsstrcmp(ADR(FileInfo.Filename), ADR('..')) <> 0 THEN			
					// Generate log entry
					TmpStr1 := 'found file ';
					brsstrcat(ADR(TmpStr1), ADR(FileInfo.Filename));
					CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);
	
					State := 4;
				END_IF

			// No more entries
			ELSIF DirReadEx_0.status = fiERR_NO_MORE_ENTRIES THEN
				// Generate log entry
				TmpStr1 := 'finished reading dir ';
				brsstrcat(ADR(TmpStr1), ADR(DirName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);

				State := 3;
				
			// Error
			ELSIF DirReadEx_0.status <> ERR_FUB_BUSY THEN
				Status := DirReadEx_0.status;
				State := 0;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Finish reading folder
		3:
			DirClose_0.enable := TRUE;
			DirClose_0.ident := DirOpen_0.ident;
			DirClose_0();
	
			// Directory closed successful
			IF DirClose_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'closed dir ';
				brsstrcat(ADR(TmpStr1), ADR(DirName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);
				
				// Open next directory, finish when all folders are created
				DirCount := DirCount + 1;
				IF DirCount > CORE_EVENT_NUM_MAX / 100 THEN
					Status := ERR_OK;
					State := 0;
					
				// Generate next folder name
				ELSE
					DirName := 'events';
					brsitoa(DirCount, ADR(TmpStr2));
					brsstrcat(ADR(DirName), ADR(TmpStr2));
					State := 1;
				END_IF
				
			// Error
			ELSIF DirClose_0.status <> ERR_FUB_BUSY THEN
				Status := DirClose_0.status;
				State := 0;
			END_IF
			
		// -------------------------------------------------------------------------------------------
		// Open event file
		4:
			// Generate file name
			FileName := DirName;
			brsstrcat(ADR(FileName), ADR('/'));
			brsstrcat(ADR(FileName), ADR(FileInfo.Filename));
			
			// Open file
			FileOpen_0.enable := TRUE;
			FileOpen_0.pDevice := ADR(Device);
			FileOpen_0.pFile := ADR(FileName);
			FileOpen_0.mode := fiREAD_ONLY;
			FileOpen_0();
	
			// File opened successful
			IF FileOpen_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'opened event file ';
				brsstrcat(ADR(TmpStr1), ADR(FileName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);
				
				// Go to next step
				State := 5;

			// Error
			ELSIF FileOpen_0.status <> ERR_FUB_BUSY THEN
				Status := FileOpen_0.status;
				State := 0;
			END_IF	
		
		// -------------------------------------------------------------------------------------------
		// Read event data
		5:
			FileRead_0.enable := TRUE;
			FileRead_0.ident := FileOpen_0.ident;
			FileRead_0.pDest := ADR(RecordData);
			FileRead_0.len := FileOpen_0.filelen;
			FileRead_0();
	
			// File read successful
			IF FileRead_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'read event file ';
				brsstrcat(ADR(TmpStr1), ADR(FileName));
				CreateLoggerEntry(exASSETINT_LOG_INFO, TmpStr1, Logger);
				
				// Check if record is newest
				InsertEventData(Memory, RecordCount, RecordData);
				
				// Increase record count, go to next step
				RecordCount := RecordCount + 1;
				State := 6;
				
			// Error
			ELSIF FileRead_0.status <> ERR_FUB_BUSY THEN
				Status := FileRead_0.status;
				State := 0;
			END_IF

		// -------------------------------------------------------------------------------------------
		// Close file
		6:
			FileClose_0.enable := TRUE;
			FileClose_0.ident := FileOpen_0.ident;
			FileClose_0();
	
			// File closed successful
			IF FileClose_0.status = ERR_OK THEN
				// Generate log entry
				TmpStr1 := 'closed event file ';
				brsstrcat(ADR(TmpStr1), ADR(FileName));
				CreateLoggerEntry(exASSETINT_LOG_ALL, TmpStr1, Logger);
				
				// Go to next step
				State := 2;
				
			// Error
			ELSIF FileClose_0.status <> ERR_FUB_BUSY THEN
				Status := FileClose_0.status;
				State := 0;
			END_IF
	END_CASE;

END_FUNCTION_BLOCK

FUNCTION InsertEventData
	x := 0;
	y := 0;
	sort := 0;

	// Set up start values for iteration
	IF RecordCount <> 0 THEN
		y := RecordCount - 1;
	END_IF
	x := y;

	// Start itteration	search
	WHILE y > 1 DO
		// Check current entry
		RecordMemory ACCESS Memory + x*SIZEOF(RecordData);
		sort := DiffDT(RecordData.TimeEnd, RecordMemory.TimeEnd);

		// Solve new search range
		IF y MOD 2 = 0 THEN
			y := y / 2;
		ELSE
			y := y / 2 + 1;
		END_IF

		// New range is lower or higher than current
		IF sort <> 16#FFFFFFFF THEN
			x := x + y;
			IF x > RecordCount THEN
				x := UINT_TO_INT(RecordCount);
			END_IF
		ELSE
			x := x - y;
			IF x < 1 THEN
				x := 1;
			END_IF
		END_IF
	END_WHILE;	

	// New entry is this, next or previous
	RecordMemory ACCESS Memory + x*SIZEOF(RecordData);
	sort := DiffDT(RecordData.TimeEnd, RecordMemory.TimeEnd);

	IF sort > 0 AND x <> RecordCount THEN
		x := x + 1;
	ELSIF x > 0 THEN
		RecordMemory ACCESS Memory + (x - 1)*SIZEOF(RecordData);
		sort := DiffDT(RecordData.TimeEnd, RecordMemory.TimeEnd);
		IF sort = 16#FFFFFFFF THEN
			x := x - 1;
		END_IF
	END_IF
	
	// Move all entrys backwards and fill in new entry
	brsmemmove(Memory + (x + 1)*SIZEOF(RecordData), Memory + x*SIZEOF(RecordData), (RecordCount - x)*SIZEOF(RecordData));
	brsmemcpy(Memory + x*SIZEOF(RecordData), ADR(RecordData), SIZEOF(RecordData));

END_FUNCTION

