# =====================================================================
#  R/mkdata/make_iov.R  -  simulated data for the chapter on variability
#  Run from the repository root:   Rscript R/mkdata/make_iov.R
#
#  Made with the true values known. **Interoccasion variability (IOV)** is
#  laid over interindividual variability (IIV), and a **subpopulation** of
#  low clearance (20 % poor metabolisers) is mixed in. Only then can one say,
#  by distance from the truth, what inflates when IOV is ignored and how much of the subpopulation $MIX recovers. The result is data/iov-sim.csv, with the seed written in.
#
#  Design. One-compartment oral. 100 mg once at 0, 168 and 336 h (days 1, 8,
#  15), three occasions (OCC 1-3). Sampling at 0.5, 1, 2, 4, 8, 12, 24 h per occasion. 60 subjects.
#
#  Model.
#    KA = 1.0 /h, CL = 4.0 L/h (normal), 1.2 L/h (poor, 30 %), V = 50 L
#    IIV  omega^2: KA 0.16, CL 0.09, V 0.04            (log-normal)
#    IOV  pi^2:    CL 0.04, KA 0.09                    (redrawn each occasion)
#    Residual:  proportional 12 %, additive 0.05 mg/L
#
#  Columns.  ID TIME AMT DV MDV EVID OCC POP
#    OCC 1-3 = dosing occasion.  POP 1 = normal, 2 = poor metaboliser (the truth; the model does not know it).
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

set.seed(20260918)

TRUE_PAR <- c(KA = 1.0, CL = 4.0, FPM = 0.3, V = 50, PPM = 0.2,
              PROP = 0.12, ADD = 0.05)
OMEGA <- c(KA = 0.16, CL = 0.09, V = 0.04)
PI    <- c(CL = 0.04, KA = 0.09)

n     <- 60
tdose <- c(0, 168, 336)
tobs  <- c(0.5, 1, 2, 4, 8, 12, 24)
dose  <- 100

pop  <- rbinom(n, 1, TRUE_PAR["PPM"]) + 1L          # 1 = normal, 2 = poor
rows <- list()
for (i in seq_len(n)) {
  eta <- rnorm(3, 0, sqrt(OMEGA))
  ka  <- TRUE_PAR["KA"] * exp(eta[1])
  cl  <- TRUE_PAR["CL"] * ifelse(pop[i] == 2, TRUE_PAR["FPM"], 1) * exp(eta[2])
  v   <- TRUE_PAR["V"]  * exp(eta[3])
  for (k in seq_along(tdose)) {
    kap <- rnorm(2, 0, sqrt(PI))                      # occasion effects
    kao <- ka * exp(kap[2]); clo <- cl * exp(kap[1])
    ke  <- clo / v
    f   <- dose * kao / (v * (kao - ke)) * (exp(-ke * tobs) - exp(-kao * tobs))
    y   <- f * (1 + TRUE_PAR["PROP"] * rnorm(length(tobs))) +
           TRUE_PAR["ADD"] * rnorm(length(tobs))
    rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tdose[k], AMT = dose,
        DV = NA, MDV = 1L, EVID = 1L, OCC = k, POP = pop[i])
    rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tdose[k] + tobs, AMT = 0,
        DV = round(pmax(y, 0.01), 3), MDV = 0L, EVID = 0L, OCC = k, POP = pop[i])
  }
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, -d$EVID), ]
rownames(d) <- NULL
write.csv(d, "data/iov-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iov-sim.csv: %d rows, %d subjects, %d observations, %d poor metabolisers\n",
            nrow(d), n, sum(d$MDV == 0), sum(pop == 2)))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA)),
                              paste0("PI_", names(PI))),
                     value = c(TRUE_PAR, OMEGA, PI)),
          "data/iov-sim-truth.csv", row.names = FALSE, quote = FALSE)
