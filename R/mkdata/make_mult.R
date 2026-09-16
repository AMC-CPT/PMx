# =====================================================================
#  R/mkdata/make_mult.R  -  7장 셋째 예제: 반복 경구 투여 자료를 세 가지 코딩으로 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_mult.R
#
#  참값을 아는 모의 자료다. 30명, 100 mg 을 12시간마다 14회(7일). 채혈은
#  3, 7, 11번째 투약 직전의 trough 셋과 14번째 투약 뒤의 전체 프로파일
#  (0.5, 1, 2, 4, 8, 12 h).
#
#  모형(참값). 1구획 1차 흡수. KA 1.2 /h, CL 4 L/h, V 50 L (반감기 8.7 h).
#    IIV omega^2: KA 0.16, CL 0.09, V 0.04.  잔차 비례 12 %, 가법 0.05 mg/L.
#
#  같은 관측을 세 데이터셋으로 적는다.
#    mult-explicit.csv  투약 레코드 14개를 전부 적는다
#    mult-addl.csv      첫 투약 하나에 ADDL=13 II=12 로 접는다 (답이 같아야 한다)
#    mult-ss.csv        14번째 투약만 SS=1 II=12 로 적고 프로파일만 남긴다
#    mult-ssx.csv       함정. 투약이 3회뿐인데(정상상태 전) SS=1 로 적은 것
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
set.seed(20260922)

TRUE_PAR <- c(KA = 1.2, CL = 4, V = 50, PROP = 0.12, ADD = 0.05)
OMEGA <- c(KA = 0.16, CL = 0.09, V = 0.04)
n <- 30; dose <- 100; ii <- 12; ndose <- 14
tprof <- c(0.5, 1, 2, 4, 8, 12)
ttrough <- (c(3, 7, 11) - 1) * ii                 # 3, 7, 11번째 투약 직전

# 반복 투여의 닫힌 해 (중첩 원리)
conc <- function(t, ka, cl, v, tdose) {
  ke <- cl / v
  sapply(t, function(tt) { td <- tdose[tdose <= tt]
    sum(dose * ka / (v * (ka - ke)) * (exp(-ke * (tt - td)) - exp(-ka * (tt - td)))) })
}

ex <- list(); ad <- list(); ss <- list(); sx <- list()
for (i in seq_len(n)) {
  eta <- rnorm(3, 0, sqrt(OMEGA))
  ka <- TRUE_PAR["KA"] * exp(eta[1]); cl <- TRUE_PAR["CL"] * exp(eta[2]); v <- TRUE_PAR["V"] * exp(eta[3])
  tdose <- (0:(ndose - 1)) * ii
  tobs <- c(ttrough, (ndose - 1) * ii + tprof)
  f <- conc(tobs, ka, cl, v, tdose)
  y <- round(pmax(f * (1 + TRUE_PAR["PROP"] * rnorm(length(f))) + TRUE_PAR["ADD"] * rnorm(length(f)), 0.01), 3)
  obs <- data.frame(ID = i, TIME = tobs, AMT = 0, ADDL = 0, II = 0, SS = 0, DV = y, MDV = 0L, EVID = 0L)
  # (1) 투약 전부
  d1 <- data.frame(ID = i, TIME = tdose, AMT = dose, ADDL = 0, II = 0, SS = 0, DV = NA, MDV = 1L, EVID = 1L)
  ex[[i]] <- rbind(d1, obs)
  # (2) ADDL 로 접는다
  d2 <- data.frame(ID = i, TIME = 0, AMT = dose, ADDL = ndose - 1, II = ii, SS = 0, DV = NA, MDV = 1L, EVID = 1L)
  ad[[i]] <- rbind(d2, obs)
  # (3) 정상상태 투약 하나와 프로파일만. 시각은 그 투약 기준 0 으로 옮긴다
  d3 <- data.frame(ID = i, TIME = 0, AMT = dose, ADDL = 0, II = ii, SS = 1, DV = NA, MDV = 1L, EVID = 1L)
  o3 <- obs[obs$TIME > (ndose - 1) * ii, ]; o3$TIME <- o3$TIME - (ndose - 1) * ii
  ss[[i]] <- rbind(d3, o3)
  # (4) 함정: 3회 투약 뒤의 프로파일(정상상태 전)을 SS=1 로 적는다
  tdose3 <- (0:2) * ii
  f3 <- conc(2 * ii + tprof, ka, cl, v, tdose3)
  y3 <- round(pmax(f3 * (1 + TRUE_PAR["PROP"] * rnorm(length(f3))) + TRUE_PAR["ADD"] * rnorm(length(f3)), 0.01), 3)
  o4 <- data.frame(ID = i, TIME = tprof, AMT = 0, ADDL = 0, II = 0, SS = 0, DV = y3, MDV = 0L, EVID = 0L)
  sx[[i]] <- rbind(d3, o4)
}
wr <- function(l, f) { d <- do.call(rbind, l); d <- d[order(d$ID, d$TIME, -d$EVID), ]
  rownames(d) <- NULL; write.csv(d, f, row.names = FALSE, quote = FALSE, na = "."); nrow(d) }
cat(sprintf("mult-explicit %d 행, mult-addl %d 행, mult-ss %d 행, mult-ssx %d 행\n",
            wr(ex, "data/mult-explicit.csv"), wr(ad, "data/mult-addl.csv"),
            wr(ss, "data/mult-ss.csv"), wr(sx, "data/mult-ssx.csv")))
write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))), value = c(TRUE_PAR, OMEGA)),
          "data/mult-truth.csv", row.names = FALSE, quote = FALSE)
