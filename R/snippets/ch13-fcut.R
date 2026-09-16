# 세 문턱을 한자리에. 카이제곱(n 무한대), 9장의 F 문턱(대상자 59명, 자유도 2),
# 그리고 순열이 준 95 백분위수.
n <- 59; q <- 2
fcut <- n * log(1 + q * qf(0.95, q, n - q) / (n - q))     # Hotelling T^2 의 F 분포에서
c(카이제곱 = round(qchisq(0.95, q), 2), F문턱 = round(fcut, 2),
  순열95 = round(unname(quantile(null, 0.95)), 2))
