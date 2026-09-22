# The reference plot. An observed-versus-population-prediction plot has no
# "expected shape". Even when the model is right the points do not sit on the
# diagonal. So draw the same plot from data simulated under the same model and
# compare it with the observed one (Karlsson & Savic 2007).
sim <- read.csv(nmf("108wtsim", "simtab.csv"))                # 200 replicates (Ch 12)
obs <- sd[, c("ID", "TIME", "DV", "PRED")]
one <- merge(sim[sim$REP == 1, ], obs[, c("ID", "TIME", "PRED")], by = c("ID", "TIME"))
lim <- range(c(obs$DV, one$DV, obs$PRED))
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(obs$PRED, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED", ylab = "DV", main = "observed")
abline(0, 1); lines(lowess(obs$PRED, obs$DV), col = "#B2182B", lwd = 2)
plot(one$PRED, one$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED", ylab = "simulated DV", main = "reference: the model being right")
abline(0, 1); lines(lowess(one$PRED, one$DV), col = "#B2182B", lwd = 2)
