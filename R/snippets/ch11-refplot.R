# 기준 그림(reference plot). 관측 대 집단 예측 그림에는 "기대되는 모양"이 없다.
# 모형이 옳아도 점이 대각선에 붙지 않는다. 그래서 같은 모형으로 모의한 자료로
# 같은 그림을 그려 두고 관측 그림과 견준다(Karlsson & Savic 2007).
sim <- read.csv(nmf("108wtsim", "simtab.csv"))                # 200회 모의 (12장)
obs <- sd[, c("ID", "TIME", "DV", "PRED")]
one <- merge(sim[sim$REP == 1, ], obs[, c("ID", "TIME", "PRED")], by = c("ID", "TIME"))
lim <- range(c(obs$DV, one$DV, obs$PRED))
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(obs$PRED, obs$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED", ylab = "DV", main = "관측")
abline(0, 1); lines(lowess(obs$PRED, obs$DV), col = "#B2182B", lwd = 2)
plot(one$PRED, one$DV, xlim = lim, ylim = lim, pch = 16, col = "#12366966",
     xlab = "PRED", ylab = "모의 DV", main = "모형이 옳을 때의 기준")
abline(0, 1); lines(lowess(one$PRED, one$DV), col = "#B2182B", lwd = 2)
