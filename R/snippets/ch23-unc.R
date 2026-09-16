# 위 표는 추정치를 참값으로 두고 만든 것이다. 추정치의 불확실성을 얹으려면
# 재표집 200벌(14장)의 파라미터마다 같은 계산을 되풀이한다.
b  <- read.csv("nm/boot/boot.csv")
b  <- b[b$TERM %in% c("SUCCESS", "ROUNDING"), ]
# 재표집 가운데 OMEGA 가 양의 정부호가 아닌 벌은 뽑을 수 없다. 몇 벌인지 센다.
ok <- b$O11 > 0 & b$O22 > 0 & b$O11 * b$O22 - b$O21^2 > 0
c(쓴벌 = sum(ok), 뺀벌 = sum(!ok))
b  <- b[ok, ]
pta_boot <- sapply(seq_len(nrow(b)), function(r) {
  th <<- unlist(b[r, paste0("T", 1:6)])
  Om <<- matrix(unlist(b[r, c("O11", "O21", "O21", "O22")]), 2)
  ct <- trough72(wt, 2.5, MASS::mvrnorm(n, c(0, 0), Om))
  tapply(ct >= 15 & ct <= 30, bin, mean)
})
# 구간마다 목표 달성률의 중앙값과 90 % 구간. 점추정 한 줄이 띠가 된다.
out <- t(apply(100 * pta_boot, 1, quantile, c(0.05, 0.5, 0.95)))
colnames(out) <- c("5 %", "중앙", "95 %")
round(out, 1)
