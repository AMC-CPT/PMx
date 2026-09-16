# =====================================================================
#  R/mkdata/make_pd.R  -  16장의 약력학 모의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_pd.R
#
#  참값을 알고 만든 자료다. 그래야 "위약군을 빼면 무엇이 편향되는가"를
#  참값과의 거리로 말할 수 있다(16장). 결과는 data/pd-sim.csv 하나이고,
#  seed 가 박혀 있으므로 같은 파일이 다시 나온다(3장의 규칙).
#
#  설계. 수술 후 통증 NRS(0-10). 진통제 단회 정맥 bolus, 네 군(위약, 40, 80,
#  160 mg), 군당 40명. NRS 는 0, 0.5, 1, 2, 4, 6, 8, 12, 24 시간에, 농도는
#  투여군에서만 0.5, 2, 6, 12 시간에 잰다(희박 채혈). 시각 0 의 NRS 는 투여 전이다.
#
#  모형. 유계 척도이므로 효과는 로짓 척도에서 더하고 마지막에 0-10 으로 되돌린다.
#    PK    C(t)  = DOSE/V * exp(-CL/V * t)                (1구획 정맥 bolus)
#    로짓  L(t)  = LB - PLMAX*(1 - exp(-KPL*t)) - EMAX*C/(EC50 + C)
#    NRS   F(t)  = 10 / (1 + exp(-L))                     (언제나 0 과 10 사이)
#  LB 는 기저치의 로짓이다. logit(7/10) = 0.847.  개체간 변이는 LB, PLMAX, EC50 에.
#  잔차는 유계 척도의 이항 유사 분산: W = sqrt(a^2 + b^2 * F*(10-F))
#  (Analects 15.A). 척도 중앙에서 최대이고 양 끝에서 0 으로 간다.
#
#  열.  ID ARM DOSE TIME DV DVID MDV BSL BFLG
#    DVID 1 = 농도(mg/L), 2 = NRS.   BSL = 그 사람의 시각 0 NRS(obs-baseline 용).
#    BFLG 1 = 시각 0 의 NRS 레코드(obs-baseline 모형에서는 적합에서 뺀다).
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

set.seed(20260917)
RNGkind()

TRUE_PAR <- c(CL = 5, V = 40,                          # PK (L/h, L)
              LB = 0.847, PLMAX = 0.85, KPL = 0.15,    # 기저 로짓, 위약 반응(로짓)
              EMAX = 1.7, EC50 = 1.5,                  # 약효(로짓), EC50 (mg/L)
              A = 0.35, B = 0.14)                      # 잔차 (유계 척도)
OMEGA <- c(CL = 0.09, V = 0.04, LB = 0.10, PLMAX = 0.16, EC50 = 0.25)
expit <- function(x) 1 / (1 + exp(-x))

arms  <- c(0, 40, 80, 160)
nArm  <- 40
tNRS  <- c(0, 0.5, 1, 2, 4, 6, 8, 12, 24)
tPK   <- c(0.5, 2, 6, 12)

rows <- list()
id <- 0
for (dose in arms) for (k in seq_len(nArm)) {
  id  <- id + 1
  eta <- rnorm(5, 0, sqrt(OMEGA))
  CL   <- TRUE_PAR["CL"]   * exp(eta[1])
  V    <- TRUE_PAR["V"]    * exp(eta[2])
  LB   <- TRUE_PAR["LB"]   + eta[3]                    # 로짓에는 더한다
  PLMX <- TRUE_PAR["PLMAX"]* exp(eta[4])
  EC50 <- TRUE_PAR["EC50"] * exp(eta[5])
  conc <- function(t) ifelse(t > 0, dose / V * exp(-CL / V * t), 0)   # 시각 0 은 투여 전
  # NRS
  L  <- LB - PLMX * (1 - exp(-TRUE_PAR["KPL"] * tNRS)) -
        TRUE_PAR["EMAX"] * conc(tNRS) / (EC50 + conc(tNRS))
  f  <- 10 * expit(L)
  w  <- sqrt(TRUE_PAR["A"]^2 + TRUE_PAR["B"]^2 * f * (10 - f))
  y  <- round(pmin(pmax(f + w * rnorm(length(tNRS)), 0), 10), 1)
  rows[[length(rows) + 1]] <- data.frame(ID = id, ARM = match(dose, arms),
      DOSE = dose, TIME = tNRS, DV = y, DVID = 2, MDV = 0,
      BSL = y[1], BFLG = as.integer(tNRS == 0))
  # 농도 (투여군만). 비례 오차 15 %
  if (dose > 0) {
    cp <- conc(tPK) * (1 + 0.15 * rnorm(length(tPK)))
    rows[[length(rows) + 1]] <- data.frame(ID = id, ARM = match(dose, arms),
        DOSE = dose, TIME = tPK, DV = round(pmax(cp, 0.01), 3), DVID = 1, MDV = 0,
        BSL = y[1], BFLG = 0L)
  }
}
d <- do.call(rbind, rows)
d <- d[order(d$ID, d$TIME, d$DVID), ]
rownames(d) <- NULL

dir.create("data", showWarnings = FALSE)
write.csv(d, "data/pd-sim.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/pd-sim.csv: %d 행, %d 명, NRS %d, 농도 %d, NRS 범위 %g-%g\n",
            nrow(d), length(unique(d$ID)), sum(d$DVID == 2), sum(d$DVID == 1),
            min(d$DV[d$DVID == 2]), max(d$DV[d$DVID == 2])))

# 순서형 판. 같은 NRS 를 세 범주로 접는다: 0-3 경도(0), 4-6 중등도(1), 7-10 중증(2).
# 16장의 순서형 로지스틱 예제가 쓴다. 농도 레코드는 뺀다.
o <- d[d$DVID == 2, c("ID", "ARM", "DOSE", "TIME", "DV", "MDV")]
o$DV <- as.integer(cut(o$DV, c(-Inf, 3.5, 6.5, Inf), labels = FALSE)) - 1L
write.csv(o, "data/pd-ord.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/pd-ord.csv: %d 행, 범주 분포 %s\n", nrow(o),
            paste(table(o$DV), collapse = "/")))

# 참값도 곁에 둔다. 16장의 표가 이것과 대조한다.
write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/pd-sim-truth.csv", row.names = FALSE, quote = FALSE)
