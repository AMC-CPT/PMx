# 그린다. 띠가 모의의 예측구간, 선이 관측이다.
x <- as.numeric(mid(obs$TIME))
par(mar = c(4, 4, 1.5, 1))
plot(obs$TIME, obs$DV, pch = 16, col = "#12366933", xlab = "시간 (h)",
     ylab = "농도 (mg/L)", ylim = c(0, max(obs$DV) * 1.05))
for (k in 1:3) {                                   # 5, 50, 95 백분위수
  polygon(c(x, rev(x)), c(sq[, 1, k], rev(sq[, 3, k])),
          col = "#12366922", border = NA)
  lines(x, oq[, k], lwd = 2, lty = if (k == 2) 1 else 2)
}
