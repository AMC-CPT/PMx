par(mar = c(4, 4, 1.5, 1))
plot(obs$TIME, obs$PCDV, pch = 16, col = "#12366933", xlab = "time (h)",
     ylab = "prediction-corrected concentration (mg/L)", ylim = c(0, max(obs$PCDV) * 1.05))
for (k in 1:3) {
  polygon(c(x, rev(x)), c(sq2[, 1, k], rev(sq2[, 3, k])),
          col = "#12366922", border = NA)
  lines(x, oq2[, k], lwd = 2, lty = if (k == 2) 1 else 2)
}
