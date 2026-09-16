# 동물마다의 EBE. ALPHA 가 큰 동물은 BETA 도 크다. 빨리 자라기 시작한 종양이
# 빨리 느려진다. 축이 하나라는 뜻이고, 축소 Gompertz 가 그 축을 쓴다.
pa <- read.table("nm/tg102b.R76/patab", skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(pa$ALPH, pa$BETA, pch = 16, col = "#123669", xlab = expression(alpha~(1/day)),
     ylab = expression(beta~(1/day)), main = "개체별 추정치")
abline(lm(BETA ~ ALPH, pa), col = "grey50")
plot(pa$ETA1, pa$ETA2, pch = 16, col = "#123669", xlab = "ETA1 (ALPHA)",
     ylab = "ETA2 (BETA)", main = "ETA 쌍")
abline(0, 1, col = "grey50", lty = 2)
