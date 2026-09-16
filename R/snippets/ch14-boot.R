# 재표집 200벌의 결과다(R/boot.R). 한 줄이 한 벌이고 그 흩어짐이
# 파라미터 불확실성이다.
b <- read.csv("nm/boot/boot.csv")
table(종료 = b$TERM)

# 재표집마다 관측 수도, 뽑힌 사람 수도 다르다. 59명 중 평균 몇 명인가.
c(관측평균 = round(mean(b$NOBS), 1), 최소 = min(b$NOBS), 최대 = max(b$NOBS),
  사람 = round(mean(b$NUNIQ), 1), 기대 = round(59 * (1 - exp(-1)), 1))

# 백분위수 신뢰구간. 정규성도, 대칭도 가정하지 않는다.
pars <- c("T1", "T2", "T3", "T4", "T5", "T6", "O11", "O21", "O22")
ci <- t(sapply(b[pars], quantile, c(0.5, 0.025, 0.975), na.rm = TRUE))
colnames(ci) <- c("중앙", "하한", "상한")
signif(ci, 3)
