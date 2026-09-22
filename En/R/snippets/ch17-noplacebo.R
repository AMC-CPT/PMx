# The fit without the placebo arm (pd101, 120 subjects) and the fit keeping only
# the 160 mg arm (pd101b, 40 subjects). The same model. Compared against the
# truth and against the fit that included placebo (pd100).
p1 <- fin("pd101"); p2 <- fin("pd101b")
key2 <- c(LB = "THETA3", PLMAX = "THETA4", KPL = "THETA5", EMAX = "THETA6", EC50 = "THETA7",
          OM_PLMAX = "OMEGA.4.4.", OM_EC50 = "OMEGA.5.5.")
rse <- function(z) round(100 * z$s[key2] / abs(z$f[key2]), 1)
data.frame(truth = signif(truth[c("LB", "PLMAX", "KPL", "EMAX", "EC50", "OM_PLMAX", "OM_EC50")], 3),
           with.placebo = signif(r$f[key2], 3), RSE = rse(r),
           treated.only = signif(p1$f[key2], 3), RSE. = rse(p1),
           one.dose.only = signif(p2$f[key2], 3), RSE.. = rse(p2),
           row.names = names(key2))
