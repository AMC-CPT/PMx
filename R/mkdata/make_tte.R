# =====================================================================
#  R/mkdata/make_tte.R  -  시간-사건과 카운트 장의 모의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_tte.R
#
#  두 자료를 만든다. 둘 다 참값을 안다.
#
#  (1) data/tte-sim.csv  시간-사건.  300명을 위약, 50, 100 mg 에 100명씩.
#      노출은 정상상태 평균농도 CAVG = DOSE/(CL*24), CL 은 5 L/h 에 CV 30 %.
#      위험함수는 Weibull:  h(t) = LAM*GAM*t^(GAM-1) * exp(-BETA*CAVG)
#        GAM 1.4 (위험이 시간에 따라 는다), 위약의 중앙 사건시각 6개월,
#        BETA 1.2 (CAVG 0.83 mg/L 에서 위험비 0.37). 시간 단위는 월.
#      12개월에 관리 중도절단, 10 % 는 그 전에 무작위로 탈락(중도절단).
#      레코드: 사람마다 시각 0 의 빈 레코드(EVID=2) 하나와 사건/절단 레코드 하나.
#        DV 1 = 사건, 0 = 중도절단.
#
#  (2) data/cnt-sim.csv  카운트.  200명을 같은 세 군에.  28일 구간 여섯 번의
#      발작 횟수.  기저율 LAM0 중앙값 6 회/구간, IIV omega^2 0.6 (CV 약 90 %).
#      약효  LAM = LAM0 * (1 - EMAX*CAVG/(EC50 + CAVG)),  EMAX 0.6, EC50 0.3.
#      과산포: 음이항, 산포 모수 OVDP 0.3 (분산 = LAM + OVDP*LAM^2).
#      Poisson 으로 적합하면 무엇이 틀리는지를 보이기 위해서다.
#
#  열.  tte: ID TIME DV MDV EVID DOSE CAVG      cnt: ID TIME DV MDV DOSE CAVG
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

set.seed(20260920)

## ---- (1) 시간-사건 ---------------------------------------------------
TTE_PAR <- c(GAM = 1.4, MED0 = 6, BETA = 1.2, CL = 5, OMCL = 0.09, PDROP = 0.10)
LAM <- log(2) / TTE_PAR["MED0"]^TTE_PAR["GAM"]         # S(6) = 0.5 (위약)

n    <- 300
dose <- rep(c(0, 50, 100), each = n / 3)
cl   <- TTE_PAR["CL"] * exp(rnorm(n, 0, sqrt(TTE_PAR["OMCL"])))
cavg <- dose / (cl * 24)
# 역변환 표집: S(t) = exp(-LAM*t^GAM*exp(-BETA*CAVG)) = U
u    <- runif(n)
tev  <- (-log(u) / (LAM * exp(-TTE_PAR["BETA"] * cavg)))^(1 / TTE_PAR["GAM"])
tdrop <- ifelse(runif(n) < TTE_PAR["PDROP"], runif(n, 0, 12), 12)
tobs <- pmin(tev, tdrop)
ev   <- as.integer(tev <= tdrop)
d1 <- rbind(data.frame(ID = seq_len(n), TIME = 0, DV = 0, MDV = 1L, EVID = 2L,
                       DOSE = dose, CAVG = round(cavg, 4)),
            data.frame(ID = seq_len(n), TIME = round(tobs, 3), DV = ev, MDV = 0L,
                       EVID = 0L, DOSE = dose, CAVG = round(cavg, 4)))
d1 <- d1[order(d1$ID, d1$TIME), ]
rownames(d1) <- NULL
write.csv(d1, "data/tte-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/tte-sim.csv: %d 명, 사건 %d (위약 %d, 50 mg %d, 100 mg %d), 절단 %d\n",
            n, sum(ev), sum(ev[dose == 0]), sum(ev[dose == 50]), sum(ev[dose == 100]),
            sum(ev == 0)))

## ---- (2) 카운트 ------------------------------------------------------
CNT_PAR <- c(LAM0 = 6, OMLAM = 0.6, EMAX = 0.6, EC50 = 0.3, OVDP = 0.3, CL = 5, OMCL = 0.09)
m     <- 200
dose2 <- rep(c(0, 50, 100), length.out = m)
cl2   <- CNT_PAR["CL"] * exp(rnorm(m, 0, sqrt(CNT_PAR["OMCL"])))
cavg2 <- dose2 / (cl2 * 24)
lam0  <- CNT_PAR["LAM0"] * exp(rnorm(m, 0, sqrt(CNT_PAR["OMLAM"])))
lam   <- lam0 * (1 - CNT_PAR["EMAX"] * cavg2 / (CNT_PAR["EC50"] + cavg2))
rows <- list()
for (i in seq_len(m)) {
  # 음이항 = 감마 혼합 Poisson.  크기 1/OVDP, 평균 lam.
  y <- rnbinom(6, size = 1 / CNT_PAR["OVDP"], mu = lam[i])
  rows[[i]] <- data.frame(ID = i, TIME = 1:6, DV = y, MDV = 0L,
                          DOSE = dose2[i], CAVG = round(cavg2[i], 4))
}
d2 <- do.call(rbind, rows)
rownames(d2) <- NULL
write.csv(d2, "data/cnt-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/cnt-sim.csv: %d 명, %d 행, 평균 횟수 위약 %.1f / 50 mg %.1f / 100 mg %.1f, 최대 %d\n",
            m, nrow(d2), mean(d2$DV[d2$DOSE == 0]), mean(d2$DV[d2$DOSE == 50]),
            mean(d2$DV[d2$DOSE == 100]), max(d2$DV)))

write.csv(data.frame(name = c(paste0("TTE_", names(TTE_PAR)), "TTE_LAM",
                              paste0("CNT_", names(CNT_PAR))),
                     value = c(TTE_PAR, LAM, CNT_PAR)),
          "data/tte-sim-truth.csv", row.names = FALSE, quote = FALSE)
