# Three absorption models: first-order (110ka), first-order with a lag
# (111lag), zero-order (112zo). The data is the same, so the OFVs compare
# directly; where the parameter counts differ, look at AICc.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
mods <- c("110ka", "111lag", "112zo")
tab <- t(sapply(mods, function(m) {
  x <- fin(m)
  p <- sum(x[grep("THETA|OMEGA", names(x))] != 0)
  c(OFV = round(x[["OBJ"]], 2), par = p,
    AICc = round(x[["OBJ"]] + 2 * p + 2 * p * (p + 1) / (120 - p - 1), 2),
    CL = signif(x[["THETA2"]], 3), V = signif(x[["THETA3"]], 3),
    absorption = signif(x[["THETA1"]], 3))
}))
tab
