# The full TMDD model. As in practice, it was run with FO. In tm100 the
# intercept of target synthesis (THETA8) sat on its lower bound, so tm103, which
# drops it, is the final model.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]),
       eig = unlist(e[e$ITERATION == -1000000002, -1]))   # eigenvalues of the correlation matrix
}
r0 <- fin("tm100")
c(tm100.OFV = round(r0$f[["OBJ"]], 2), KSYN.intercept = signif(r0$f[["THETA8"]], 3),
  lower.bound = 1e-4, BWT.slope = signif(r0$f[["THETA12"]], 3))
r <- fin("tm103")
key <- c(CL_kg = "THETA1", V1_kg = "THETA2", Q = "THETA3", V2 = "THETA4", KON = "THETA5",
         KOFF = "THETA6", KINT = "THETA7", KDEG = "THETA9", add.SD = "THETA10",
         prop.CV = "THETA11", KSYN_kg = "THETA12")
data.frame(estimate = signif(r$f[key], 3), RSE = round(100 * r$s[key] / abs(r$f[key]), 1),
           row.names = names(key))
eig <- r$eig[grepl("THETA|OMEGA|SIGMA", names(r$eig))]; eig <- eig[eig != 0]
c(OFV = round(r$f[["OBJ"]], 2), condition.number = round(max(eig) / min(eig)))

# Derived quantities, for a typical 4 kg monkey. KD was estimated as an amount
# (mg), so divide by V1 to bring it to a concentration.
th <- r$f; bwt <- 4
cl <- th[["THETA1"]] * bwt; v1 <- th[["THETA2"]] * bwt
c(linear.half.life.h = round(log(2) * (v1 + th[["THETA4"]]) / cl, 1),
  KD.mgL = signif(th[["THETA6"]] / th[["THETA5"]] / v1, 3),
  target.half.life.h = round(log(2) / th[["THETA9"]], 1),
  complex.half.life.h = round(log(2) / (th[["THETA6"]] + th[["THETA7"]]), 1),   # dissociation and internalisation remove it together
  baseline.target.mg = signif(th[["THETA12"]] * bwt / th[["THETA9"]], 3))
