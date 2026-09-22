# The same PHENO base model run by five methods. The .ext holds one table per
# $EST, so read the final row of the last table. The wall-clock time is what the
# runner left in nmfe.log (Ch 3).
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
last_ext <- function(m) {
  x <- readLines(nmf(m, paste0(m, ".ext")), warn = FALSE)
  s <- max(grep("^TABLE NO", x))
  e <- read.table(text = x[(s + 1):length(x)], header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
wall <- function(m) {
  l <- grep("wall seconds", readLines(nmf(m, "nmfe.log"), warn = FALSE), value = TRUE)
  if (length(l)) as.numeric(sub(".*: ", "", l[1])) else NA
}
mods <- c(`FOCE-I` = "100foce", ITS = "100its", IMP = "100imp", SAEM = "100saem",
          BAYES = "100bayes")
tab <- t(sapply(mods, function(m) {
  f <- last_ext(m)
  # The objective function column of BAYES is MCMCOBJ and cannot be compared
  # with the OFV of the other methods. Left as NA.
  ofv <- if ("OBJ" %in% names(f)) round(f[["OBJ"]], 2) else NA
  c(OFV = ofv, CL = signif(f[["THETA1"]], 4), V = signif(f[["THETA2"]], 4),
    add = signif(f[["THETA3"]], 3), prop = signif(f[["THETA4"]], 3),
    OM_CL = signif(f[["OMEGA.1.1."]], 3), OM_V = signif(f[["OMEGA.2.2."]], 3),
    corr = round(f[["OMEGA.2.1."]] / sqrt(f[["OMEGA.1.1."]] * f[["OMEGA.2.2."]]), 3),
    sec = wall(m))
}))
tab
