# Cut the same profile curve again on the likelihood-ratio scale. The end of a
# 1/k likelihood interval is where dOFV = 2 log k. k = 8 (moderate),
# k = 32 (strong).
li <- function(k) t(sapply(split(p, p$PAR), function(z)
  cross(z$VALUE, z$dOFV, lv = 2 * log(k))))
cbind(round(li(8), 4), round(li(32), 4))
c(`dOFV(k=8)` = round(2 * log(8), 3), `dOFV(k=32)` = round(2 * log(32), 3),
  `k at 3.84` = round(exp(qchisq(0.95, 1) / 2), 2))
