# EX: dosing. The assembly function takes the time split into DAT2 (date) and
# TIME (hh:mm). Carrying the wall clock through is the point; elapsed time is
# derived at the very end.
table(route = EX$EXROUTE, unit = EX$EXDOSU)   # first check they are not mixed

EX$SUBJID <- EX$USUBJID
tEX <- parse_dtc(EX$EXSTDTC)
EX$DAT2 <- format(tEX, "%Y-%m-%d")
EX$TIME <- format(tEX, "%H:%M")
EX$AMT  <- as.numeric(EX$EXDOSE)
EX$RATE <- 0                       # IV bolus. For an infusion put AMT/duration

ex <- EX[, c("SUBJID", "DAT2", "TIME", "AMT", "RATE")]
head(ex, 3)
