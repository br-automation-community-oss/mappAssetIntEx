
TYPE
	TIME_typ : 	STRUCT 
		Hour : UDINT;
		Minutes : UDINT;
	END_STRUCT;
	SHIFT_typ : 	STRUCT 
		Start : TIME_typ;
		End : TIME_typ;
		Name : STRING[20];
		ScheduledDowntime : ARRAY[0..9]OF exAssetIntScheduledDowntimeType;
	END_STRUCT;
END_TYPE
