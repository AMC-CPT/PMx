# 잔차. 여기서 보는 것은 모형의 좋고 나쁨이 아니라 **자료 준비의 잘못**이다.
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))

plot(obs$TIME, obs$CWRES, pch = 16, col = "#12366966",
     xlab = "시간 (h)", ylab = "CWRES", main = "시간에 대하여")
abline(h = c(-2, 0, 2), lty = c(3, 1, 3))
plot(obs$PRED, obs$CWRES, pch = 16, col = "#12366966",
     xlab = "PRED (mg/L)", ylab = "CWRES", main = "집단 예측에 대하여")
abline(h = c(-2, 0, 2), lty = c(3, 1, 3))
