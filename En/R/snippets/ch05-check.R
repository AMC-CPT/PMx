# Compare against the answer. This practice data was made by decomposing
# pheno.csv, so the answer is known.
ans <- read.csv("data/pheno.csv", na.strings = ".")

pre <- NMDS$EVID == 0 & NMDS$MDV == 1    # pre-dose samples; not in the answer
out <- NMDS[!pre, ]
c(answer = nrow(ans), assembled = nrow(out), pre.dose = sum(pre))

stopifnot(
  nrow(out) == nrow(ans),
  all(out$ID == ans$ID), all(out$EVID == ans$EVID), all(out$APGR == ans$APGR),
  max(abs(out$TAFD - ans$TIME))                             < 1e-6,
  max(abs(out$WT   - ans$WT))                               < 1e-9,
  max(abs(out$AMT[out$EVID == 1] - ans$AMT[ans$EVID == 1])) < 1e-9,
  max(abs(out$DV[out$MDV == 0]   - ans$DV[ans$MDV == 0]))   < 1e-9
)
"all 744 assembled rows match the answer"

# How far would the time axis have been out if it had been assembled on the
# nominal times?
err <- as.numeric(difftime(parse_dtc(PC$PCDTC), parse_dtc(PC$PCDTC_ACTUAL),
                           units = "mins"))[PC$PCREASND != "PREDOSE"]
c(observations.out = sum(err != 0), max.min = max(abs(err)),
  mean.abs.min = round(mean(abs(err)), 1))

# Export only what passed verification. This is the input to Ch 6.
# Write with quote = FALSE: NM-TRAN cannot read quoted fields.
write.csv(NMDS, "data/pheno-nm.csv", row.names = FALSE, quote = FALSE)
