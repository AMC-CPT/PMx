# 세 위험함수 모형. 상수 위험(tte100), Weibull(tte101), Weibull 에 노출 효과(tte102).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
r0 <- fin("tte100"); r1 <- fin("tte101"); r2 <- fin("tte102")
rse <- function(r, k) round(100 * r$s[[k]] / abs(r$f[[k]]), 1)
data.frame(
  모형 = c("상수, 용량", "Weibull, 용량", "Weibull, 노출"),
  OFV = round(c(r0$f[["OBJ"]], r1$f[["OBJ"]], r2$f[["OBJ"]]), 2),
  LAM = signif(c(r0$f[["THETA1"]], r1$f[["THETA1"]], r2$f[["THETA1"]]), 3),
  GAM = c(NA, signif(r1$f[["THETA2"]], 3), signif(r2$f[["THETA2"]], 3)),
  BETA = signif(c(r0$f[["THETA2"]], r1$f[["THETA3"]], r2$f[["THETA3"]]), 3),
  RSE_BETA = c(rse(r0, "THETA2"), rse(r1, "THETA3"), rse(r2, "THETA3")))
# 참값: GAM 1.4, LAM 0.056, BETA 1.2 (mg/L 당). 용량 모형의 BETA 는 100 mg 당이다.
c(참값_LAM = round(truth[["TTE_LAM"]], 4), 참값_GAM = truth[["TTE_GAM"]], 참값_BETA = truth[["TTE_BETA"]])
# 노출 모형의 위험비. 100 mg 군의 평균 CAVG 0.83 mg/L 에서.
hr <- exp(-r2$f[["THETA3"]] * c(0.42, 0.83)); names(hr) <- c("50 mg", "100 mg")
round(hr, 2)
