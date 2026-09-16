# 추정된 위험함수. 상수 모형은 평평하고 Weibull 은 시간에 따라 오른다(GAM > 1).
# 오른쪽은 노출에 따른 위험비. 100 mg 군 안에서도 청소율이 다르면 노출이 다르다.
tt <- seq(0.01, 12, length.out = 200)
h0 <- rep(r0$f[["THETA1"]], length(tt))
h1 <- r1$f[["THETA1"]] * r1$f[["THETA2"]] * tt^(r1$f[["THETA2"]] - 1)
ht <- truth[["TTE_LAM"]] * truth[["TTE_GAM"]] * tt^(truth[["TTE_GAM"]] - 1)
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(tt, h1, type = "l", lwd = 2, col = "#123669", ylim = c(0, 0.3), xlab = "개월",
     ylab = "위약군 위험 (1/개월)", main = "기저 위험함수")
lines(tt, h0, lwd = 2, col = "grey50", lty = 2); lines(tt, ht, lwd = 1, col = "#B2182B", lty = 3)
legend("topleft", c("Weibull", "상수", "참값"), col = c("#123669", "grey50", "#B2182B"),
       lty = c(1, 2, 3), lwd = c(2, 2, 1), bty = "n", cex = 0.85)
cav <- seq(0, 1.5, length.out = 100)
plot(cav, exp(-r2$f[["THETA3"]] * cav), type = "l", lwd = 2, col = "#123669", ylim = c(0, 1),
     xlab = "CAVG (mg/L)", ylab = "위험비", main = "노출-위험")
lines(cav, exp(-truth[["TTE_BETA"]] * cav), col = "#B2182B", lty = 3)
rug(ev$CAVG[ev$DOSE > 0], col = "#12366955")
