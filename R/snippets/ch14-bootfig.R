# 재표집 분포 위에 정규 근사를 겹친다. 셋을 골랐다. T5, T6 은 공변량 지수,
# T3 은 RSE 가 가장 큰 모수다.
par(mfrow = c(1, 3), mar = c(4, 2, 2.2, 1))
for (k in c("T3", "T5", "T6")) {
  v <- b[[k]][!is.na(b[[k]])]
  m <- fin[[key[[k]]]]; s <- se[[key[[k]]]]
  hist(v, breaks = 25, col = "#12366955", border = "white", freq = FALSE,
       main = k, xlab = "", ylab = "")
  curve(dnorm(x, m, s), add = TRUE, lwd = 2)             # 점근 정규 근사
  abline(v = m, lty = 2)                                 # 전체 자료의 추정치
}
