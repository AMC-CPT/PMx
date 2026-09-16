# 프로파일 우도 곡선 셋. 가로 점선이 3.84, 세로 회색선이 점근 구간이다.
# 세 칸의 세로 눈금을 맞춰 두면 곡선의 가파르기를 서로 견줄 수 있다.
par(mfrow = c(1, 3), mar = c(4, 4, 2.2, 1))
for (k in c("T3", "T5", "T6")) {
  z <- p[p$PAR == k, ]
  plot(z$VALUE, z$dOFV, type = "b", pch = 16, main = k,
       xlab = "", ylab = "dOFV", ylim = c(0, 12))
  abline(h = qchisq(0.95, 1), lty = 2)
  abline(v = fin[[key[[k]]]] + c(-1.96, 1.96) * se[[key[[k]]]], col = "grey60")
}
