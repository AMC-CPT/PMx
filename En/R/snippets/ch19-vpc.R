# A VPC from 200 simulations of the Gompertz block model (the method of Ch 12).
# With only 20 animals the bands are wide. Even so, whether the observed median
# and the two edges lie inside the bands can be seen.
sim <- read.csv("nm/tg102bsim.R76/simtab.csv")
obs <- read.table("nm/tg102b.R76/sdtab", skip = 1, header = TRUE)
obs <- obs[obs$MDV == 0, ]
brk <- c(3, 8, 11, 13, 15, 17, 19, 23)
obs$BIN <- cut(obs$TIME, brk); sim$BIN <- cut(sim$TIME, brk)
qs <- c(0.05, 0.5, 0.95)
oq <- sapply(qs, function(q) tapply(obs$DV, obs$BIN, quantile, q))
sq <- sapply(qs, function(q) {
  m <- tapply(seq_len(nrow(sim)), list(sim$BIN, sim$REP),
              function(i) quantile(sim$DV[i], q))
  t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
}, simplify = "array")
mid <- tapply(obs$TIME, obs$BIN, median)
par(mar = c(4, 4, 1, 1))
plot(mid, oq[, 2], type = "n", ylim = c(0, 2500), xlab = "days after implantation",
     ylab = expression(volume~(mm^3)))
for (j in 1:3) polygon(c(mid, rev(mid)), c(sq[, 1, j], rev(sq[, 3, j])),
                       col = if (j == 2) "#12366944" else "#12366922", border = NA)
for (j in 1:3) lines(mid, oq[, j], lwd = if (j == 2) 2 else 1, lty = if (j == 2) 1 else 2)
points(obs$TIME, obs$DV, pch = 16, cex = 0.5, col = "#00000055")
