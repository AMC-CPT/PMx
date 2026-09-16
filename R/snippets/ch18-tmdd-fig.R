# 왼쪽: 동물 50마리의 농도(로그 축), 색은 용량 수준. 오른쪽: 용량군별 기하평균을 용량으로
# 나눈 것. 선형 약동학이면 오른쪽의 곡선들이 겹쳐야 한다. 낮은 용량일수록 아래로 꺾여
# 먼저 사라진다. 표적이 약을 붙잡아 없애는 몫이 낮은 용량에서 크기 때문이고, 그것이
# TMDD 의 표지다. 높은 용량에서는 표적이 포화되어 선형 약동학처럼 보인다.
lv <- sort(unique(obs$LVL)); cols <- hcl.colors(9, "Blues 3", rev = TRUE)[4:9]
gm <- function(x) exp(mean(log(x)))
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(NA, xlim = c(0, 150), ylim = c(0.02, 800), log = "y", xlab = "시간 (h)",
     ylab = "농도 (mg/L)", main = "동물마다")
for (i in unique(obs$ID)) { o <- obs[obs$ID == i, ]
  lines(o$TIME, o$DV, col = cols[match(o$LVL[1], lv)], lwd = 0.8) }
plot(NA, xlim = c(0, 150), ylim = c(0.005, 60), log = "y", xlab = "시간 (h)",
     ylab = "농도 / 용량", main = "용량으로 나눈 기하평균")
for (i in seq_along(lv)) { o <- obs[obs$LVL == lv[i], ]; m <- tapply(o$DV / o$LVL, o$TIME, gm)
  lines(as.numeric(names(m)), m, type = "b", pch = 16, cex = 0.7, col = cols[i]) }
legend("bottomleft", paste(lv, "mg/kg"), col = cols, lwd = 2, bty = "n", cex = 0.7)
