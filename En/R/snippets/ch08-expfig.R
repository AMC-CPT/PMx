# Where FO and FOCE expand, seen through one subject. From 110ka (Ch 7,
# theophylline), take the person whose absorption rate is furthest from the
# typical value; this is the slice with the other two etas held at 0.
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
c(subject = id, EBE = round(pa$ETA1[pa$ID == id], 3), observations = length(yy))

F <- function(eta) {                          # closed form of the 1-compartment oral model
  ka <- th[1] * exp(eta); k <- th[2] / th[3]
  dose / th[3] * ka / (ka - k) * (exp(-k * tt) - exp(-ka * tt))
}
q <- function(eta) {                          # kernel of the individual -2 log likelihood (q_i of Section 8.3)
  f <- F(eta); v <- th[4]^2 + th[5]^2 * f^2
  sum(log(v) + (yy - f)^2 / v) + eta^2 / om
}
# FO: linearize F at eta = 0 and measure the residual variance there too. It
# becomes a quadratic in eta.
h <- 1e-4; f0 <- F(0); g0 <- (F(h) - F(-h)) / (2 * h)
v0 <- th[4]^2 + th[5]^2 * f0^2
qFO <- function(eta) sum(log(v0) + (yy - f0 - g0 * eta)^2 / v0) + eta^2 / om
# FOCE-I and Laplacian: find the mode and expand quadratically there.
mode <- optimize(q, c(-4, 2))$minimum
curv <- (q(mode + h) - 2 * q(mode) + q(mode - h)) / h^2
qLP  <- function(eta) q(mode) + 0.5 * curv * (eta - mode)^2

# Integrating the three curves gives the -2 log likelihood each method assigns
# to this person.
L <- function(fun) integrate(function(x) exp(-sapply(x, fun) / 2), -8, 4)$value
c(mode = round(mode, 3),
  round(-2 * log(c(exact = L(q), FO = L(qFO), Laplace = L(qLP))), 2))

eta <- seq(-2.5, 1, length.out = 301)
qe  <- sapply(eta, q); qf <- sapply(eta, qFO); ql <- sapply(eta, qLP)
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(eta, qe, type = "l", lwd = 2.5, ylim = c(min(qe), min(qe) + 12),
     xlab = expression(eta[1]), ylab = expression(q[i](eta[1])),
     main = "where it is expanded")
lines(eta, qf, lty = 2, lwd = 1.5, col = "#9C3B2E")
lines(eta, ql, lty = 3, lwd = 1.5, col = "#123669")
abline(v = c(0, mode), col = "grey60")
plot(eta, exp(-qe / 2), type = "l", lwd = 2.5, xlab = expression(eta[1]),
     ylab = "exp(-q/2)", main = "what is integrated")
lines(eta, exp(-qf / 2), lty = 2, lwd = 1.5, col = "#9C3B2E")
lines(eta, exp(-ql / 2), lty = 3, lwd = 1.5, col = "#123669")
abline(v = c(0, mode), col = "grey60")
legend("topright", c("exact, on this slice", "FO: quadratic expanded at 0",
                     "Laplace: at the mode"),
       lty = 1:3, lwd = c(2.5, 1.5, 1.5), col = c("black", "#9C3B2E", "#123669"),
       bty = "n", cex = 0.72)
