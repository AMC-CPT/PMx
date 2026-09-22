# =====================================================================
#  R/mkdata/make_pd.R  -  simulated pharmacodynamic data for Ch 17
#  Run from the repository root:   Rscript R/mkdata/make_pd.R
#
#  Made with the true values known, so that "what is biased when the placebo
#  arm is dropped" can be said as a distance from the truth (Ch 17). The
#  result is data/pd-sim.csv, with the seed written in so the same file comes out again (the rule of Ch 3).
#
#  Design. Post-operative pain NRS (0-10). Single IV bolus of an analgesic,
#  four arms (placebo, 40, 80, 160 mg), 40 per arm. NRS at 0, 0.5, 1, 2, 4, 6,
#  8, 12, 24 h; concentration only in the dosed arms at 0.5, 2, 6, 12 h (sparse). The NRS at time 0 is pre-dose.
#
#  Model. The scale is bounded, so the effect is added on the logit scale and mapped back to 0-10 at the end.
#    PK     C(t) = DOSE/V * exp(-CL/V * t)                (1-compartment IV bolus)
#    Logit  L(t) = LB - PLMAX*(1 - exp(-KPL*t)) - EMAX*C/(EC50 + C)
#    NRS    F(t) = 10 / (1 + exp(-L))                     (always between 0 and 10)
#  LB is the logit of the baseline; logit(7/10) = 0.847. Interindividual variability sits on LB, PLMAX and EC50.
#  The residual uses a binomial-like variance for a bounded scale: W = sqrt(a^2 + b^2 * F*(10-F))
#  (Analects 15.A). It is largest mid-scale and goes to zero at both ends.
#
#  Columns.  ID ARM DOSE TIME DV DVID MDV BSL BFLG
#    DVID 1 = concentration (mg/L), 2 = NRS.  BSL = that person's time-0 NRS (for the observed-baseline model).
#    BFLG 1 = the time-0 NRS record (excluded from the fit in the observed-baseline model).
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

set.seed(20260917)
RNGkind()

TRUE_PAR <- c(CL = 5, V = 40,                          # PK (L/h, L)
              LB = 0.847, PLMAX = 0.85, KPL = 0.15,    # baseline logit, placebo response (logit)
              EMAX = 1.7, EC50 = 1.5,                  # drug effect (logit), EC50 (mg/L)
              A = 0.35, B = 0.14)                      # residual (bounded scale)
OMEGA <- c(CL = 0.09, V = 0.04, LB = 0.10, PLMAX = 0.16, EC50 = 0.25)
expit <- function(x) 1 / (1 + exp(-x))

arms  <- c(0, 40, 80, 160)
nArm  <- 40
tNRS  <- c(0, 0.5, 1, 2, 4, 6, 8, 12, 24)
tPK   <- c(0.5, 2, 6, 12)

rows <- list()
id <- 0
for (dose in arms) for (k in seq_len(nArm)) {
  id  <- id + 1
  eta <- rnorm(5, 0, sqrt(OMEGA))
  CL   <- TRUE_PAR["CL"]   * exp(eta[1])
  V    <- TRUE_PAR["V"]    * exp(eta[2])
  LB   <- TRUE_PAR["LB"]   + eta[3]                    # added on the logit scale
  PLMX <- TRUE_PAR["PLMAX"]* exp(eta[4])
  EC50 <- TRUE_PAR["EC50"] * exp(eta[5])
  conc <- function(t) ifelse(t > 0, dose / V * exp(-CL / V * t), 0)   # time 0 is pre-dose
  # NRS
  L  <- LB - PLMX * (1 - exp(-TRUE_PAR["KPL"] * tNRS)) -
        TRUE_PAR["EMAX"] * conc(tNRS) / (EC50 + conc(tNRS))
  f  <- 10 * expit(L)
  w  <- sqrt(TRUE_PAR["A"]^2 + TRUE_PAR["B"]^2 * f * (10 - f))
  y  <- round(pmin(pmax(f + w * rnorm(length(tNRS)), 0), 10), 1)
  rows[[length(rows) + 1]] <- data.frame(ID = id, ARM = match(dose, arms),
      DOSE = dose, TIME = tNRS, DV = y, DVID = 2, MDV = 0,
      BSL = y[1], BFLG = as.integer(tNRS == 0))
  # Concentration (dosed arms only). Proportional error 15 %
  if (dose > 0) {
    cp <- conc(tPK) * (1 + 0.15 * rnorm(length(tPK)))
    rows[[length(rows) + 1]] <- data.frame(ID = id, ARM = match(dose, arms),
        DOSE = dose, TIME = tPK, DV = round(pmax(cp, 0.01), 3), DVID = 1, MDV = 0,
        BSL = y[1], BFLG = 0L)
  }
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, d$DVID), ]
rownames(d) <- NULL

dir.create("data", showWarnings = FALSE)
write.csv(d, "data/pd-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/pd-sim.csv: %d rows, %d subjects, NRS %d, conc %d, NRS range %g-%g\n",
            nrow(d), length(unique(d$ID)), sum(d$DVID == 2), sum(d$DVID == 1),
            min(d$DV[d$DVID == 2]), max(d$DV[d$DVID == 2])))

# Ordinal version. The same NRS collapsed into three categories: 0-3 mild (0), 4-6 moderate (1), 7-10 severe (2).
# Used by the ordinal logistic example of Ch 17. Concentration records are dropped.
o <- d[d$DVID == 2, c("ID", "ARM", "DOSE", "TIME", "DV", "MDV")]
o$DV <- as.integer(cut(o$DV, c(-Inf, 3.5, 6.5, Inf), labels = FALSE)) - 1L
write.csv(o, "data/pd-ord.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/pd-ord.csv: %d rows, category distribution %s\n", nrow(o),
            paste(table(o$DV), collapse = "/")))

# Keep the true values alongside. The table in Ch 17 compares against them.
write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/pd-sim-truth.csv", row.names = FALSE, quote = FALSE)
