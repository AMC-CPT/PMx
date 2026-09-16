# 관측된 횟수의 분포와 두 모형의 예측 분포. 각 모형의 추정치로 같은 사람들을
# 200번 모의해 횟수별 비율의 평균을 낸다. Poisson 은 0 과 큰 값을 둘 다 적게 만든다.
set.seed(20260920)
simcnt <- function(r, nb) {
  th <- r$f; om <- th[["OMEGA.1.1."]]
  out <- matrix(0, 200, 31)
  for (k in 1:200) {
    lam0 <- th[["THETA1"]] * exp(rnorm(200, 0, sqrt(om)))[cn$ID]
    lam  <- lam0 * (1 - th[["THETA2"]] * cn$CAVG / (th[["THETA3"]] + cn$CAVG))
    y <- if (nb) rnbinom(nrow(cn), size = 1 / th[["THETA4"]], mu = lam) else rpois(nrow(cn), lam)
    out[k, ] <- tabulate(pmin(y, 30) + 1, 31) / nrow(cn)
  }
  colMeans(out)
}
o <- tabulate(pmin(cn$DV, 30) + 1, 31) / nrow(cn)
par(mar = c(4, 4, 1, 1))
plot(0:30, o, type = "h", lwd = 6, col = "#12366955", xlab = "28일 발작 횟수", ylab = "비율",
     ylim = c(0, 0.15))
lines(0:30, simcnt(c0, FALSE), type = "b", pch = 1, col = "grey40")
lines(0:30, simcnt(c1, TRUE), type = "b", pch = 16, col = "#B2182B")
legend("topright", c("관측", "Poisson", "음이항"), col = c("#12366955", "grey40", "#B2182B"),
       lwd = c(6, 1, 1), pch = c(NA, 1, 16), bty = "n")
