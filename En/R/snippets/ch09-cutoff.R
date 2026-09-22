# The likelihood ratio threshold on 1 df. 3.84 is the value as n goes to
# infinity. For the mean of a normal distribution with unknown variance the
# exact statistic follows F(1, n-1), and the threshold on -2 log(likelihood
# ratio) is then n * log(1 + F_0.95 / (n-1)).
n     <- c(3, 5, 8, 10, 15, 20, 30, 40, 60, 100, 1000, 1e4)
chisq <- qchisq(0.95, 1)
fcut  <- n * log(1 + qf(0.95, 1, n - 1) / (n - 1))
data.frame(n = n, dOFV = round(fcut, 3), vs.chisq = round(fcut / chisq, 3))
c(chisq = round(chisq, 4), max = round(2 * log(2 / 0.05), 4))    # 2 log(2/alpha)
