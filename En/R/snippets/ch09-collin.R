# Overlap taken to its limit: the same covariate under two names. Compare
# 108wtbwt, which puts WT and BWT (identical values in these data) on clearance
# together, against 108wt.
se <- function(m) {                          # standard errors are the -1000000001 row of the .ext
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000001, -1])
}
w <- fin("108wt");    ws  <- se("108wt")
wb <- fin("108wtbwt"); wbs <- se("108wtbwt")
c(OFV.108wt = sprintf("%.3f", w[["OBJ"]]), OFV.108wtbwt = sprintf("%.3f", wb[["OBJ"]]))
rbind(`108wt    WT~CL`  = c(estimate = w[["THETA5"]], `RSE %` = 100 * ws[["THETA5"]] / w[["THETA5"]]),
      `108wtbwt WT~CL`  = c(wb[["THETA5"]], 100 * wbs[["THETA5"]] / wb[["THETA5"]]),
      `108wtbwt BWT~CL` = c(wb[["THETA7"]], 100 * wbs[["THETA7"]] / wb[["THETA7"]]),
      `108wtbwt sum`    = c(wb[["THETA5"]] + wb[["THETA7"]], NA))

# Correlation of the two exponent estimates (off-diagonal of the .cor, Ch 8)
# and the condition number (the -1000000003 row of the .ext)
C <- read.table(nmf("108wtbwt", "108wtbwt.cor"), skip = 1, header = TRUE,
                row.names = 1, check.names = FALSE)
cond <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000003, 2]
}
c(`cor(WT exp, BWT exp)` = C["THETA5", "THETA7"],
  `cond 108wt` = cond("108wt"), `cond 108wtbwt` = cond("108wtbwt"))
