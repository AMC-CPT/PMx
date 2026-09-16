# 공개 저장소용 TMDD 모의 자료. 18장 둘째 예제의 원숭이 자료는 실무 자료라 공개 저장소에
# 싣지 않는다. 대신 최종 모형 tm103 의 추정치로 같은 설계(용량 여섯, 마리 수, 채혈
# 시각, 정량한계)를 모의한 이 자료를 같은 이름 data/tmdd-mab.csv 로 둔다. 책의 숫자는
# 원자료에서 나온 것이므로 이 자료로 다시 돌리면 비슷하되 같지는 않다.
library(deSolve); set.seed(2026)
th <- c(CLkg = 0.000205, V1kg = 0.0316, Q = 0.00300, V2 = 0.0141, KON = 0.305, KOFF = 0.00171,
        KINT = 0.0133, KDEG = 0.147, ADD = 0.0147, PROP = 0.0705, KSYNkg = 0.0182)
om1 <- matrix(c(0.205, -0.0076, -0.302, -0.0076, 0.0205, 0.193, -0.302, 0.193, 5.65), 3)  # CL V1 V2
om2 <- matrix(c(0.101, 0.212, 0.212, 0.782), 2)                                            # KSYN KDEG
design <- list(`0.3` = list(n = 10, t = c(0.0833, 0.5, 1, 2, 4, 6, 24, 72)),
               `1`   = list(n = 14, t = c(0.0833, 0.5, 1, 2, 4, 6, 24, 72, 120, 144)),
               `3`   = list(n = 14, t = c(0.0833, 0.5, 1, 2, 4, 6, 24, 72, 120, 144)),
               `5`   = list(n = 4,  t = c(0.5, 1, 4, 24, 72)),
               `10`  = list(n = 4,  t = c(0.5, 1, 4, 24, 72)),
               `20`  = list(n = 4,  t = c(0.5, 1, 4, 24, 72)))
LLOQ <- 0.03
tmdd <- function(t, A, p) with(as.list(p), list(c(
  -(K + K12) * A[1] + K21 * A[2] - KON * A[1] * A[3] + KOFF * A[4],
  K12 * A[1] - K21 * A[2],
  KSYN - KDEG * A[3] - KON * A[1] * A[3] + KOFF * A[4],
  KON * A[1] * A[3] - (KOFF + KINT) * A[4])))
out <- NULL; id <- 0
for (lv in names(design)) for (i in seq_len(design[[lv]]$n)) {
  id <- id + 1; dose <- as.numeric(lv)
  bwt <- round(rnorm(1, 3.5, 0.6), 1); bwt <- min(max(bwt, 2.5), 4.6)
  e1 <- MASS::mvrnorm(1, rep(0, 3), om1); e2 <- MASS::mvrnorm(1, rep(0, 2), om2)
  cl <- th[["CLkg"]] * bwt * exp(e1[1]); v1 <- th[["V1kg"]] * bwt * exp(e1[2])
  v2 <- th[["V2"]] * exp(e1[3]); ksyn <- th[["KSYNkg"]] * bwt * exp(e2[1]); kdeg <- th[["KDEG"]] * exp(e2[2])
  p <- c(K = cl / v1, K12 = th[["Q"]] / v1, K21 = th[["Q"]] / v2, KON = th[["KON"]], KOFF = th[["KOFF"]],
         KINT = th[["KINT"]], KSYN = ksyn, KDEG = kdeg)
  amt <- round(dose * bwt, 2); tt <- design[[lv]]$t
  o <- ode(c(amt, 0, ksyn / kdeg, 0), c(0, tt), tmdd, p, rtol = 1e-8, atol = 1e-10)
  ipred <- o[-1, 2] / v1
  w <- sqrt(th[["ADD"]]^2 + th[["PROP"]]^2 * ipred^2)
  dv <- ipred + w * rnorm(length(tt)); dv <- signif(pmax(dv, LLOQ / 2), 4)
  keep <- dv >= LLOQ                                    # 정량한계 아래는 원자료처럼 뺀다
  out <- rbind(out, data.frame(ID = id, LVL = dose, SEX = id %% 2, BWT = bwt, TIME = 0, AMT = amt, DV = 0, MDV = 1),
               data.frame(ID = id, LVL = dose, SEX = id %% 2, BWT = bwt, TIME = tt[keep], AMT = 0, DV = dv[keep], MDV = 0))
}
write.csv(out, "data/tmdd-mab-sim.csv", row.names = FALSE, quote = FALSE)
message("data/tmdd-mab-sim.csv: ", nrow(out), " 행, ", id, " 마리, 관측 ", sum(out$MDV == 0))
