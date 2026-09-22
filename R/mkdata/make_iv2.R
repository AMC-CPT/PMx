# =====================================================================
#  R/mkdata/make_iv2.R  -  simulated data for the two-compartment IV example of Ch 7
#  Run from the repository root:   Rscript R/mkdata/make_iv2.R
#
#  Made with the true values known. Two-compartment IV bolus of 100 mg,
#  40 subjects, 11 samples from 0.25 to 48 h. The parameters are set so that
#  the distribution and elimination phases separate clearly (half-lives of
#  about 0.9 h and 15 h). The point is to say, by distance from the truth,
#  where a one-compartment fit goes wrong (140iv2), that two compartments are  right (200iv2), and that three are not supported by the data (300iv2).
#
#  Model.  CL = 5 L/h, V1 = 20 L, Q = 8 L/h, V2 = 60 L
#    IIV omega^2: 0.09 (all four, independent, log-normal)
#    Residual: proportional 10 %, additive 0.02 mg/L
#  Columns.  ID TIME AMT DV MDV EVID WT SEX
#    WT and SEX are **spurious covariates** put there to fill the tables
#    (cotab/catab). They were drawn independently of the model, so they must    not be used as an example of covariate search.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

set.seed(20260919)

TRUE_PAR <- c(CL = 5, V1 = 20, Q = 8, V2 = 60, PROP = 0.10, ADD = 0.02)
OMEGA    <- c(CL = 0.09, V1 = 0.09, Q = 0.09, V2 = 0.09)

n    <- 40
dose <- 100
tobs <- c(0.25, 0.5, 1, 2, 4, 6, 8, 12, 24, 36, 48)

# Closed-form solution of the two-compartment bolus (Volume 3, Ch 7)
c2iv <- function(t, D, CL, V1, Q, V2) {
  k10 <- CL / V1; k12 <- Q / V1; k21 <- Q / V2
  s <- k10 + k12 + k21; p <- k10 * k21
  a <- (s + sqrt(s^2 - 4 * p)) / 2
  b <- (s - sqrt(s^2 - 4 * p)) / 2
  A <- D / V1 * (a - k21) / (a - b)
  B <- D / V1 * (k21 - b) / (a - b)
  A * exp(-a * t) + B * exp(-b * t)
}

rows <- list()
for (i in seq_len(n)) {
  eta <- rnorm(4, 0, sqrt(OMEGA))
  p   <- TRUE_PAR[c("CL", "V1", "Q", "V2")] * exp(eta)
  f   <- c2iv(tobs, dose, p[["CL"]], p[["V1"]], p[["Q"]], p[["V2"]])
  y   <- f * (1 + TRUE_PAR[["PROP"]] * rnorm(length(tobs))) +
         TRUE_PAR[["ADD"]] * rnorm(length(tobs))
  wt  <- round(rnorm(1, 70, 12), 1)
  sex <- rbinom(1, 1, 0.5)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = 0, AMT = dose, DV = NA,
      MDV = 1L, EVID = 1L, WT = wt, SEX = sex)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tobs, AMT = 0,
      DV = round(pmax(y, 0.001), 3), MDV = 0L, EVID = 0L, WT = wt, SEX = sex)
}
d <- do.call(rbind, rows)
rownames(d) <- NULL
write.csv(d, "data/iv2-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iv2-sim.csv: %d rows, %d subjects, %d observations\n", nrow(d), n, sum(d$MDV == 0)))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/iv2-sim-truth.csv", row.names = FALSE, quote = FALSE)
