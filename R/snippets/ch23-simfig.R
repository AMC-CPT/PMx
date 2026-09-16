# 유지용량 2.5 mg/kg 요법의 72시간 농도 띠. 체중 구간마다 90 % 예측구간이다.
tt <- seq(0, 72, by = 0.5)
td <- seq(0, 60, by = 12)
CL <- th[1] * (wt / 1.5)^th[5] * exp(eta[, 1])
V  <- th[2] * (wt / 1.5)^th[6] * exp(eta[, 2])
ct <- t(sapply(seq_len(n), function(i) conc(tt, c(20, rep(2.5, 5)) * wt[i], td, CL[i], V[i])))
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (b in levels(bin)) {
  q <- apply(ct[bin == b, ], 2, quantile, c(0.05, 0.5, 0.95))
  plot(tt, q[2, ], type = "n", ylim = c(0, 50), xlab = "시간 (h)", ylab = "",
       main = paste(b, "kg"))
  rect(0, 15, 72, 30, col = "#12366915", border = NA)          # 목표 범위
  polygon(c(tt, rev(tt)), c(q[1, ], rev(q[3, ])), col = "#12366944", border = NA)
  lines(tt, q[2, ], lwd = 1.5, col = "#123669")
}
mtext("농도 (mg/L)", side = 2, outer = TRUE, line = -0.5)
