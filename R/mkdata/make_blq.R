# =====================================================================
#  R/mkdata/make_blq.R  -  6장 BLQ 실전(M1/M3/M5)의 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_blq.R
#
#  참값을 아는 iov-sim.csv(16장, make_iov.R)의 관측을 LLOQ = 0.5 mg/L 에서
#  자른다. 잘린 관측(BLQ = 1)의 DV 에는 LLOQ/2 = 0.25 를 적어 둔다. 그래서
#  같은 파일 하나로 세 방법이 돈다.
#    120m1  IGNORE=(BLQ.EQ.1)        BLQ 를 버린다
#    120m5  그대로 적합              BLQ 를 LLOQ/2 로 대치한 셈이다
#    120m3  F_FLAG=1, Y=PHI(...)     BLQ 를 검열 관측으로 (LAPLACE)
#  자르지 않은 적합은 120base 다. 참값은 iov-sim-truth.csv.
#  난수는 쓰지 않는다(자르기만 한다).
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

LLOQ <- 0.5
d   <- read.csv("data/iov-sim.csv", na.strings = ".")
obs <- d$EVID == 0
d$BLQ <- 0L
d$BLQ[obs & d$DV < LLOQ] <- 1L
d$DV[d$BLQ == 1L] <- LLOQ / 2
write.csv(d, "data/iov-blq.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/iov-blq.csv: %d 행, 관측 %d, BLQ %d (%.1f %%), LLOQ %.2f mg/L\n",
            nrow(d), sum(obs), sum(d$BLQ), 100 * mean(d$BLQ[obs]), LLOQ))
