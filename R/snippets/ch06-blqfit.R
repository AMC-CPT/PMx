# 세 방법을 같은 자료(data/iov-blq.csv, LLOQ 0.5 mg/L)에 돌린 결과를
# 자르지 않은 자료의 적합(120base)과 견준다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
runs <- c(자르지않음 = "120base", M1 = "120m1", M5 = "120m5", M3 = "120m3")
par  <- c(KA = "THETA1", CL = "THETA2", V = "THETA3", 가법 = "THETA4", 비례 = "THETA5",
          om.KA = "OMEGA.1.1.", om.CL = "OMEGA.2.2.", om.V = "OMEGA.3.3.")
est <- sapply(runs, function(m) fin(m)[par])
rownames(est) <- names(par)
round(est, 3)

round(est[, -1] / est[, 1], 2)     # 자르지 않은 적합에 대한 비. 1 이면 같다
