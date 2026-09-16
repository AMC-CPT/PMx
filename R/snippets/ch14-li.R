# 같은 프로파일 곡선을 우도비의 눈금으로 다시 자른다. 1/k 우도 구간의 끝은
# dOFV = 2 log k 인 자리다. k = 8 (중등도), k = 32 (강함).
li <- function(k) t(sapply(split(p, p$PAR), function(z)
  cross(z$VALUE, z$dOFV, lv = 2 * log(k))))
cbind(round(li(8), 4), round(li(32), 4))
c(`dOFV(k=8)` = round(2 * log(8), 3), `dOFV(k=32)` = round(2 * log(32), 3),
  `k at 3.84` = round(exp(qchisq(0.95, 1) / 2), 2))
