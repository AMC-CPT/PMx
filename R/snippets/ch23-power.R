# 임상시험 시뮬레이션의 가장 단순한 꼴. 16장의 약력학 모형(참값)으로 시험을
# 500번 돌려, 4시간의 NRS 가 위약군과 80 mg 군에서 다르다고 판정할 확률을 본다.
tr <- read.csv("data/pd-sim-truth.csv"); p <- setNames(tr$value, tr$name)
one_trial <- function(n, dose = 80, t = 4) {
  eta  <- sapply(c("OM_CL", "OM_V", "OM_LB", "OM_PLMAX", "OM_EC50"),
                 function(v) rnorm(2 * n, 0, sqrt(p[v])))
  d    <- rep(c(0, dose), each = n)
  conc <- d / (p["V"] * exp(eta[, 2])) * exp(-p["CL"] / p["V"] * exp(eta[, 1] - eta[, 2]) * t)
  L    <- p["LB"] + eta[, 3] - p["PLMAX"] * exp(eta[, 4]) * (1 - exp(-p["KPL"] * t)) -
          p["EMAX"] * conc / (p["EC50"] * exp(eta[, 5]) + conc)
  f    <- 10 / (1 + exp(-L))                        # 16장의 로짓 연결
  y    <- f + sqrt(p["A"]^2 + p["B"]^2 * f * (10 - f)) * rnorm(2 * n)
  t.test(y[d == 0], y[d > 0])$p.value < 0.05
}
set.seed(20260917)
power <- sapply(c(5, 10, 15, 20, 30), function(n) mean(replicate(500, one_trial(n))))
round(setNames(power, paste0("n=", c(5, 10, 15, 20, 30))), 2)
