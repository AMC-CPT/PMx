# The time written in PC is the nominal time. When the sample was actually
# drawn lives in another domain.
PC$SUBJID <- PC$USUBJID
n0 <- nrow(PC)
PC <- merge(PC, CO[, c("USUBJID", "PCDTC_PLANNED", "PCDTC_ACTUAL")],
            by.x = c("USUBJID", "PCDTC"), by.y = c("USUBJID", "PCDTC_PLANNED"))
# Check on the spot that the merge neither added nor dropped rows
stopifnot(nrow(PC) == n0, !anyNA(PC$PCDTC_ACTUAL))
# How far nominal and actual diverge (minutes)
dev <- as.numeric(difftime(parse_dtc(PC$PCDTC_ACTUAL), parse_dtc(PC$PCDTC),
                           units = "mins"))
summary(dev)
