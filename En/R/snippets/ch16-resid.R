# Three residual error models on the same structural model (IIV only, no IOV).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
mods <- c(`120add` = "additive", `120prop` = "proportional", `120base` = "combined")
tab <- t(sapply(names(mods), function(m) {
  r <- fin(m); f <- r$f
  c(OFV = f[["OBJ"]], parameters = sum(grepl("THETA", names(f)) & f != 0),
    add.SD = if (m == "120prop") NA else f[["THETA4"]],
    prop.CV = if (m == "120add") NA else if (m == "120prop") f[["THETA4"]] else f[["THETA5"]],
    OM_CL = f[["OMEGA.2.2."]])
}))
data.frame(error = mods, round(tab, 3), row.names = NULL)
c(true.add.SD = truth[["ADD"]], true.prop.CV = truth[["PROP"]])
