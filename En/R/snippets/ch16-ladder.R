# The ladder of this chapter. Five models on the same data. The number of
# parameters, the OFV, and where the IIV of CL returns to its true value, all in
# one table.
lad <- c(`120base` = "IIV only", `124etaeps` = "+ IIV on the residual", `121iov` = "+ IOV",
         `122mix` = "+ mixture", `123mixiov` = "+ IOV + mixture")
tab <- t(sapply(names(lad), function(m) {
  f <- fin(m)$f
  p <- sum(grepl("THETA", names(f)) & f != 0) +
       length(unique(f[grepl("OMEGA", names(f)) & f != 0]))   # a SAME block counts once
  c(parameters = p, OFV = round(f[["OBJ"]], 1), OM_CL = signif(f[["OMEGA.2.2."]], 3))
}))
data.frame(model = lad, tab, row.names = NULL)
