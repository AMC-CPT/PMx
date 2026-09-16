# 흡수 모형 셋. 1차 흡수(110ka), 1차 흡수 + 지연(111lag), 0차 흡수(112zo).
# 같은 자료이므로 OFV 를 바로 견주되, 모수 수가 다르면 AICc 로 본다.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
mods <- c("110ka", "111lag", "112zo")
tab <- t(sapply(mods, function(m) {
  x <- fin(m)
  p <- sum(x[grep("THETA|OMEGA", names(x))] != 0)
  c(OFV = round(x[["OBJ"]], 2), 모수 = p,
    AICc = round(x[["OBJ"]] + 2 * p + 2 * p * (p + 1) / (120 - p - 1), 2),
    CL = signif(x[["THETA2"]], 3), V = signif(x[["THETA3"]], 3), 흡수 = signif(x[["THETA1"]], 3))
}))
tab
