# 반복마다 남는 흔적 셋. .ext 의 OFV, .grd 의 gradient, 그리고 인접 반복 사이의
# 변화율로 어림한 유효숫자(모수 넷 가운데 가장 낮은 것). PRINT=5 의 눈금이다.
g <- read.table(nmf("100base", "100base.grd"), skip = 1, header = TRUE)
g <- g[!duplicated(g[, -1]), ]                     # 마지막 줄은 앞줄의 되풀이
gmax <- apply(abs(g[, -1]), 1, max)
sig  <- sapply(2:nrow(it), function(i) {
  a <- unlist(it[i - 1, p]); b <- unlist(it[i, p])
  min(-log10(abs((b - a) / b)))
})
tr <- data.frame(반복 = it$ITERATION, OFV = round(it$OBJ, 2),
                 gradient = signif(gmax, 2), 자리수 = c(NA, round(sig, 2)))
tr

par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(tr$반복, tr$OFV, type = "b", pch = 16, xlab = "반복", ylab = "OFV",
     main = "목적함수")
plot(tr$반복, tr$gradient, type = "b", pch = 16, log = "y", xlab = "반복",
     ylab = "max |gradient|", main = "gradient")
abline(h = 1, lty = 2)
plot(tr$반복, tr$자리수, type = "b", pch = 16, xlab = "반복",
     ylab = "유효숫자 (어림)", main = "유효숫자")
abline(h = 3, lty = 2)
