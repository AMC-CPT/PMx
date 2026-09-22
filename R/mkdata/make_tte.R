# =====================================================================
#  R/mkdata/make_tte.R  -  simulated data for the time-to-event and count chapter
#  Run from the repository root:   Rscript R/mkdata/make_tte.R
#
#  Two datasets, both with known true values.
#
#  (1) data/tte-sim.csv  time-to-event. 300 subjects, 100 each on placebo, 50 and 100 mg.
#      Exposure is the steady-state average CAVG = DOSE/(CL*24), with CL 5 L/h and CV 30 %.
#      The hazard is Weibull:  h(t) = LAM*GAM*t^(GAM-1) * exp(-BETA*CAVG)
#        GAM 1.4 (hazard rises with time), median event time on placebo 6 months,
#        BETA 1.2 (hazard ratio 0.37 at CAVG 0.83 mg/L). Time in months.
#      Administrative censoring at 12 months; 10 % drop out at random before that (censored).
#      Records: one empty record at time 0 (EVID=2) per person, plus one event/censoring record.
#        DV 1 = event, 0 = censored.
#
#  (2) data/cnt-sim.csv  counts. 200 subjects in the same three arms. Seizure
#      counts over six 28-day intervals. Baseline rate LAM0 median 6 per interval, IIV omega^2 0.6 (CV about 90 %).
#      Drug effect  LAM = LAM0 * (1 - EMAX*CAVG/(EC50 + CAVG)),  EMAX 0.6, EC50 0.3.
#      Overdispersion: negative binomial, dispersion OVDP 0.3 (variance = LAM + OVDP*LAM^2).
#      This is so that what goes wrong when fitting Poisson can be shown.
#
#  Columns.  tte: ID TIME DV MDV EVID DOSE CAVG      cnt: ID TIME DV MDV DOSE CAVG
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

set.seed(20260920)

## ---- (1) Time-to-event -----------------------------------------------
TTE_PAR <- c(GAM = 1.4, MED0 = 6, BETA = 1.2, CL = 5, OMCL = 0.09, PDROP = 0.10)
LAM <- log(2) / TTE_PAR["MED0"]^TTE_PAR["GAM"]         # S(6) = 0.5 (placebo)

n    <- 300
dose <- rep(c(0, 50, 100), each = n / 3)
cl   <- TTE_PAR["CL"] * exp(rnorm(n, 0, sqrt(TTE_PAR["OMCL"])))
cavg <- dose / (cl * 24)
# Inverse-transform sampling: S(t) = exp(-LAM*t^GAM*exp(-BETA*CAVG)) = U
u    <- runif(n)
tev  <- (-log(u) / (LAM * exp(-TTE_PAR["BETA"] * cavg)))^(1 / TTE_PAR["GAM"])
tdrop <- ifelse(runif(n) < TTE_PAR["PDROP"], runif(n, 0, 12), 12)
tobs <- pmin(tev, tdrop)
ev   <- as.integer(tev <= tdrop)
d1 <- rbind(data.frame(ID = seq_len(n), TIME = 0, DV = 0, MDV = 1L, EVID = 2L,
                       DOSE = dose, CAVG = round(cavg, 4)),
            data.frame(ID = seq_len(n), TIME = round(tobs, 3), DV = ev, MDV = 0L,
                       EVID = 0L, DOSE = dose, CAVG = round(cavg, 4)))
d1 <- d1[order(d1$ID, d1$TIME), ]
rownames(d1) <- NULL
write.csv(d1, "data/tte-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/tte-sim.csv: %d subjects, %d events (placebo %d, 50 mg %d, 100 mg %d), %d censored\n",
            n, sum(ev), sum(ev[dose == 0]), sum(ev[dose == 50]), sum(ev[dose == 100]),
            sum(ev == 0)))

## ---- (2) Counts --------------------------------------------------------
CNT_PAR <- c(LAM0 = 6, OMLAM = 0.6, EMAX = 0.6, EC50 = 0.3, OVDP = 0.3, CL = 5, OMCL = 0.09)
m     <- 200
dose2 <- rep(c(0, 50, 100), length.out = m)
cl2   <- CNT_PAR["CL"] * exp(rnorm(m, 0, sqrt(CNT_PAR["OMCL"])))
cavg2 <- dose2 / (cl2 * 24)
lam0  <- CNT_PAR["LAM0"] * exp(rnorm(m, 0, sqrt(CNT_PAR["OMLAM"])))
lam   <- lam0 * (1 - CNT_PAR["EMAX"] * cavg2 / (CNT_PAR["EC50"] + cavg2))
rows <- list()
for (i in seq_len(m)) {
  # Negative binomial = gamma-mixed Poisson. Size 1/OVDP, mean lam.
  y <- rnbinom(6, size = 1 / CNT_PAR["OVDP"], mu = lam[i])
  rows[[i]] <- data.frame(ID = i, TIME = 1:6, DV = y, MDV = 0L,
                          DOSE = dose2[i], CAVG = round(cavg2[i], 4))
}
d2 <- do.call(rbind, rows)
rownames(d2) <- NULL
write.csv(d2, "data/cnt-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/cnt-sim.csv: %d subjects, %d rows, mean count placebo %.1f / 50 mg %.1f / 100 mg %.1f, max %d\n",
            m, nrow(d2), mean(d2$DV[d2$DOSE == 0]), mean(d2$DV[d2$DOSE == 50]),
            mean(d2$DV[d2$DOSE == 100]), max(d2$DV)))

write.csv(data.frame(name = c(paste0("TTE_", names(TTE_PAR)), "TTE_LAM",
                              paste0("CNT_", names(CNT_PAR))),
                     value = c(TTE_PAR, LAM, CNT_PAR)),
          "data/tte-sim-truth.csv", row.names = FALSE, quote = FALSE)
