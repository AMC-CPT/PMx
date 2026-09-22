# Step 1. Fit the PK from the concentrations alone (wf100). The PCA records
# were removed with IGNORE.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
show <- function(r, key, tv) data.frame(truth = signif(tv, 3), estimate = signif(r$f[key], 3),
       RSE = round(100 * r$s[key] / abs(r$f[key]), 1), row.names = names(key))
pk <- fin("wf100")
show(pk, c(KA = "THETA1", CL = "THETA2", V = "THETA3", prop.CV = "THETA4",
           OM_KA = "OMEGA.1.1.", OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3."),
     truth[c("KA", "CL", "V", "PROP", "OM_KA", "OM_CL", "OM_V")])
c(OFV = round(pk$f[["OBJ"]], 2))
