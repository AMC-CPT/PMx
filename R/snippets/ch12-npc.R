# NPC 는 VPC 의 수치판이다. 그림 대신 **덮는 비율**을 센다.
# 모의 분포의 90 % 예측구간 안에 관측이 몇 %나 들어오는가. 90 이면 좋다.
cover <- function(p) {
  lo <- (1 - p) / 2; hi <- 1 - lo
  q <- t(sapply(seq_len(nrow(obs)), function(i) {
    v <- sim$DV[sim$ID == obs$ID[i] & sim$TIME == obs$TIME[i]]
    quantile(v, c(lo, hi))
  }))
  inside <- obs$DV >= q[, 1] & obs$DV <= q[, 2]
  c(기대 = 100 * p, 실제 = round(100 * mean(inside), 1),
    아래 = round(100 * mean(obs$DV < q[, 1]), 1),
    위   = round(100 * mean(obs$DV > q[, 2]), 1))
}
t(sapply(c(0.5, 0.8, 0.9, 0.95), cover))
