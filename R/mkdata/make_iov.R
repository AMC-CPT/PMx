# =====================================================================
#  R/mkdata/make_iov.R  -  변동성 구조 장의 모의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_iov.R
#
#  참값을 알고 만든 자료다. 개체간 변이(IIV) 위에 **투여회차간 변이(IOV)** 를
#  얹고, 청소율이 낮은 **아집단**(대사 저하자 20 %)을 섞었다. 그래야 IOV 를
#  무시하면 무엇이 부풀고, $MIX 가 아집단을 얼마나 되찾는지를 참값과의
#  거리로 말할 수 있다. 결과는 data/iov-sim.csv 하나이고 seed 가 박혀 있다.
#
#  설계. 1구획 경구 흡수. 100 mg 을 0, 168, 336 시간(1, 8, 15일)에 한 번씩,
#  세 회차(OCC 1-3). 회차마다 0.5, 1, 2, 4, 8, 12, 24 시간에 채혈. 60명.
#
#  모형.
#    KA = 1.0 /h, CL = 4.0 L/h (대사 정상), 1.2 L/h (대사 저하, 30 %), V = 50 L
#    IIV  omega^2: KA 0.16, CL 0.09, V 0.04            (로그정규)
#    IOV  pi^2:    CL 0.04, KA 0.09                    (회차마다 새로 뽑는다)
#    잔차:  비례 12 %, 가법 0.05 mg/L
#
#  열.  ID TIME AMT DV MDV EVID OCC POP
#    OCC 1-3 = 투여 회차.  POP 1 = 대사 정상, 2 = 대사 저하 (참값. 모형은 모른다).
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

set.seed(20260918)

TRUE_PAR <- c(KA = 1.0, CL = 4.0, FPM = 0.3, V = 50, PPM = 0.2,
              PROP = 0.12, ADD = 0.05)
OMEGA <- c(KA = 0.16, CL = 0.09, V = 0.04)
PI    <- c(CL = 0.04, KA = 0.09)

n     <- 60
tdose <- c(0, 168, 336)
tobs  <- c(0.5, 1, 2, 4, 8, 12, 24)
dose  <- 100

pop  <- rbinom(n, 1, TRUE_PAR["PPM"]) + 1L          # 1 = 정상, 2 = 저하
rows <- list()
for (i in seq_len(n)) {
  eta <- rnorm(3, 0, sqrt(OMEGA))
  ka  <- TRUE_PAR["KA"] * exp(eta[1])
  cl  <- TRUE_PAR["CL"] * ifelse(pop[i] == 2, TRUE_PAR["FPM"], 1) * exp(eta[2])
  v   <- TRUE_PAR["V"]  * exp(eta[3])
  for (k in seq_along(tdose)) {
    kap <- rnorm(2, 0, sqrt(PI))                      # 회차 효과
    kao <- ka * exp(kap[2]); clo <- cl * exp(kap[1])
    ke  <- clo / v
    f   <- dose * kao / (v * (kao - ke)) * (exp(-ke * tobs) - exp(-kao * tobs))
    y   <- f * (1 + TRUE_PAR["PROP"] * rnorm(length(tobs))) +
           TRUE_PAR["ADD"] * rnorm(length(tobs))
    rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tdose[k], AMT = dose,
        DV = NA, MDV = 1L, EVID = 1L, OCC = k, POP = pop[i])
    rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tdose[k] + tobs, AMT = 0,
        DV = round(pmax(y, 0.01), 3), MDV = 0L, EVID = 0L, OCC = k, POP = pop[i])
  }
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, -d$EVID), ]
rownames(d) <- NULL
write.csv(d, "data/iov-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iov-sim.csv: %d 행, %d 명, 관측 %d, 대사 저하 %d 명\n",
            nrow(d), n, sum(d$MDV == 0), sum(pop == 2)))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA)),
                              paste0("PI_", names(PI))),
                     value = c(TRUE_PAR, OMEGA, PI)),
          "data/iov-sim-truth.csv", row.names = FALSE, quote = FALSE)
