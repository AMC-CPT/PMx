# tm103 의 적합 그림. 용량군마다 한 칸, 동물마다 관측(점)과 개체 예측(실선), 집단 예측은
# 점선. 로그 축이다. 낮은 용량에서 마지막 관측들이 예측보다 꺾여 내려가는지, 높은
# 용량에서 초기가 맞는지 본다. 보고서의 '전형적인 그림'이 이것이다.
sd <- read.table("nm/tm103.R76/sdtab", skip = 1, header = TRUE)
sd <- sd[sd$MDV == 0, ]
lv <- sort(unique(sd$LVL))
par(mfrow = c(2, 3), mar = c(3.5, 3.5, 1.5, 0.5), mgp = c(2.2, 0.7, 0))
for (L in lv) {
  z <- sd[sd$LVL == L, ]
  plot(NA, xlim = c(0, 150), ylim = c(0.02, 800), log = "y", xlab = "시간 (h)",
       ylab = "농도 (mg/L)", main = paste(L, "mg/kg"))
  for (i in unique(z$ID)) { o <- z[z$ID == i, ]
    points(o$TIME, o$DV, pch = 16, cex = 0.5, col = "grey40")
    lines(o$TIME, o$IPRE, col = "steelblue", lwd = 0.8) }
  m <- tapply(z$PRED, z$TIME, function(x) exp(mean(log(x))))
  lines(as.numeric(names(m)), m, lty = 2, lwd = 1.5)
}
