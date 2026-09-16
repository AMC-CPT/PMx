# 모수 하나를 고정하고 나머지를 다시 추정한 OFV 곡선이다(R/llp.R).
# dOFV 가 3.84 가 되는 자리가 95 % 구간의 끝이다(자유도 1).
p    <- read.csv("nm/llp/llp.csv")
base <- as.numeric(e[e$ITERATION == -1000000000, "OBJ"])
p$dOFV <- p$OFV - base

# 프로파일 OFV 는 전체 최소보다 작을 수 없다. 작으면 깨진 run 이다.
# (최적점 그 자리는 수치 오차로 1e-6 쯤 작게 나오므로 그만큼은 봐 준다.)
table(종료 = p$TERM, 깨짐 = p$dOFV < -0.01)
p <- p[p$dOFV >= -0.01, ]
p$dOFV <- pmax(p$dOFV, 0)

# 바닥의 좌우에서 3.84 를 지나는 자리를 선형보간으로 찾는다.
cross <- function(x, y, lv = qchisq(0.95, 1)) {
  i <- which.min(y)
  c(하한 = approx(y[1:i], x[1:i], lv)$y,
    상한 = approx(y[i:length(y)], x[i:length(y)], lv)$y)
}
llp <- t(sapply(split(p, p$PAR), function(z) cross(z$VALUE, z$dOFV)))
round(llp, 4)

# NA 는 격자 끝까지 가도 3.84 에 닿지 않았다는 뜻이다. 그 끝을 본다.
t(sapply(split(p, p$PAR), function(z)
  c(격자하단 = min(z$VALUE), 거기dOFV = round(z$dOFV[which.min(z$VALUE)], 2))))
