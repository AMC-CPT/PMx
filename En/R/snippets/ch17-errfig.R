# Two residual error models: the bounded variance (pd100) and the combined
# error (pd103). Plot |IWRES| against the prediction. If the error model is
# right, the size of |IWRES| should not change with the prediction.
p3 <- fin("pd103")
c(bounded = round(r$f[["OBJ"]], 2), combined = round(p3$f[["OBJ"]], 2))
sdt <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE)
  s[s$MDV == 0 & s$DVID == 2, ] }
s0 <- sdt("pd100"); s3 <- sdt("pd103")
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (z in list(list(s0, "bounded variance"), list(s3, "combined error"))) {
  s <- z[[1]]
  plot(s$IPRE, abs(s$IWRE), pch = 16, cex = 0.5, col = "#12366955", ylim = c(0, 4),
       xlab = "IPRE (NRS)", ylab = "|IWRES|", main = z[[2]])
  lines(lowess(s$IPRE, abs(s$IWRE), f = 0.5), col = "#B2182B", lwd = 2)
  abline(h = sqrt(2 / pi), lty = 3)                  # 0.80, the expectation of |N(0,1)|
}
