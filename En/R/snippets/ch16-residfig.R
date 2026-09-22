# |IWRES| against the individual prediction. If the error model is right, the
# size does not change with the prediction. The additive model grows at high
# concentrations and the proportional model grows at low ones.
sdt <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE); s[s$MDV == 0, ] }
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
for (m in names(mods)) {
  s <- sdt(m)
  plot(s$IPRE, abs(s$IWRE), pch = 16, cex = 0.4, col = "#12366944", ylim = c(0, 4),
       xlab = "IPRED (mg/L)", ylab = "|IWRES|", main = mods[m])
  lines(lowess(s$IPRE, abs(s$IWRE), f = 0.4), col = "#B2182B", lwd = 2)
  abline(h = sqrt(2 / pi), lty = 3)                  # 0.80, the expectation of |N(0,1)|
}
