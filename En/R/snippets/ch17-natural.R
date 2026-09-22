# The natural-scale model (pd100x) and the logit model (pd100). They have the
# same number of parameters, so the OFVs compare directly.
x <- fin("pd100x")
c(natural = round(x$f[["OBJ"]], 2), logit = round(r$f[["OBJ"]], 2),
  difference = round(x$f[["OBJ"]] - r$f[["OBJ"]], 2))
# How far down does the natural-scale typical curve go? The typical NRS of the
# 160 mg arm. Even without EBEs, the typical values alone put the two models in
# different places.
nat <- function(t, d) { C <- if (t > 0) d / x$f["THETA2"] * exp(-x$f["THETA1"] / x$f["THETA2"] * t) else 0
  x$f["THETA3"] - x$f["THETA4"] * (1 - exp(-x$f["THETA5"] * t)) -
  x$f["THETA6"] * C / (x$f["THETA7"] + C) }
lgt <- function(t, d) { C <- if (t > 0) d / r$f["THETA2"] * exp(-r$f["THETA1"] / r$f["THETA2"] * t) else 0
  L <- r$f["THETA3"] - r$f["THETA4"] * (1 - exp(-r$f["THETA5"] * t)) -
       r$f["THETA6"] * C / (r$f["THETA7"] + C); 10 / (1 + exp(-L)) }
out <- rbind(natural = sapply(c(0, 2, 12, 24), nat, d = 160),
             logit = sapply(c(0, 2, 12, 24), lgt, d = 160))
colnames(out) <- paste0(c(0, 2, 12, 24), "h"); round(out, 2)
