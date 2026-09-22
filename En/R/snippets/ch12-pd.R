# pd (prediction discrepancy). Where in the simulated distribution the
# observation sits, written as 0-1. If the model is right, pd follows a uniform
# distribution. NPDE is this plus a within-subject decorrelation.
pd <- sapply(seq_len(nrow(obs)), function(i) {
  v <- sim$DV[sim$ID == obs$ID[i] & sim$TIME == obs$TIME[i]]
  mean(v < obs$DV[i]) + 0.5 * mean(v == obs$DV[i])
})
# With 200 replicates pd is discrete, on a grid of 1/200. So a test for a
# continuous distribution such as the KS test must not be used as it stands
# (the ties distort the p value). Comparing with the mean 0.5 and variance 1/12
# of the uniform distribution is enough.
round(summary(pd), 3)
c(mean = round(mean(pd), 3), expected.mean = 0.5,
  variance = round(var(pd), 4), expected.variance = round(1 / 12, 4))

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
hist(pd, breaks = 10, col = "#12366955", border = "white",
     xlab = "pd", ylab = "frequency", main = "should be uniform")
abline(h = length(pd) / 10, lty = 2)
qqplot(qunif(ppoints(length(pd))), sort(pd), pch = 16, col = "#12366999",
       xlab = "uniform quantile", ylab = "pd", main = "QQ")
abline(0, 1)
