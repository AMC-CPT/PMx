# Before and after IOV goes in. How far two parameters (two IOV variances)
# bring the OFV down, and where the remaining variances go, beside the truth.
b <- fin("120base"); v <- fin("121iov")
key <- c(KA = "THETA1", CL = "THETA2", V = "THETA3", add.SD = "THETA4", prop.CV = "THETA5",
         OM_KA = "OMEGA.1.1.", OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3.",
         PI_CL = "OMEGA.4.4.", PI_KA = "OMEGA.7.7.")
tv <- c(truth[c("KA", "CL", "V", "ADD", "PROP", "OM_KA")],
        OM_CL = NA, truth[c("OM_V", "PI_CL", "PI_KA")])   # the true IIV of CL is not one number: the subpopulations are mixed
get <- function(r) sapply(key, function(k) if (k %in% names(r$f)) r$f[[k]] else NA)
rse <- function(r) sapply(key, function(k) if (k %in% names(r$s)) 100 * r$s[[k]] / abs(r$f[[k]]) else NA)
data.frame(truth = signif(tv, 3), IIV.only = signif(get(b), 3), RSE = round(rse(b), 1),
           IIV.IOV = signif(get(v), 3), RSE = round(rse(v), 1), row.names = names(key))
c(OFV.IIV.only = round(b$f[["OBJ"]], 2), OFV.IOV = round(v$f[["OBJ"]], 2),
  dOFV = round(v$f[["OBJ"]] - b$f[["OBJ"]], 1))
