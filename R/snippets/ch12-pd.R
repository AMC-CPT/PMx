# pd(예측 불일치). 관측이 모의 분포에서 어느 자리에 있는가를 0-1 로 적는다.
# 모형이 맞으면 pd 가 균등분포를 따른다. NPDE 는 여기에 개체 내 탈상관을 더한 것이다.
pd <- sapply(seq_len(nrow(obs)), function(i) {
  v <- sim$DV[sim$ID == obs$ID[i] & sim$TIME == obs$TIME[i]]
  mean(v < obs$DV[i]) + 0.5 * mean(v == obs$DV[i])
})
# 재현이 200회이므로 pd 는 1/200 눈금의 이산값이다. 그래서 KS 검정 같은
# 연속분포 검정을 그대로 쓰면 안 된다(동점 때문에 p 값이 틀어진다).
# 균등분포의 평균 0.5, 분산 1/12 과 견주는 것으로 충분하다.
round(summary(pd), 3)
c(평균 = round(mean(pd), 3), 기대평균 = 0.5,
  분산 = round(var(pd), 4), 기대분산 = round(1 / 12, 4))

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
hist(pd, breaks = 10, col = "#12366955", border = "white",
     xlab = "pd", ylab = "빈도", main = "균등해야 한다")
abline(h = length(pd) / 10, lty = 2)
qqplot(qunif(ppoints(length(pd))), sort(pd), pch = 16, col = "#12366999",
       xlab = "균등분포 분위수", ylab = "pd", main = "QQ")
abline(0, 1)
