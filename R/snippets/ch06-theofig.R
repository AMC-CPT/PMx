# 같은 표를 그림으로 옮긴다. 열한 점이 320 mg 선 위에 나란한데 9번만 떨어져 있다.
par(mar = c(4, 4, 1, 1))
plot(dz$ID, dz$TOTAL, pch = 16, col = "#123669", xaxt = "n", ylim = c(260, 330),
     xlab = "대상자", ylab = "용량 x 체중 (mg)")
axis(1, at = dz$ID)
abline(h = 320, lty = 2)
text(9, 267.8, "3.10 x 86.4", pos = 4, cex = 0.85)
