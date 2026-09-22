# Draw it. The bands are the simulated prediction intervals, the lines the
# observations.
x <- as.numeric(mid(obs$TIME))
par(mar = c(4, 4, 1.5, 1))
plot(obs$TIME, obs$DV, pch = 16, col = "#12366933", xlab = "time (h)",
     ylab = "concentration (mg/L)", ylim = c(0, max(obs$DV) * 1.05))
for (k in 1:3) {                                   # 5th, 50th, 95th percentiles
  polygon(c(x, rev(x)), c(sq[, 1, k], rev(sq[, 3, k])),
          col = "#12366922", border = NA)
  lines(x, oq[, k], lwd = 2, lty = if (k == 2) 1 else 2)
}
