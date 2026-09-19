# =====================================================================
#  R/mkdata/make_iv2.R  -  7장 2구획 정맥 예제의 모의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_iv2.R
#
#  참값을 알고 만든 자료다. 2구획 정맥 bolus 100 mg, 40명, 0.25 시간부터
#  48 시간까지 11회 채혈. 분포상과 소실상이 뚜렷이 갈리도록(반감기 약 0.9 시간과
#  15 시간) 파라미터를 잡았다. 1구획으로 적합하면 어디가 틀어지고(140iv2),
#  2구획이 맞으며(200iv2), 3구획은 자료가 지지하지 않는다(300iv2)는 것을
#  참값과의 거리로 말하기 위한 자료다.
#
#  모형.  CL = 5 L/h, V1 = 20 L, Q = 8 L/h, V2 = 60 L
#    IIV omega^2: 0.09 (넷 다, 독립, 로그정규)
#    잔차: 비례 10 %, 가법 0.02 mg/L
#  열.  ID TIME AMT DV MDV EVID WT SEX
#    WT 와 SEX 는 표(cotab/catab)를 채우려고 둔 **가짜 공변량**이다. 모형과
#    무관하게 뽑았으므로 공변량 탐색의 예로 쓰면 안 된다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

set.seed(20260919)

TRUE_PAR <- c(CL = 5, V1 = 20, Q = 8, V2 = 60, PROP = 0.10, ADD = 0.02)
OMEGA    <- c(CL = 0.09, V1 = 0.09, Q = 0.09, V2 = 0.09)

n    <- 40
dose <- 100
tobs <- c(0.25, 0.5, 1, 2, 4, 6, 8, 12, 24, 36, 48)

# 2구획 bolus 의 닫힌 해 (3권 7장)
c2iv <- function(t, D, CL, V1, Q, V2) {
  k10 <- CL / V1; k12 <- Q / V1; k21 <- Q / V2
  s <- k10 + k12 + k21; p <- k10 * k21
  a <- (s + sqrt(s^2 - 4 * p)) / 2
  b <- (s - sqrt(s^2 - 4 * p)) / 2
  A <- D / V1 * (a - k21) / (a - b)
  B <- D / V1 * (k21 - b) / (a - b)
  A * exp(-a * t) + B * exp(-b * t)
}

rows <- list()
for (i in seq_len(n)) {
  eta <- rnorm(4, 0, sqrt(OMEGA))
  p   <- TRUE_PAR[c("CL", "V1", "Q", "V2")] * exp(eta)
  f   <- c2iv(tobs, dose, p[["CL"]], p[["V1"]], p[["Q"]], p[["V2"]])
  y   <- f * (1 + TRUE_PAR[["PROP"]] * rnorm(length(tobs))) +
         TRUE_PAR[["ADD"]] * rnorm(length(tobs))
  wt  <- round(rnorm(1, 70, 12), 1)
  sex <- rbinom(1, 1, 0.5)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = 0, AMT = dose, DV = NA,
      MDV = 1L, EVID = 1L, WT = wt, SEX = sex)
  rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = tobs, AMT = 0,
      DV = round(pmax(y, 0.001), 3), MDV = 0L, EVID = 0L, WT = wt, SEX = sex)
}
d <- do.call(rbind, rows)
rownames(d) <- NULL
write.csv(d, "data/iv2-sim.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iv2-sim.csv: %d 행, %d 명, 관측 %d\n", nrow(d), n, sum(d$MDV == 0)))

write.csv(data.frame(name = c(names(TRUE_PAR), paste0("OM_", names(OMEGA))),
                     value = c(TRUE_PAR, OMEGA)),
          "data/iv2-sim-truth.csv", row.names = FALSE, quote = FALSE)
