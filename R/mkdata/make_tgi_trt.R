# =====================================================================
#  R/mkdata/make_tgi_trt.R  -  17장의 치료효과 실습 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_tgi_trt.R
#
#  Benzekry 자료는 대조군뿐이다. 치료효과를 넣는 연습을 하려면 참값을 아는
#  치료군이 필요하다. tg102b(Gompertz, 블록)의 추정치를 참값으로 삼아
#  대조군 20마리와 치료군 20마리를 만든다. 치료는 이식 후 7일부터이고,
#  성장률 ALPHA 를 40 % 낮춘다(참값 THETA(5) = -0.4). 채혈 설계는 원자료와 같다.
#  결과: data/tgi-trt.csv (ID TIME DV MDV GRP), GRP 0 대조, 1 치료.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
set.seed(20260917)
RNGkind()

e  <- read.table("nm/tg102b.R76/tg102b.ext", skip = 1, header = TRUE)
f  <- unlist(e[e$ITERATION == -1000000000, -1])
th <- f[paste0("THETA", 1:4)]
Om <- matrix(f[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2)
EFF   <- -0.4                      # 치료군의 ALPHA 배율 - 1
TSTART <- 7                        # 치료 시작일
times <- c(7, 9, 11, 13, 15, 17, 19, 21)

gomp <- function(t, a, b) exp(a / b * (1 - exp(-b * t)))     # V0 = 1
rows <- list()
for (grp in 0:1) for (k in 1:20) {
  id  <- grp * 20 + k
  eta <- MASS::mvrnorm(1, c(0, 0), Om)
  a   <- th[1] * exp(eta[1]); b <- th[2] * exp(eta[2])
  # 치료 전에는 대조군과 같은 곡선. 치료 시작 후에는 성장률이 (1+EFF) 배.
  # 닫힌 식이 없으므로 조각별로 잇는다: 시작 시점의 부피를 새 초기값으로.
  v <- sapply(times, function(t) {
    if (grp == 0 || t <= TSTART) return(gomp(t, a, b))
    v7 <- gomp(TSTART, a, b)
    # Gompertz 의 성장률은 alpha*exp(-beta*t) 로 줄어든다. 치료가 alpha 만 낮춘다.
    v7 * exp(a * (1 + EFF) / b * (exp(-b * TSTART) - exp(-b * t)))
  })
  w  <- sqrt(th[3]^2 + th[4]^2 * v^2)
  y  <- pmax(v + w * rnorm(length(v)), 1)
  rows[[length(rows) + 1]] <- data.frame(ID = id, TIME = times, DV = round(y, 1),
                                         MDV = 0L, GRP = grp)
}
d <- do.call(rbind, rows)
write.csv(d, "data/tgi-trt.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/tgi-trt.csv: %d 행, 대조 %d 치료 %d, 참값 EFF = %.2f\n",
            nrow(d), sum(d$GRP == 0), sum(d$GRP == 1), EFF))
