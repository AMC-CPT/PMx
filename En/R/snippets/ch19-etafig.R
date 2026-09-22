# The EBEs per animal. An animal with a large ALPHA has a large BETA too: a
# tumor that started growing fast slows down fast. It means there is one axis,
# and the reduced Gompertz uses that axis.
pa <- read.table("nm/tg102b.R76/patab", skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(pa$ALPH, pa$BETA, pch = 16, col = "#123669", xlab = expression(alpha~(1/day)),
     ylab = expression(beta~(1/day)), main = "individual estimates")
abline(lm(BETA ~ ALPH, pa), col = "grey50")
plot(pa$ETA1, pa$ETA2, pch = 16, col = "#123669", xlab = "ETA1 (ALPHA)",
     ylab = "ETA2 (BETA)", main = "the ETA pair")
abline(0, 1, col = "grey50", lty = 2)
