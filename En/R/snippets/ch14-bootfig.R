# Overlay the normal approximation on the resampling distribution. Three were
# chosen: T5 and T6 are the covariate exponents, T3 the parameter with the
# largest RSE.
par(mfrow = c(1, 3), mar = c(4, 2, 2.2, 1))
for (k in c("T3", "T5", "T6")) {
  v <- b[[k]][!is.na(b[[k]])]
  m <- fin[[key[[k]]]]; s <- se[[key[[k]]]]
  hist(v, breaks = 25, col = "#12366955", border = "white", freq = FALSE,
       main = k, xlab = "", ylab = "")
  curve(dnorm(x, m, s), add = TRUE, lwd = 2)             # asymptotic normal approximation
  abline(v = m, lty = 2)                                 # the estimate from the whole data
}
