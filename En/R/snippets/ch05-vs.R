# VS: weight. Measured per visit, so it brings a time axis with it. One must
# decide whether to fix it or keep it time-varying.
VS$SUBJID <- VS$USUBJID
VS$BWT    <- as.numeric(VS$VSORRES)
vsw <- VS[VS$VSTESTCD == "WEIGHT", c("SUBJID", "VISIT", "VSDTC", "BWT")]

table(measurements.per.subject = table(vsw$SUBJID))

# Baseline (DAY 1) weight. If it is to be treated as time-invariant, this one
# value is spread over every record.
vsb <- vsw[vsw$VISIT == "DAY 1", c("SUBJID", "BWT")]
stopifnot(nrow(vsb) == length(unique(vsw$SUBJID)))   # exactly one per subject

r <- vsw$BWT / vsb$BWT[match(vsw$SUBJID, vsb$SUBJID)]    # weight relative to baseline
c(min = min(r), max = round(max(r), 3))
