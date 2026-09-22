# Three models: size only (ped100), size + maturation (ped101), and size only
# with the exponent estimated (ped102).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
p0 <- fin("ped100"); p1 <- fin("ped101"); p2 <- fin("ped102")
g <- function(r, k) if (k %in% names(r$f)) signif(r$f[[k]], 3) else NA
data.frame(
  model = c("size only (0.75 fixed)", "size + maturation", "size only (exponent estimated)"),
  OFV = round(c(p0$f[["OBJ"]], p1$f[["OBJ"]], p2$f[["OBJ"]]), 1),
  CLSTD = c(g(p0, "THETA1"), g(p1, "THETA1"), g(p2, "THETA1")),
  exponent = c(0.75, 0.75, g(p2, "THETA5")),
  TM50 = c(NA, g(p1, "THETA5"), NA), HILL = c(NA, g(p1, "THETA6"), NA),
  OM_CL = c(g(p0, "OMEGA.1.1."), g(p1, "OMEGA.1.1."), g(p2, "OMEGA.1.1.")))
c(true.CLSTD = truth[["CLSTD"]], true.TM50 = truth[["TM50"]], true.HILL = truth[["HILL"]],
  true.OM_CL = truth[["OM_CL"]])
# The size-only model had trouble converging.
grep("MINIMIZATION|PROBLEMS", readLines(nmf("ped100", "ped100.lst")), value = TRUE)
