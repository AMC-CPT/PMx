# =====================================================================
#  R/mkdata/make_theo.R  -  the oral absorption example dataset of Ch 7
#  Run from the repository root:   Rscript R/mkdata/make_theo.R
#
#  The original is data/theo-raw.txt, a copy of util/THEO from the NONMEM distribution (Ch 6).
#  12 subjects, a single oral dose of theophylline, 11 concentrations each.
#  The columns are ID DOSE TIME CP WT, with DOSE in mg/kg; the actual dose is DOSE*WT mg.
#
#  The dose transcription error of subject 9 found in Ch 6 (3.10, where 3.70
#  is right) is **not corrected**. The data is left as it is, and the  sensitivity analysis with the corrected value is left as an exercise.
#
#  Result: data/theo-nm.csv (ID TIME AMT RATE DV MDV EVID WT)
#    RATE = -2 is used by the zero-order absorption model (112zo) when it estimates the absorption duration D1.
#    A first-order absorption model discards it with RATE=DROP in $INPUT.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

raw <- read.table("data/theo-raw.txt", header = FALSE,
                  col.names = c("ID", "DOSE", "TIME", "CP", "WT"))
# In the original the dose appears only on the first row (time 0); the rest are '.'.
for (v in c("DOSE", "CP", "WT")) raw[[v]] <- suppressWarnings(as.numeric(raw[[v]]))
out <- list()
for (i in unique(raw$ID)) {
  z <- raw[raw$ID == i, ]
  amt <- z$DOSE[1] * z$WT[1]                       # mg/kg -> mg
  out[[length(out) + 1]] <- data.frame(ID = i, TIME = 0, AMT = round(amt, 2), RATE = -2,
                                       DV = NA, MDV = 1L, EVID = 1L, WT = z$WT[1])
  # The concentration at time 0 is not zero (theophylline from diet and so
  # on). It is a pre-dose observation, so it is excluded from the fit
  # (MDV=1) but the record is kept (the rule of Ch 5).
  obs <- z[!is.na(z$CP), ]
  out[[length(out) + 1]] <- data.frame(ID = i, TIME = obs$TIME, AMT = 0, RATE = 0,
                                       DV = obs$CP, MDV = as.integer(obs$TIME <= 0),
                                       EVID = 0L, WT = z$WT[1])
}
d <- do.call(rbind, out)
d <- d[order(d$ID, d$TIME, -d$EVID), ]
rownames(d) <- NULL
write.csv(d, "data/theo-nm.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/theo-nm.csv: %d rows, %d subjects, %d observations, doses %s mg\n", nrow(d),
            length(unique(d$ID)), sum(d$MDV == 0),
            paste(range(d$AMT[d$EVID == 1]), collapse = "-")))
