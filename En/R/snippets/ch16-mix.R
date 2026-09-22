# The result with $MIX. Estimate the subpopulation's clearance ratio FPM and
# its proportion PPM, and see whether the IIV of CL returns to the true 0.09.
# 123mixiov, which adds IOV as well, is the final model.
m2 <- fin("122mix"); m3 <- fin("123mixiov")
key <- c(CL = "THETA2", FPM = "THETA6", PPM = "THETA7", OM_CL = "OMEGA.2.2.",
         PI_CL = "OMEGA.4.4.")
tv <- truth[c("CL", "FPM", "PPM", "OM_CL", "PI_CL")]
get <- function(r) sapply(key, function(k) if (k %in% names(r$f)) r$f[[k]] else NA)
rse <- function(r) sapply(key, function(k) if (k %in% names(r$s)) 100 * r$s[[k]] / abs(r$f[[k]]) else NA)
data.frame(truth = tv, mixture = signif(get(m2), 3), RSE = round(rse(m2), 1),
           mixture.IOV = signif(get(m3), 3), RSE = round(rse(m3), 1), row.names = names(key))
c(OFV.IIV.only = round(b$f[["OBJ"]], 1), OFV.mixture = round(m2$f[["OBJ"]], 1),
  OFV.IOV = round(v$f[["OBJ"]], 1), OFV.mixture.IOV = round(m3$f[["OBJ"]], 1))

# Who is in which subpopulation? MIXEST (MEST in the table) against the true POP.
ca <- read.table(nmf("123mixiov", "catab"), skip = 1, header = TRUE)
ca <- ca[!duplicated(ca$ID), ]
table(truth = c("normal", "reduced")[ca$POP], estimated = c("normal", "reduced")[ca$MEST])
