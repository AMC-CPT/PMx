# 숫자보다 그림이 낫다. 체중에 대한 두 ETA 를 그린다.
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
for (e in c("ETA1", "ETA2")) {
  plot(s$WT, s[[e]], pch = 16, col = "#12366999", xlab = "체중 (kg)", ylab = e,
       main = paste(e, if (e == "ETA1") "(CL)" else "(V)"))
  abline(h = 0, lty = 3)
  abline(lm(s[[e]] ~ s$WT), lwd = 1.5)
}
