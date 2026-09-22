# Goodness-of-fit plots. Only observation records are looked at (MDV=0); doses
# and pre-dose samples drop out.
obs <- sd[sd$MDV == 0, ]
lim <- range(c(obs$DV, obs$PRED, obs$IPRE))
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))

plot(obs$PRED, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED (mg/L)", ylab = "DV (mg/L)", main = "population prediction")
abline(0, 1)
plot(obs$IPRE, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "IPRE (mg/L)", ylab = "DV (mg/L)", main = "individual prediction")
abline(0, 1)
