

PROGRAM _INIT
	exAssetIntConfig.Shifts[0].Name := gShift[0].Name; 
	exAssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[0].TotalTime.End := UDINT_TO_TOD((gShift[0].End.Hour * 3600000) + (gShift[0].End.Minutes * 60000));
	exAssetIntConfig.Shifts[1].Name := gShift[1].Name; 
	exAssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[1].TotalTime.End := UDINT_TO_TOD((gShift[1].End.Hour * 3600000) + (gShift[1].End.Minutes * 60000));
	exAssetIntConfig.Shifts[2].Name := gShift[2].Name; 
	exAssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000));
	exAssetIntConfig.Shifts[2].TotalTime.End := UDINT_TO_TOD((gShift[2].End.Hour * 3600000) + (gShift[2].End.Minutes * 60000));
   
	IF (exAssetIntConfig.Shifts[1].TotalTime.Start = exAssetIntConfig.Shifts[0].TotalTime.End) AND (exAssetIntConfig.Shifts[1].TotalTime.End <> exAssetIntConfig.Shifts[1].TotalTime.Start) THEN
		exAssetIntConfig.Shifts[1].TotalTime.Start := UDINT_TO_TOD((gShift[1].Start.Hour * 3600000) + (gShift[1].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (exAssetIntConfig.Shifts[2].TotalTime.Start = exAssetIntConfig.Shifts[1].TotalTime.End) AND (exAssetIntConfig.Shifts[2].TotalTime.End <> exAssetIntConfig.Shifts[2].TotalTime.Start)  THEN
		exAssetIntConfig.Shifts[2].TotalTime.Start := UDINT_TO_TOD((gShift[2].Start.Hour * 3600000) + (gShift[2].Start.Minutes * 60000) + 1);
	END_IF
    
	IF (exAssetIntConfig.Shifts[0].TotalTime.Start = exAssetIntConfig.Shifts[2].TotalTime.End) THEN
		exAssetIntConfig.Shifts[0].TotalTime.Start := UDINT_TO_TOD((gShift[0].Start.Hour * 3600000) + (gShift[0].Start.Minutes * 60000) + 1);
	END_IF
		 
END_PROGRAM