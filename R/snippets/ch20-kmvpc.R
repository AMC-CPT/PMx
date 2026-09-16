# Kaplan-Meier VPC. 추정된 모형(tte102)에서 같은 사람들(같은 CAVG, 같은 절단 시각)의
# 사건시각을 200번 모의하고, 군별 KM 곡선의 95 % 띠 위에 관측 KM 을 얹는다.
# 사건시각은 역변환으로 뽑는다: S(t) = U 를 t 에 대해 푼다.
set.seed(20260920)
lam <- r2$f[["THETA1"]]; gam <- r2$f[["THETA2"]]; beta <- r2$f[["THETA3"]]
cens <- ifelse(ev$DV == 0, ev$TIME, 12)                 # 절단은 설계로 둔다
grid <- seq(0, 12, by = 0.25)
kmcurve <- function(t, e, g) { f <- survfit(Surv(t, e) ~ 1, subset = g)
  summary(f, times = grid, extend = TRUE)$surv }
simband <- array(NA, c(200, length(grid), 3))
for (r in 1:200) {
  u <- runif(nrow(ev))
  tev <- (-log(u) / (lam * exp(-beta * ev$CAVG)))^(1 / gam)
  tobs <- pmin(tev, cens); e <- as.integer(tev <= cens)
  for (g in 1:3) simband[r, , g] <- kmcurve(tobs, e, ev$DOSE == c(0, 50, 100)[g])
}
par(mfrow = c(1, 3), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (g in 1:3) {
  q <- apply(simband[, , g], 2, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE)
  plot(grid, q[2, ], type = "n", ylim = c(0, 1), xlab = "개월", ylab = "",
       main = c("위약", "50 mg", "100 mg")[g])
  polygon(c(grid, rev(grid)), c(q[1, ], rev(q[3, ])), col = "#12366933", border = NA)
  lines(grid, q[2, ], col = "#123669", lty = 2)
  lines(kmcurve(ev$TIME, ev$DV, ev$DOSE == c(0, 50, 100)[g]) ~ grid, lwd = 2, col = "#B2182B")
}
mtext("사건 없이 남은 비율", side = 2, outer = TRUE, line = -0.5)
