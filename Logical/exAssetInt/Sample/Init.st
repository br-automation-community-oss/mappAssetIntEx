

PROGRAM _INIT
	exAssetIntConfig.Export.DecimalMark := ',';
	exAssetIntConfig.Export.ColumnSeparator := ';';
	brsstrcpy(ADR(exAssetIntConfig.Export.JobStatisticsFileNamePattern), ADR('JobStatistics_%Y_%m_%d_%H_%M.csv'));
	brsstrcpy(ADR(exAssetIntConfig.Export.ShiftStatisticsFileNamePattern), ADR('ShiftStatistics_%Y_%m_%d_%H_%M.csv'));
	brsstrcpy(ADR(exAssetIntConfig.Export.TimelineFileNamePattern), ADR('Timeline_%Y_%m_%d_%H_%M.csv'));

	brsstrcpy(ADR(exAssetIntConfig.Export.JobStatisticsFileNamePattern), ADR('JobStatistics_%Y_%m_%d.csv'));
	brsstrcpy(ADR(exAssetIntConfig.Export.ShiftStatisticsFileNamePattern), ADR('ShiftStatistics_%Y_%m_%d.csv'));
	brsstrcpy(ADR(exAssetIntConfig.Export.TimelineFileNamePattern), ADR('Timeline_%Y_%m_%d.csv'));

	// Check if we are running in simuulation
	IF DiagCpuIsARsim() THEN
		gDeviceName := 'ARsim';
	ELSE
		gDeviceName := 'USER_HD';
	END_IF
END_PROGRAM