
// -------------------------------------------------------------------------------------------
// Handle log buffer
FUNCTION_BLOCK exAssetIntCore
	CASE Internal.State OF

		exASSETINT_STATE_INIT_1:
			IF Enable THEN
				Internal.State := exASSETINT_STATE_INIT_2;
			END_IF

		exASSETINT_STATE_INIT_2:
			Internal.CreateDirStructure.enable := TRUE;
			Internal.CreateDirStructure.device := DeviceName;
			Internal.CreateDirStructure();
	
			IF Internal.CreateDirStructure.status = ERR_OK THEN
				
			ELSIF Internal.CreateDirStructure.status <> ERR_FUB_BUSY THEN
				
			END_IF

	END_CASE;
END_FUNCTION_BLOCK

FUNCTION_BLOCK CreateDirStructure
	
	CASE state OF

		0:
			IF enable THEN
				idx := 0;
				tmpStr := 'events0';
				status := ERR_FUB_BUSY;
				state := state + 1;
			END_IF

		1:
			DirCreate_0.enable := TRUE;
			DirCreate_0.pDevice := ADR(device);
			DirCreate_0.pName := ADR(tmpStr);
			DirCreate_0();
	
			IF DirCreate_0.status = ERR_OK THEN
				
			ELSIF DirCreate_0.status <> ERR_FUB_BUSY THEN
				
			END_IF

	END_CASE;

END_FUNCTION_BLOCK

