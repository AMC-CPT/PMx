# VPC by arm. The placebo arm's band checks the time course of the placebo
# response, the treated arms' bands the exposure-response. Draw them pooled and
# it becomes the average of the four and checks neither.
sim <- read.csv(nmf("pd100sim", "simtab.csv"))
sim <- sim[sim$DVID == 2, ]
obs <- s0
arm <- c("placebo", "40 mg", "80 mg", "160 mg")
qs  <- c(0.05, 0.5, 0.95)
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (a in 1:4) {
  o <- obs[obs$ARM == a, ]; s <- sim[sim$ARM == a, ]
  tt <- sort(unique(o$TIME))
  oq <- sapply(qs, function(q) tapply(o$DV, o$TIME, quantile, q))
  sq <- sapply(qs, function(q) {
    m <- tapply(seq_len(nrow(s)), list(s$TIME, s$REP), function(i) quantile(s$DV[i], q))
    t(apply(m, 1, quantile, c(0.025, 0.975)))
  }, simplify = "array")
  plot(tt, oq[, 2], type = "n", ylim = c(0, 10), xlab = "time (h)", ylab = "", main = arm[a])
  for (j in 1:3) polygon(c(tt, rev(tt)), c(sq[, 1, j], rev(sq[, 2, j])),
                         col = if (j == 2) "#12366944" else "#12366922", border = NA)
  for (j in 1:3) lines(tt, oq[, j], lwd = if (j == 2) 2 else 1, lty = if (j == 2) 1 else 2)
}
mtext("NRS", side = 2, outer = TRUE, line = -0.5)
