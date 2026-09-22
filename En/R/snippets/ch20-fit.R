# Three hazard models: constant hazard (tte100), Weibull (tte101), and Weibull
# with an exposure effect (tte102).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
r0 <- fin("tte100"); r1 <- fin("tte101"); r2 <- fin("tte102")
rse <- function(r, k) round(100 * r$s[[k]] / abs(r$f[[k]]), 1)
data.frame(
  model = c("constant, dose", "Weibull, dose", "Weibull, exposure"),
  OFV = round(c(r0$f[["OBJ"]], r1$f[["OBJ"]], r2$f[["OBJ"]]), 2),
  LAM = signif(c(r0$f[["THETA1"]], r1$f[["THETA1"]], r2$f[["THETA1"]]), 3),
  GAM = c(NA, signif(r1$f[["THETA2"]], 3), signif(r2$f[["THETA2"]], 3)),
  BETA = signif(c(r0$f[["THETA2"]], r1$f[["THETA3"]], r2$f[["THETA3"]]), 3),
  RSE_BETA = c(rse(r0, "THETA2"), rse(r1, "THETA3"), rse(r2, "THETA3")))
# Truth: GAM 1.4, LAM 0.056, BETA 1.2 (per mg/L). The BETA of the dose models is
# per 100 mg.
c(true.LAM = round(truth[["TTE_LAM"]], 4), true.GAM = truth[["TTE_GAM"]],
  true.BETA = truth[["TTE_BETA"]])
# Hazard ratios of the exposure model, at the mean CAVG of each arm.
hr <- exp(-r2$f[["THETA3"]] * c(0.42, 0.83)); names(hr) <- c("50 mg", "100 mg")
round(hr, 2)
