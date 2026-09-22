# =====================================================================
#  R/mkdata/make_blq.R  -  data for the BLQ practice of Ch 6 (M1/M3/M5)
#  Run from the repository root:   Rscript R/mkdata/make_blq.R
#
#  Cuts the observations of iov-sim.csv (Ch 16, make_iov.R), whose true values
#  are known, at LLOQ = 0.5 mg/L. The DV of a cut observation (BLQ = 1) is
#  written as LLOQ/2 = 0.25, so one file serves all three methods.
#    120m1  IGNORE=(BLQ.EQ.1)        discard the BLQ
#    120m5  fit as is                equivalent to substituting LLOQ/2
#    120m3  F_FLAG=1, Y=PHI(...)     BLQ as a censored observation (LAPLACE)
#  The uncut fit is 120base. The true values are in iov-sim-truth.csv.
#  No random numbers are used (it only cuts).
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

LLOQ <- 0.5
d   <- read.csv("data/iov-sim.csv", na.strings = ".")
obs <- d$EVID == 0
d$BLQ <- 0L
d$BLQ[obs & d$DV < LLOQ] <- 1L
d$DV[d$BLQ == 1L] <- LLOQ / 2
write.csv(d, "data/iov-blq.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iov-blq.csv: %d rows, %d observations, %d BLQ (%.1f %%), LLOQ %.2f mg/L\n",
            nrow(d), sum(obs), sum(d$BLQ), 100 * mean(d$BLQ[obs]), LLOQ))
