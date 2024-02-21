

PROGRAM _INIT
	AssetIntConfig.Shifts[0].Name := 'Shift0'; 
	AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000));
	AssetIntConfig.Shifts[0].TotalTime.End := UDINT_TO_TOD((gShift[0].End.Hour * 3600000) + (gShift[0].End.Minutes * 60000));
	AssetIntConfig.Shifts[1].Name := 'Shift1'; 
	AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000));
	AssetIntConfig.Shifts[1].TotalTime.End := UDINT_TO_TOD((gShift[1].End.Hour * 3600000) + (gShift[1].End.Minutes * 60000));
	AssetIntConfig.Shifts[2].Name := 'Shift2'; 
	AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000));
	AssetIntConfig.Shifts[2].TotalTime.End := UDINT_TO_TOD((gShift[2].End.Hour * 3600000) + (gShift[2].End.Minutes * 60000));
   
	IF (AssetIntConfig.Shifts[1].TotalTime.Start = AssetIntConfig.Shifts[0].TotalTime.End) AND (AssetIntConfig.Shifts[1].TotalTime.End <> AssetIntConfig.Shifts[1].TotalTime.Start) THEN
		AssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (AssetIntConfig.Shifts[2].TotalTime.Start = AssetIntConfig.Shifts[1].TotalTime.End) AND (AssetIntConfig.Shifts[2].TotalTime.End <> AssetIntConfig.Shifts[2].TotalTime.Start)  THEN
		AssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (AssetIntConfig.Shifts[0].TotalTime.Start = AssetIntConfig.Shifts[2].TotalTime.End) THEN
		AssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 1);
	END_IF
		 
END_PROGRAM