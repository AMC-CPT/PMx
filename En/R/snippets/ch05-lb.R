# LB: creatinine. Three things catch at once.
#   (i) a censored value as a string, (ii) units by site, (iii) an upper limit
#   of normal by site.
head(sort(unique(LB$LBORRES)), 5)        # as.numeric() turns "<0.2" into NA

# First check that the normal range was reported in the same unit as the result
u <- merge(unique(LB[, c("SITEID", "LBORRESU")]),
           LN[, c("SITEID", "LBORRESU", "LBORNRHI")],
           by = "SITEID", suffixes = c(".res", ".ref"))
stopifnot(u$LBORRESU.res == u$LBORRESU.ref)
u

LB$SUBJID <- LB$USUBJID
n0 <- nrow(LB)
LB <- merge(LB, LN[, c("SITEID", "LBTESTCD", "LBORNRHI")],
            by = c("SITEID", "LBTESTCD"))
stopifnot(nrow(LB) == n0)

cens     <- grepl("^<", LB$LBORRES)
LB$CENS  <- as.integer(cens)
LB$CREA0 <- suppressWarnings(as.numeric(LB$LBORRES))
stopifnot(all(is.na(LB$CREA0) == cens))  # is a censored value the only thing that
                                         # becomes NA? If another string (QNS,
                                         # HEMOLYZED) is hiding, it halts here
LB$CREA0[cens] <- as.numeric(sub("^<", "", LB$LBORRES[cens])) / 2   # substitute limit/2

umol <- LB$LBORRESU == "umol/L"          # 1 mg/dL = 88.4 umol/L
LB$CREA  <- ifelse(umol, LB$CREA0 / 88.4, LB$CREA0)
LB$ULN   <- ifelse(umol, as.numeric(LB$LBORNRHI) / 88.4, as.numeric(LB$LBORNRHI))
LB$CREAR <- LB$CREA / LB$ULN             # ratio to the upper limit of normal

c(total = nrow(LB), censored = sum(cens))
aggregate(cbind(CREA0, CREA, CREAR) ~ SITEID, LB, function(x) round(mean(x), 2))

# Once the units agree the three sites line up. Yet the ratio to the upper limit
# of normal separates them again, because that limit differs by site. Which to
# use turns on whether the site difference lies in the assay or in the unit.
# Here it is the unit, so the converted value is carried forward as the covariate.
lbc <- LB[, c("SUBJID", "LBDTC", "CREA")]
