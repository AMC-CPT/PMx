# Three profile likelihood curves. The horizontal dashed line is 3.84 and the
# grey verticals are the asymptotic interval. Matching the vertical scale of
# the three panels lets their steepness be compared.
par(mfrow = c(1, 3), mar = c(4, 4, 2.2, 1))
for (k in c("T3", "T5", "T6")) {
  z <- p[p$PAR == k, ]
  plot(z$VALUE, z$dOFV, type = "b", pch = 16, main = k,
       xlab = "", ylab = "dOFV", ylim = c(0, 12))
  abline(h = qchisq(0.95, 1), lty = 2)
  abline(v = fin[[key[[k]]]] + c(-1.96, 1.96) * se[[key[[k]]]], col = "grey60")
}
