# A picture beats the numbers. Plot the two ETA against weight.
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
for (e in c("ETA1", "ETA2")) {
  plot(s$WT, s[[e]], pch = 16, col = "#12366999", xlab = "weight (kg)", ylab = e,
       main = paste(e, if (e == "ETA1") "(CL)" else "(V)"))
  abline(h = 0, lty = 3)
  abline(lm(s[[e]] ~ s$WT), lwd = 1.5)
}
