# Simulated data with a treated arm (true value -0.40), fitted with two models.
# tg106: no treatment effect.  tg107: treatment multiplies ALPHA by
# (1 + THETA(5)) from day 7.
fin <- function(m) {
  e <- read.table(file.path("nm", paste0(m, ".R76"), paste0(m, ".ext")),
                  skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
r0 <- fin("tg106"); r1 <- fin("tg107")
c(OFV.no.effect = round(r0$f[["OBJ"]], 2), OFV.effect = round(r1$f[["OBJ"]], 2),
  dOFV = round(r0$f[["OBJ"]] - r1$f[["OBJ"]], 2))
c(estimate = round(r1$f[["THETA5"]], 3),
  RSE = round(100 * r1$s[["THETA5"]] / abs(r1$f[["THETA5"]]), 1),
  truth = -0.40,
  lower = round(r1$f[["THETA5"]] - 1.96 * r1$s[["THETA5"]], 3),
  upper = round(r1$f[["THETA5"]] + 1.96 * r1$s[["THETA5"]], 3))

# The TGI metric: the typical volume ratio T/C at day 21. It states the size of
# the treatment effect as a volume rather than as a growth rate.
a <- r1$f[["THETA1"]]; b <- r1$f[["THETA2"]]; ef <- r1$f[["THETA5"]]
V  <- function(t, aa) exp(aa / b * (1 - exp(-b * t)))
v7 <- V(7, a)
vt <- v7 * exp(a * (1 + ef) / b * (exp(-b * 7) - exp(-b * 21)))
c(control.day21 = round(V(21, a)), treated.day21 = round(vt),
  TC.ratio = round(vt / V(21, a), 2))
