# =====================================================================
#  R/mkdata/make_ped.R  -  소아 외삽 장의 모의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_ped.R
#
#  참값을 알고 만든 자료다. 9장에서 체중 지수 1.13 이 이론값 0.75 보다 큰 것을
#  "크기 위에 성숙이 겹친 것"으로 읽었다. 이 자료는 그 읽기를 참값으로 확인한다.
#
#  설계. 120명, 정맥 bolus 5 mg/kg, 네 연령군 30명씩.
#    1 신생아(재태연령 포함 PMA 26-44주, 출생 후 0-28일)   채혈 2-3회 (희박)
#    2 영아(1-24개월)                                        채혈 3-4회
#    3 소아(2-12세)                                          채혈 6회
#    4 청소년(12-18세)                                       채혈 6회
#
#  모형(참값).  CL = 6 * (WT/70)^0.75 * MAT(PMA),  V = 40 * (WT/70)
#    MAT = PMA^H / (TM50^H + PMA^H),  TM50 = 55 주, H = 3.4   (Anderson & Holford)
#    IIV omega^2: CL 0.09, V 0.04.   잔차: 비례 10 %, 가법 0.2 mg/L
#
#  열.  ID TIME AMT DV MDV EVID WT PMA AGE GRP
#    PMA 는 주(week), AGE 는 년(year), GRP 1-4 는 위의 연령군.
#  부분 자료: data/ped-neo.csv (신생아 30명), data/ped-old.csv (나머지 90명).
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

set.seed(20260921)

TRUE_PAR <- c(CLSTD = 6, VSTD = 40, EXP_CL = 0.75, EXP_V = 1, TM50 = 55, HILL = 3.4,
              PROP = 0.10, ADD = 0.2)
OMEGA <- c(CL = 0.09, V = 0.04)
mat <- function(pma) pma^TRUE_PAR["HILL"] / (TRUE_PAR["TM50"]^TRUE_PAR["HILL"] + pma^TRUE_PAR["HILL"])

n_grp <- 30
subj <- list()
for (g in 1:4) for (k in seq_len(n_grp)) {
  if (g == 1) {                                     # 신생아
    ga  <- runif(1, 26, 41); pna <- runif(1, 0, 28) # 재태 주, 출생 후 일
    pma <- ga + pna / 7; age <- pna / 365
    wt  <- 3.4 * (ga / 40)^2.8 * exp(rnorm(1, 0, 0.10)) + 0.03 * pna
  } else if (g == 2) {                              # 영아
    mo  <- runif(1, 1, 24); pma <- 40 + mo * 4.35; age <- mo / 12
    wt  <- (3.4 + 6.6 * (1 - exp(-mo / 6)) + 0.2 * mo) * exp(rnorm(1, 0, 0.10))
  } else if (g == 3) {                              # 소아
    age <- runif(1, 2, 12); pma <- 40 + age * 52.18
    wt  <- (8 + 2.2 * age) * exp(rnorm(1, 0, 0.12))
  } else {                                          # 청소년
    age <- runif(1, 12, 18); pma <- 40 + age * 52.18
    wt  <- (40 + 4 * (age - 12)) * exp(rnorm(1, 0, 0.12))
  }
  subj[[length(subj) + 1]] <- data.frame(GRP = g, WT = round(wt, 2),
                                         PMA = round(pma, 1), AGE = round(age, 3))
}
s <- do.call(rbind, subj); s$ID <- seq_len(nrow(s))

tfull <- c(0.5, 1, 2, 4, 8, 12, 24)
rows <- list()
for (i in seq_len(nrow(s))) {
  eta <- rnorm(2, 0, sqrt(OMEGA))
  cl  <- TRUE_PAR["CLSTD"] * (s$WT[i] / 70)^TRUE_PAR["EXP_CL"] * mat(s$PMA[i]) * exp(eta[1])
  v   <- TRUE_PAR["VSTD"]  * (s$WT[i] / 70)^TRUE_PAR["EXP_V"] * exp(eta[2])
  amt <- round(5 * s$WT[i], 2)
  tt  <- switch(s$GRP[i],
                sort(sample(c(1, 6, 12, 24, 48, 72), sample(2:3, 1))),
                sort(sample(c(0.5, 1, 2, 6, 12, 24, 48), sample(3:4, 1))),
                tfull[-4], tfull[-4])
  f   <- amt / v * exp(-cl / v * tt)
  y   <- f * (1 + TRUE_PAR["PROP"] * rnorm(length(tt))) + TRUE_PAR["ADD"] * rnorm(length(tt))
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = 0, AMT = amt, DV = NA, MDV = 1L,
      EVID = 1L, WT = s$WT[i], PMA = s$PMA[i], AGE = s$AGE[i], GRP = s$GRP[i])
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tt, AMT = 0,
      DV = round(pmax(y, 0.05), 3), MDV = 0L, EVID = 0L,
      WT = s$WT[i], PMA = s$PMA[i], AGE = s$AGE[i], GRP = s$GRP[i])
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, -d$EVID), ]
rownames(d) <- NULL
write.csv(d, "data/ped-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
write.csv(d[d$GRP == 1, ], "data/ped-neo.csv", row.names = FALSE, quote = FALSE, na = ".")
write.csv(d[d$GRP != 1, ], "data/ped-old.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/ped-sim.csv: %d 행, %d 명, 관측 %d. 체중 %.2f-%.1f kg, PMA %.0f-%.0f 주\n",
            nrow(d), nrow(s), sum(d$MDV == 0), min(s$WT), max(s$WT), min(s$PMA), max(s$PMA)))
cat(sprintf("신생아 30명의 관측 %d 개 (1인당 %.1f)\n", sum(d$MDV == 0 & d$GRP == 1),
            sum(d$MDV == 0 & d$GRP == 1) / 30))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/ped-sim-truth.csv", row.names = FALSE, quote = FALSE)
