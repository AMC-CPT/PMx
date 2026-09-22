# Simulating receptor occupancy. With the estimates of tm103, give a typical
# 4 kg monkey a single dose at each of six levels and integrate free drug, free
# target and complex out to 30 days. RO = complex / (free target + complex).
# The data hold no RO. It is a quantity only a model can show, and that is why
# this model was built.
library(deSolve)
th <- r$f; bwt <- 4
p <- c(K = th[["THETA1"]] / th[["THETA2"]], K12 = th[["THETA3"]] / (th[["THETA2"]] * bwt),
       K21 = th[["THETA3"]] / th[["THETA4"]], KON = th[["THETA5"]], KOFF = th[["THETA6"]],
       KINT = th[["THETA7"]], KSYN = th[["THETA12"]] * bwt, KDEG = th[["THETA9"]])
v1 <- th[["THETA2"]] * bwt
tmdd <- function(t, A, p) with(as.list(p), list(c(
  -(K + K12) * A[1] + K21 * A[2] - KON * A[1] * A[3] + KOFF * A[4],
  K12 * A[1] - K21 * A[2],
  KSYN - KDEG * A[3] - KON * A[1] * A[3] + KOFF * A[4],
  KON * A[1] * A[3] - (KOFF + KINT) * A[4])))
tt <- c(seq(0, 24, by = 0.25), seq(25, 720, by = 1))
lv <- c(0.3, 1, 3, 5, 10, 20); cols <- hcl.colors(9, "Blues 3", rev = TRUE)[4:9]
sim <- lapply(lv, function(dose) {
  y0 <- c(dose * bwt, 0, p[["KSYN"]] / p[["KDEG"]], 0)
  o <- ode(y0, tt, tmdd, p, rtol = 1e-8, atol = 1e-10)
  data.frame(TIME = o[, 1], C = o[, 2] / v1, RO = o[, 5] / (o[, 4] + o[, 5])) })
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(NA, xlim = c(0, 30), ylim = c(1e-3, 1e3), log = "y", xlab = "days",
     ylab = "free drug concentration (mg/L)", main = "concentration")
for (i in seq_along(lv)) lines(sim[[i]]$TIME / 24, sim[[i]]$C, col = cols[i], lwd = 2)
legend("topright", paste(lv, "mg/kg"), col = cols, lwd = 2, bty = "n", cex = 0.75)
plot(NA, xlim = c(0, 30), ylim = c(0, 1), xlab = "days", ylab = "receptor occupancy", main = "RO")
for (i in seq_along(lv)) lines(sim[[i]]$TIME / 24, sim[[i]]$RO, col = cols[i], lwd = 2)
abline(h = 0.9, lty = 3)
# Days above 90 % RO for each dose. This is the number that sets the dosing interval.
sapply(seq_along(lv), function(i) { z <- sim[[i]]; round(max(z$TIME[z$RO > 0.9], 0) / 24, 1) }) |>
  setNames(paste(lv, "mg/kg"))
