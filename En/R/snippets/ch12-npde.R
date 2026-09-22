# NPDE. The npde package walks exactly the four steps of the box above
# (decorrelation by Cholesky decomposition). Observations and simulations must
# be in the same row order, and the simulations are in long form, the whole set
# of observations stacked once per replicate.
library(npde)
x <- autonpde(namobs = obs[, c("ID", "TIME", "DV")], namsim = sim[, c("ID", "TIME", "DV")],
              iid = 1, ix = 2, iy = 3, boolsave = FALSE, verbose = FALSE)
res <- x@results@res                       # ypred, pd, npde and so on
head(round(res[, c("ypred", "pd", "npde")], 3), 3)
# Normality before decorrelation (npd = qnorm(pd)) and after (npde). The same
# data, the same simulations.
round(c(SW.npd = shapiro.test(qnorm(res$pd))$p.value,
        SW.npde = shapiro.test(res$npde)$p.value), 3)

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
qqnorm(res$npde, pch = 16, col = "#12366999", main = "normal QQ",
       xlab = "normal quantile", ylab = "NPDE")
abline(0, 1)
plot(obs$TIME, res$npde, pch = 16, col = "#12366999", xlab = "time (h)",
     ylab = "NPDE", main = "against time")
abline(h = c(-1.96, 0, 1.96), lty = c(2, 1, 2))
