
TYPE
    exAssetIntCoreAlarmEnum : 
        ( (* Alarms of exAssetInt Core *)
        exASSETINT_ALM_EXPORT_STATISTICS := 0, (* Export shift statistics failed. *)
        exASSETINT_ALM_EXPORT_TIMELINE := 1, (* Export timeline failed. *)
        exASSETINT_ALM_EXPORT_JOB := 2, (* Export job statistics failed. *)
        exASSETINT_ALM_UNSCH_DOWNTIME := 3 (* Machine is in an unscheduled downtime phase *)
    );
END_TYPE
