# 같은 PHENO 기저 모형을 다섯 방법으로 돌렸다. .ext 는 $EST 마다 표가 하나씩이므로
# 마지막 표의 최종 줄을 읽는다. 벽시계 시간은 실행기가 nmfe.log 에 남긴 것이다(3장).
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
  # BAYES 의 목적함수 열은 MCMCOBJ 이고 다른 방법의 OFV 와 견줄 수 없다. NA 로 둔다.
  ofv <- if ("OBJ" %in% names(f)) round(f[["OBJ"]], 2) else NA
  c(OFV = ofv, CL = signif(f[["THETA1"]], 4), V = signif(f[["THETA2"]], 4),
    가법 = signif(f[["THETA3"]], 3), 비례 = signif(f[["THETA4"]], 3),
    OM_CL = signif(f[["OMEGA.1.1."]], 3), OM_V = signif(f[["OMEGA.2.2."]], 3),
    상관 = round(f[["OMEGA.2.1."]] / sqrt(f[["OMEGA.1.1."]] * f[["OMEGA.2.2."]]), 3),
    초 = wall(m))
}))
tab
