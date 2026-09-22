# VPC of the simultaneous model. Concentration and PCA are drawn separately
# (the method of Ch 12). 200 simulations (wf201sim).
sim <- read.csv(nmf("wf201sim", "simtab.csv"))
qs <- c(0.05, 0.5, 0.95)
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
for (k in 1:2) {
  o <- obs[obs$DVID == k, ]; s <- sim[sim$DVID == k, ]
  tt <- sort(unique(o$TIME))
  oq <- sapply(qs, function(q) tapply(o$DV, o$TIME, quantile, q))
  sq <- sapply(qs, function(q) {
    m <- tapply(seq_len(nrow(s)), list(s$TIME, s$REP), function(i) quantile(s$DV[i], q))
    t(apply(m, 1, quantile, c(0.025, 0.975)))
  }, simplify = "array")
  plot(tt, oq[, 2], type = "n", ylim = if (k == 1) c(0, 20) else c(0, 130),
       xlab = "time (h)", ylab = c("concentration (mg/L)", "PCA (%)")[k],
       main = c("concentration", "PCA")[k])
  for (j in 1:3) polygon(c(tt, rev(tt)), c(sq[, 1, j], rev(sq[, 2, j])),
                         col = if (j == 2) "#12366944" else "#12366922", border = NA)
  for (j in 1:3) lines(tt, oq[, j], lwd = if (j == 2) 2 else 1, lty = if (j == 2) 1 else 2)
}
