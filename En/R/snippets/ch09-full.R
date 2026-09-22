# The full model: 108full, which adds CREA, APGR and SEX to 108wt all at once.
# Nothing is searched; the size of each effect and its 95 % interval are read.
f <- fin("108full"); fs <- se("108full")
ci <- function(k) c(estimate = f[[k]], lower = f[[k]] - 1.96 * fs[[k]], upper = f[[k]] + 1.96 * fs[[k]])
rbind(`CREA~CL` = ci("THETA7"), `APGR~CL` = ci("THETA8"), `SEX~CL` = ci("THETA9"))
dOFV <- fin("108wt")[["OBJ"]] - f[["OBJ"]]
c(dOFV = dOFV, df = 3, p = pchisq(dOFV, df = 3, lower.tail = FALSE))

# Where the price was paid: the RSE of the interindividual variability of clearance
w <- fin("108wt"); ws <- se("108wt")
c(`RSE % om(CL) 108wt` = 100 * ws[["OMEGA.1.1."]] / w[["OMEGA.1.1."]],
  `108full` = 100 * fs[["OMEGA.1.1."]] / f[["OMEGA.1.1."]])
