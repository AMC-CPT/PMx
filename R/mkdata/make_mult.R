# =====================================================================
#  R/mkdata/make_mult.R  -  Ch 7, third example: repeated oral dosing data in three codings
#  Run from the repository root:   Rscript R/mkdata/make_mult.R
#
#  Simulated data with known true values. 30 subjects, 100 mg every 12 h for
#  14 doses (7 days). Sampling is three troughs just before doses 3, 7 and 11,  plus a full profile after dose 14
#  (0.5, 1, 2, 4, 8, 12 h).
#
#  Model (truth). One-compartment first-order absorption. KA 1.2 /h, CL 4 L/h, V 50 L (half-life 8.7 h).
#    IIV omega^2: KA 0.16, CL 0.09, V 0.04.  Residual proportional 12 %, additive 0.05 mg/L.
#
#  The same observations are written as three datasets.
#    mult-explicit.csv  all 14 dosing records written out
#    mult-addl.csv      folded into one dose with ADDL=13 II=12 (the answer must be the same)
#    mult-ss.csv        only dose 14 written as SS=1 II=12, keeping the profile
#    mult-ssx.csv       a trap: only three doses (before steady state) written as SS=1
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")
set.seed(20260922)

TRUE_PAR <- c(KA = 1.2, CL = 4, V = 50, PROP = 0.12, ADD = 0.05)
OMEGA <- c(KA = 0.16, CL = 0.09, V = 0.04)
n <- 30; dose <- 100; ii <- 12; ndose <- 14
tprof <- c(0.5, 1, 2, 4, 8, 12)
ttrough <- (c(3, 7, 11) - 1) * ii                 # just before doses 3, 7, 11

# Closed form of repeated dosing (superposition)
conc <- function(t, ka, cl, v, tdose) {
  ke <- cl / v
  sapply(t, function(tt) { td <- tdose[tdose <= tt]
    sum(dose * ka / (v * (ka - ke)) * (exp(-ke * (tt - td)) - exp(-ka * (tt - td)))) })
}

ex <- list(); ad <- list(); ss <- list(); sx <- list()
for (i in seq_len(n)) {
  eta <- rnorm(3, 0, sqrt(OMEGA))
  ka <- TRUE_PAR["KA"] * exp(eta[1]); cl <- TRUE_PAR["CL"] * exp(eta[2]); v <- TRUE_PAR["V"] * exp(eta[3])
  tdose <- (0:(ndose - 1)) * ii
  tobs <- c(ttrough, (ndose - 1) * ii + tprof)
  f <- conc(tobs, ka, cl, v, tdose)
  y <- round(pmax(f * (1 + TRUE_PAR["PROP"] * rnorm(length(f))) + TRUE_PAR["ADD"] * rnorm(length(f)), 0.01), 3)
  obs <- data.frame(ID = i, TIME = tobs, AMT = 0, ADDL = 0, II = 0, SS = 0, DV = y, MDV = 0L, EVID = 0L)
  # (1) every dose
  d1 <- data.frame(ID = i, TIME = tdose, AMT = dose, ADDL = 0, II = 0, SS = 0, DV = NA, MDV = 1L, EVID = 1L)
  ex[[i]] <- rbind(d1, obs)
  # (2) folded with ADDL
  d2 <- data.frame(ID = i, TIME = 0, AMT = dose, ADDL = ndose - 1, II = ii, SS = 0, DV = NA, MDV = 1L, EVID = 1L)
  ad[[i]] <- rbind(d2, obs)
  # (3) one steady-state dose and the profile only; times shifted so that
  #     dose is time 0
  d3 <- data.frame(ID = i, TIME = 0, AMT = dose, ADDL = 0, II = ii, SS = 1, DV = NA, MDV = 1L, EVID = 1L)
  o3 <- obs[obs$TIME > (ndose - 1) * ii, ]; o3$TIME <- o3$TIME - (ndose - 1) * ii
  ss[[i]] <- rbind(d3, o3)
  # (4) the trap: the profile after three doses (before steady state)
  #     written as SS=1
  tdose3 <- (0:2) * ii
  f3 <- conc(2 * ii + tprof, ka, cl, v, tdose3)
  y3 <- round(pmax(f3 * (1 + TRUE_PAR["PROP"] * rnorm(length(f3))) + TRUE_PAR["ADD"] * rnorm(length(f3)), 0.01), 3)
  o4 <- data.frame(ID = i, TIME = tprof, AMT = 0, ADDL = 0, II = 0, SS = 0, DV = y3, MDV = 0L, EVID = 0L)
  sx[[i]] <- rbind(d3, o4)
}
wr <- function(l, f) { d <- do.call(rbind, l); d <- d[order(d$ID, d$TIME, -d$EVID), ]
  rownames(d) <- NULL; write.csv(d, f, row.names = FALSE, quote = FALSE, na = "."); nrow(d) }
cat(sprintf("mult-explicit %d rows, mult-addl %d, mult-ss %d, mult-ssx %d\n",
            wr(ex, "data/mult-explicit.csv"), wr(ad, "data/mult-addl.csv"),
            wr(ss, "data/mult-ss.csv"), wr(sx, "data/mult-ssx.csv")))
write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))), value = c(TRUE_PAR, OMEGA)),
          "data/mult-truth.csv", row.names = FALSE, quote = FALSE)
