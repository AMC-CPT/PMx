# 최종 모형(108wt)으로 가상 신생아 집단에 투약해 본다. NONMEM 은 필요 없다.
# 1구획 정맥 bolus 의 농도는 투약마다의 지수 항을 더한 것이다(중첩 원리).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
e   <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
th  <- unlist(e[e$ITERATION == -1000000000, paste0("THETA", 1:6)])
Om  <- matrix(unlist(e[e$ITERATION == -1000000000,
                       c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")]), 2)

conc <- function(t, doses, tdose, CL, V) {          # t 시각의 농도
  k <- CL / V
  sapply(t, function(tt) sum(doses[tdose <= tt] / V * exp(-k * (tt - tdose[tdose <= tt]))))
}
# 요법: 부하 20 mg/kg, 유지 M mg/kg 를 12시간마다. 72시간의 최저 농도를 본다.
trough72 <- function(wt, M, eta) {
  CL <- th[1] * (wt / 1.5)^th[5] * exp(eta[, 1])
  V  <- th[2] * (wt / 1.5)^th[6] * exp(eta[, 2])
  td <- seq(0, 60, by = 12)
  sapply(seq_along(wt), function(i)
    conc(72, c(20, rep(M, 5)) * wt[i], td, CL[i], V[i]))
}
set.seed(20260917)
n   <- 2000
wt  <- runif(n, 0.6, 3.6)                              # 자료의 체중 범위
eta <- MASS::mvrnorm(n, c(0, 0), Om)
bin <- cut(wt, c(0.6, 1.0, 1.5, 2.5, 3.6), include.lowest = TRUE)
pta <- sapply(c(2, 2.5, 3, 4), function(M) {
  ct <- trough72(wt, M, eta)
  tapply(ct >= 15 & ct <= 30, bin, mean)
})
colnames(pta) <- paste0(c(2, 2.5, 3, 4), " mg/kg")
round(100 * pta, 1)                                    # 목표 15-30 mg/L 안에 드는 비율 (%)
