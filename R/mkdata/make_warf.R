# =====================================================================
#  R/mkdata/make_warf.R  -  warfarin-type PK/PD simulated data for the indirect response chapter
#  Run from the repository root:   Rscript R/mkdata/make_warf.R
#
#  Made with the true values known. Warfarin **inhibits the synthesis** of
#  clotting factors, and clotting capacity (PCA, prothrombin complex
#  activity, % of normal) falls slowly and returns according to their turnover. This is indirect response type I (inhibition of kin).
#
#  Design. 40 subjects, single 100 mg oral dose. Concentration at 0.5, 2, 6,
#  12, 24, 48, 72, 96, 120 h; PCA at 0 (pre-dose), 12, 24, 36, 48, 72, 96, 120, 144 h.
#
#  Model.
#    PK   1-compartment oral.  KA 1.5 /h, CL 0.15 L/h, V 8 L   (half-life 37 h)
#    PD   dPCA/dt = KIN * (1 - C/(C50 + C)) - KOUT * PCA,   PCA(0) = BASE = KIN/KOUT
#         BASE 100 %, KOUT 0.05 /h (turnover half-life 14 h), C50 1.0 mg/L
#    IIV  omega^2: KA 0.25, CL 0.09, V 0.04, BASE 0.01, KOUT 0.09, C50 0.16
#    Residual:  concentration proportional 10 %, PCA additive SD 5 %
#
#  Columns.  ID TIME AMT CMT DV DVID MDV EVID
#    CMT 1 = depot (dosing), 2 = central (concentration), 3 = PCA.   DVID 1 = concentration, 2 = PCA.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

set.seed(20260919)

TRUE_PAR <- c(KA = 1.5, CL = 0.15, V = 8, BASE = 100, KOUT = 0.05, C50 = 1.0,
              PROP = 0.10, ADDPD = 5)
OMEGA <- c(KA = 0.25, CL = 0.09, V = 0.04, BASE = 0.01, KOUT = 0.09, C50 = 0.16)

n    <- 40
dose <- 100
tPK  <- c(0.5, 2, 6, 12, 24, 48, 72, 96, 120)
tPD  <- c(0, 12, 24, 36, 48, 72, 96, 120, 144)

# PCA has no closed form, so it is integrated numerically (4th-order Runge-Kutta on a 0.05 h grid).
pca_curve <- function(ka, cl, v, base, kout, c50, tmax = 150, h = 0.05) {
  ke   <- cl / v
  conc <- function(t) dose * ka / (v * (ka - ke)) * (exp(-ke * t) - exp(-ka * t))
  kin  <- base * kout
  f    <- function(t, p) kin * (1 - conc(t) / (c50 + conc(t))) - kout * p
  tt   <- seq(0, tmax, by = h); p <- numeric(length(tt)); p[1] <- base
  for (j in seq_len(length(tt) - 1)) {
    k1 <- f(tt[j], p[j]);            k2 <- f(tt[j] + h/2, p[j] + h/2 * k1)
    k3 <- f(tt[j] + h/2, p[j] + h/2 * k2); k4 <- f(tt[j] + h, p[j] + h * k3)
    p[j + 1] <- p[j] + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
  }
  list(conc = conc, pca = approxfun(tt, p))
}

rows <- list()
for (i in seq_len(n)) {
  eta  <- rnorm(6, 0, sqrt(OMEGA))
  p    <- TRUE_PAR[c("KA", "CL", "V", "BASE", "KOUT", "C50")] * exp(eta)
  cv   <- pca_curve(p["KA"], p["CL"], p["V"], p["BASE"], p["KOUT"], p["C50"])
  cp   <- cv$conc(tPK) * (1 + TRUE_PAR["PROP"] * rnorm(length(tPK)))
  pca  <- cv$pca(tPD) + TRUE_PAR["ADDPD"] * rnorm(length(tPD))
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = 0, AMT = dose, CMT = 1,
      DV = NA, DVID = 0, MDV = 1L, EVID = 1L)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tPK, AMT = 0, CMT = 2,
      DV = round(pmax(cp, 0.01), 3), DVID = 1, MDV = 0L, EVID = 0L)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tPD, AMT = 0, CMT = 3,
      DV = round(pmax(pca, 1), 1), DVID = 2, MDV = 0L, EVID = 0L)
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, -d$EVID, d$CMT), ]
rownames(d) <- NULL
write.csv(d, "data/warf-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/warf-sim.csv: %d rows, %d subjects, conc %d, PCA %d, PCA min %g\n",
            nrow(d), n, sum(d$DVID == 1), sum(d$DVID == 2), min(d$DV[d$DVID == 2])))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/warf-sim-truth.csv", row.names = FALSE, quote = FALSE)
