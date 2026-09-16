# |IWRES| 를 개체 예측값에 대해. 오차 모형이 맞으면 크기가 예측값에 따라 변하지 않는다.
# 가법 모형은 높은 농도에서 커지고, 비례 모형은 낮은 농도에서 커진다.
sdt <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE); s[s$MDV == 0, ] }
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
for (m in names(mods)) {
  s <- sdt(m)
  plot(s$IPRE, abs(s$IWRE), pch = 16, cex = 0.4, col = "#12366944", ylim = c(0, 4),
       xlab = "IPRED (mg/L)", ylab = "|IWRES|", main = mods[m])
  lines(lowess(s$IPRE, abs(s$IWRE), f = 0.4), col = "#B2182B", lwd = 2)
  abline(h = sqrt(2 / pi), lty = 3)                  # |N(0,1)| 의 기대값 0.80
}
