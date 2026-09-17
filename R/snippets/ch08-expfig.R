# FO 와 FOCE 가 어디서 펴는지를 한 대상자로 본다. theophylline 의 110ka(7장)에서
# 흡수속도가 대표값에서 가장 먼 사람을 고르고, 다른 두 eta 는 0 에 둔 단면이다.
ex <- read.table(nmf("110ka", "110ka.ext"), skip = 1, header = TRUE)
th <- unlist(ex[ex$ITERATION == -1000000000, paste0("THETA", 1:5)])
om <- ex[ex$ITERATION == -1000000000, "OMEGA.1.1."]
pa <- read.table(nmf("110ka", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
st <- read.table(nmf("110ka", "sdtab"), skip = 1, header = TRUE)
id <- pa$ID[which.min(pa$ETA1)]
d  <- st[st$ID == id, ]
dose <- d$AMT[d$EVID == 1][1]
tt <- d$TIME[d$MDV == 0]; yy <- d$DV[d$MDV == 0]
c(대상자 = id, EBE = round(pa$ETA1[pa$ID == id], 3), 관측 = length(yy))

F <- function(eta) {                          # 1구획 경구 모형의 닫힌 해
  ka <- th[1] * exp(eta); k <- th[2] / th[3]
  dose / th[3] * ka / (ka - k) * (exp(-k * tt) - exp(-ka * tt))
}
q <- function(eta) {                          # 개인 -2 log 가능도의 핵 (8.3절의 q_i)
  f <- F(eta); v <- th[4]^2 + th[5]^2 * f^2
  sum(log(v) + (yy - f)^2 / v) + eta^2 / om
}
# FO: eta = 0 에서 F 를 선형화하고 잔차 분산도 거기서 잰다. eta 의 이차식이 된다.
h <- 1e-4; f0 <- F(0); g0 <- (F(h) - F(-h)) / (2 * h)
v0 <- th[4]^2 + th[5]^2 * f0^2
qFO <- function(eta) sum(log(v0) + (yy - f0 - g0 * eta)^2 / v0) + eta^2 / om
# FOCE-I 와 Laplacian: 최빈값을 찾고 거기서 이차식으로 편다.
mode <- optimize(q, c(-4, 2))$minimum
curv <- (q(mode + h) - 2 * q(mode) + q(mode - h)) / h^2
qLP  <- function(eta) q(mode) + 0.5 * curv * (eta - mode)^2

# 세 곡선을 적분하면 세 방법이 이 사람에게 주는 -2 log 가능도가 된다.
L <- function(fun) integrate(function(x) exp(-sapply(x, fun) / 2), -8, 4)$value
c(최빈값 = round(mode, 3), round(-2 * log(c(정확 = L(q), FO = L(qFO), Laplace = L(qLP))), 2))

eta <- seq(-2.5, 1, length.out = 301)
qe  <- sapply(eta, q); qf <- sapply(eta, qFO); ql <- sapply(eta, qLP)
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(eta, qe, type = "l", lwd = 2.5, ylim = c(min(qe), min(qe) + 12),
     xlab = expression(eta[1]), ylab = expression(q[i](eta[1])), main = "펴는 자리")
lines(eta, qf, lty = 2, lwd = 1.5, col = "#9C3B2E")
lines(eta, ql, lty = 3, lwd = 1.5, col = "#123669")
abline(v = c(0, mode), col = "grey60")
plot(eta, exp(-qe / 2), type = "l", lwd = 2.5, xlab = expression(eta[1]),
     ylab = "exp(-q/2)", main = "적분되는 것")
lines(eta, exp(-qf / 2), lty = 2, lwd = 1.5, col = "#9C3B2E")
lines(eta, exp(-ql / 2), lty = 3, lwd = 1.5, col = "#123669")
abline(v = c(0, mode), col = "grey60")
legend("topright", c("이 단면의 정확한 값", "FO: 0 에서 편 이차식", "Laplace: 최빈값에서"),
       lty = 1:3, lwd = c(2.5, 1.5, 1.5), col = c("black", "#9C3B2E", "#123669"),
       bty = "n", cex = 0.72)
