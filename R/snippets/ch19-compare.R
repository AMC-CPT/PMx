# 여섯 모형을 같은 자료에 적합했다. OFV 는 모수 수를 벌하지 않으므로 AICc 로
# 견준다. 관측 173, 대상자 20.
mods <- c(tg100 = "지수", tg101 = "로지스틱", tg102 = "Gompertz(대각)",
          tg102b = "Gompertz(블록)", tg103 = "멱함수", tg104 = "von Bertalanffy",
          tg105 = "축소 Gompertz")
fin <- function(m) {
  e <- read.table(file.path("nm", paste0(m, ".R76"), paste0(m, ".ext")),
                  skip = 1, header = TRUE)
  f <- unlist(e[e$ITERATION == -1000000000, -1])
  p <- sum(f[grep("THETA|OMEGA", names(f))] != 0)     # 0 인 것은 고정된 것이다
  c(OFV = f[["OBJ"]], p = p)
}
tab <- t(sapply(names(mods), fin))
n   <- 173
tab <- data.frame(모형 = mods, OFV = round(tab[, "OFV"], 1), 모수 = tab[, "p"],
                  AICc = round(tab[, "OFV"] + 2 * tab[, "p"] +
                               2 * tab[, "p"] * (tab[, "p"] + 1) / (n - tab[, "p"] - 1), 1))
tab[order(tab$AICc), ]
