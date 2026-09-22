# Draw it to the range of the null distribution. The actual value is off the
# axis, so point at it with an arrow. (Put both in one figure and the null
# distribution is crushed invisibly against the left edge.)
xmax <- max(null, qchisq(0.95, 2)) * 1.35
par(mar = c(4, 4, 1.5, 1))
h <- hist(null, breaks = 20, col = "#12366955", border = "white",
          xlim = c(0, xmax), xlab = "dOFV", ylab = "frequency", main = "")
ymax <- max(h$counts)

abline(v = qchisq(0.95, 2), lty = 2)                     # 95th percentile of chi-square
text(qchisq(0.95, 2), ymax, "chi-square 95%", pos = 4, cex = 0.9)
arrows(xmax * 0.80, ymax * 0.45, xmax * 0.99, ymax * 0.45, length = 0.12, lwd = 2)
text(xmax * 0.80, ymax * 0.58, sprintf("actual %.1f", obs), pos = 4, font = 2)
