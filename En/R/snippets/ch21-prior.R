# Can a maturation model be built from 30 neonates alone? Without prior
# information (ped103x), and with the estimates of the other 90 subjects
# (ped104) entered as an NWPRI prior (ped103).
px <- fin("ped103x"); pp <- fin("ped103"); po <- fin("ped104")
key <- c(CLSTD = "THETA1", VSTD = "THETA2", TM50 = "THETA5", OM_CL = "OMEGA.1.1.", OM_V = "OMEGA.2.2.")
tv <- truth[c("CLSTD", "VSTD", "TM50", "OM_CL", "OM_V")]
rse <- function(r) round(100 * r$s[key] / abs(r$f[key]), 1)
data.frame(truth = tv, source.90 = signif(po$f[key], 3), RSE = rse(po),
           neonate = signif(px$f[key], 3), RSE = rse(px),
           neo.prior = signif(pp$f[key], 3), RSE = rse(pp), row.names = names(key))
# The OFV of a run with a prior carries the prior's penalty and cannot be
# compared with the others.
c(OFV.neonates.only = round(px$f[["OBJ"]], 2), OFV.with.prior = round(pp$f[["OBJ"]], 2))
