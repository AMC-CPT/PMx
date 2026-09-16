# S5 가 그리는 것. ETA 의 히스토그램과 정규 QQ. 모형은 ETA ~ N(0, OMEGA) 를
# 가정했다. 그 가정을 EBE 로 점검하되, 수축이 크면 이 그림은 가정이 아니라
# 수축을 보여 준다(위 표에서 확인하고 읽는다).
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5))
for (k in 1:2) {
  x <- pa[[paste0("ETA", k)]]; om <- sqrt(f[[sprintf("OMEGA.%d.%d.", k, k)]])
  hist(x, breaks = 12, col = "#12366944", border = "white", main = paste0("ETA", k),
       xlab = "", ylab = "", freq = FALSE)
  curve(dnorm(x, 0, om), add = TRUE, col = "#B2182B", lwd = 2)       # 추정된 OMEGA 의 정규
  qqnorm(x, main = paste0("ETA", k, " QQ"), pch = 16, col = "#123669", xlab = "", ylab = "")
  qqline(x, col = "grey40")
}
