# Observation records. The time axis is built on the actual sampling time.
tPC <- parse_dtc(PC$PCDTC_ACTUAL)
PC$DAT2 <- format(tPC, "%Y-%m-%d")
PC$TIME <- format(tPC, "%H:%M")
PC$DV   <- as.numeric(PC$PCSTRESN)
PC$CMT  <- 1L                                    # central compartment

# A pre-dose sample is not a measurement but a zero the design guarantees.
# It is not counted as an observation.
table(PREDOSE = PC$PCREASND == "PREDOSE", DV.0 = PC$DV == 0)

# A BLQ is a value actually measured and found below the limit. A pre-dose zero
# goes into neither numerator nor denominator (Ch 6 separates the two in its
# table of BLQ handling).
post <- PC[PC$PCREASND != "PREDOSE", ]
c(observations = nrow(post), BLQ = sum(post$DV < as.numeric(post$PCLLOQ)),
  LLOQ = as.numeric(post$PCLLOQ[1]))

pc <- PC[, c("SUBJID", "DAT2", "TIME", "DV", "CMT")]
