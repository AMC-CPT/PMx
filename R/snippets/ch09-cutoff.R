# 자유도 1 의 가능도비 검정 문턱. 3.84 는 n 이 무한대일 때의 값이다.
# 분산을 모르는 정규분포의 평균에서는 정확한 통계량이 F(1, n-1) 을 따르고,
# 그때 -2 log(가능도비) 의 문턱은 n * log(1 + F_0.95 / (n-1)) 이다.
n     <- c(3, 5, 8, 10, 15, 20, 30, 40, 60, 100, 1000, 1e4)
chisq <- qchisq(0.95, 1)
fcut  <- n * log(1 + qf(0.95, 1, n - 1) / (n - 1))
data.frame(n = n, dOFV = round(fcut, 3), 카이제곱대비 = round(fcut / chisq, 3))
c(chisq = round(chisq, 4), 최대 = round(2 * log(2 / 0.05), 4))   # 2 log(2/alpha)
