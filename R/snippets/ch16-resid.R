# 잔차오차 모형 셋을 같은 구조 모형(IIV 만, IOV 없음)에 얹어 견준다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
mods <- c(`120add` = "가법", `120prop` = "비례", `120base` = "복합")
tab <- t(sapply(names(mods), function(m) {
  r <- fin(m); f <- r$f
  c(OFV = f[["OBJ"]], 모수 = sum(grepl("THETA", names(f)) & f != 0),
    가법SD = if (m == "120prop") NA else f[["THETA4"]],
    비례CV = if (m == "120add") NA else if (m == "120prop") f[["THETA4"]] else f[["THETA5"]],
    OM_CL = f[["OMEGA.2.2."]])
}))
data.frame(오차 = mods, round(tab, 3), row.names = NULL)
c(참값_가법SD = truth[["ADD"]], 참값_비례CV = truth[["PROP"]])
