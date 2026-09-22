# Derive elapsed time (h). The first dose is zero.
clock <- dat2_time_to_posix(nm$DAT2, nm$TIME)
t0 <- tapply(as.numeric(clock)[nm$AMT > 0], nm$SUBJID[nm$AMT > 0], min)
nm$TAFD <- round((as.numeric(clock) - t0[nm$SUBJID]) / 3600, 4)
nm$EVID <- ifelse(nm$AMT > 0, 1L, 0L)

# Records at the same time keep the order they had at assembly (a pre-dose
# sample comes before the dose).
nm <- nm[order(nm$ID, nm$TAFD), ]

# The time axis is carried as DAT2 (date) + TIME (hh:mm); NONMEM translates that
# into elapsed time. Our derived TAFD is carried alongside so that the
# translation can be verified.
NMDS <- data.frame(ID = nm$ID, DAT2 = nm$DAT2, TIME = nm$TIME,
                   AMT = nm$AMT, RATE = nm$RATE, CMT = nm$CMT,
                   DV = nm$DV, MDV = nm$MDV, EVID = nm$EVID,
                   WT = nm$WT, BWT = nm$BWT, SEX = nm$SEX, APGR = nm$APGR,
                   CREA = round(nm$CREA, 3), TAFD = nm$TAFD)
head(NMDS, 4)
