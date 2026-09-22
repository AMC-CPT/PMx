# The full model (tm103), the QSS approximation (tm102) and Michaelis-Menten
# (tm104). All three ran on the same data with the same FO, so their OFVs can be
# compared. The parameter count is full > QSS > MM.
q <- fin("tm102"); mm <- fin("tm104")
rse <- function(z, k) round(100 * z$s[[k]] / abs(z$f[[k]]), 1)
np <- function(z) sum(z$f[grepl("THETA|OMEGA", names(z$f))] != 0)   # fixed zeros drop out
data.frame(OFV = round(c(r$f[["OBJ"]], q$f[["OBJ"]], mm$f[["OBJ"]]), 1),
           estimated = c(np(r), np(q), np(mm)),
           term = c(term("tm103")[["term"]], term("tm102")[["term"]], term("tm104")[["term"]]),
           sigdig = c(term("tm103")[["sigdig"]], term("tm102")[["sigdig"]], term("tm104")[["sigdig"]]),
           CL_kg = signif(c(r$f[["THETA1"]], q$f[["THETA1"]], mm$f[["THETA1"]]), 3),
           V1_kg = signif(c(r$f[["THETA2"]], q$f[["THETA2"]], mm$f[["THETA2"]]), 3),
           KDEG = c(signif(r$f[["THETA9"]], 3), signif(q$f[["THETA9"]], 3), NA),
           row.names = c("full (tm103)", "QSS (tm102)", "MM (tm104)"))
# What QSS folded up and what the full model unfolds. The premise of the
# approximation is that the complex reaches equilibrium quickly.
c(KSS.mg.from.full = signif((r$f[["THETA6"]] + r$f[["THETA7"]]) / r$f[["THETA5"]], 3),
  KSS.mg.of.QSS = signif(q$f[["THETA5"]], 3), KSS.RSE.of.QSS = rse(q, "THETA5"),
  complex.half.life.h = round(log(2) / (r$f[["THETA6"]] + r$f[["THETA7"]]), 1),
  target.half.life.h = round(log(2) / r$f[["THETA9"]], 1))
