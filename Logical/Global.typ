
TYPE
	TIME_typ : 	STRUCT 
		Hour : UDINT;
		Minutes : UDINT;
	END_STRUCT;
	SHIFT_typ : 	STRUCT 
		Start : TIME_typ;
		End : TIME_typ;
		Name : STRING[20];
	END_STRUCT;
END_TYPE
