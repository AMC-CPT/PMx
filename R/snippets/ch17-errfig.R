# 잔차오차 모형 둘. 유계 분산(pd100)과 복합 오차(pd103). |IWRES| 를 예측값에 대해 그린다.
# 오차 모형이 맞으면 |IWRES| 의 크기가 예측값에 따라 달라지지 않아야 한다.
p3 <- fin("pd103")
c(유계 = round(r$f[["OBJ"]], 2), 복합 = round(p3$f[["OBJ"]], 2))
sdt <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE)
  s[s$MDV == 0 & s$DVID == 2, ] }
s0 <- sdt("pd100"); s3 <- sdt("pd103")
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (z in list(list(s0, "유계 분산"), list(s3, "복합 오차"))) {
  s <- z[[1]]
  plot(s$IPRE, abs(s$IWRE), pch = 16, cex = 0.5, col = "#12366955", ylim = c(0, 4),
       xlab = "IPRE (NRS)", ylab = "|IWRES|", main = z[[2]])
  lines(lowess(s$IPRE, abs(s$IWRE), f = 0.5), col = "#B2182B", lwd = 2)
  abline(h = sqrt(2 / pi), lty = 3)                  # |N(0,1)| 의 기대값 0.80
}
