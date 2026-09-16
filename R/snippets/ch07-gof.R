# 적합도 그림. 관측 레코드만 본다(MDV=0). 투약과 투여 전 채혈은 빠진다.
obs <- sd[sd$MDV == 0, ]
lim <- range(c(obs$DV, obs$PRED, obs$IPRE))
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))

plot(obs$PRED, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED (mg/L)", ylab = "DV (mg/L)", main = "집단 예측")
abline(0, 1)
plot(obs$IPRE, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "IPRE (mg/L)", ylab = "DV (mg/L)", main = "개체 예측")
abline(0, 1)
