# Dose a virtual neonatal population with the final model (108wt). NONMEM is
# not needed. The concentration of a one-compartment intravenous bolus is the
# sum of an exponential term per dose (superposition).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
e   <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
th  <- unlist(e[e$ITERATION == -1000000000, paste0("THETA", 1:6)])
Om  <- matrix(unlist(e[e$ITERATION == -1000000000,
                       c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")]), 2)

conc <- function(t, doses, tdose, CL, V) {          # the concentration at time t
  k <- CL / V
  sapply(t, function(tt) sum(doses[tdose <= tt] / V * exp(-k * (tt - tdose[tdose <= tt]))))
}
# Regimen: a 20 mg/kg loading dose, then M mg/kg every 12 hours. Look at the
# trough at 72 hours.
trough72 <- function(wt, M, eta) {
  CL <- th[1] * (wt / 1.5)^th[5] * exp(eta[, 1])
  V  <- th[2] * (wt / 1.5)^th[6] * exp(eta[, 2])
  td <- seq(0, 60, by = 12)
  sapply(seq_along(wt), function(i)
    conc(72, c(20, rep(M, 5)) * wt[i], td, CL[i], V[i]))
}
set.seed(20260917)
n   <- 2000
wt  <- runif(n, 0.6, 3.6)                              # the weight range of the data
eta <- MASS::mvrnorm(n, c(0, 0), Om)
bin <- cut(wt, c(0.6, 1.0, 1.5, 2.5, 3.6), include.lowest = TRUE)
pta <- sapply(c(2, 2.5, 3, 4), function(M) {
  ct <- trough72(wt, M, eta)
  tapply(ct >= 15 & ct <= 30, bin, mean)
})
colnames(pta) <- paste0(c(2, 2.5, 3, 4), " mg/kg")
round(100 * pta, 1)                                    # % within the 15-30 mg/L target
