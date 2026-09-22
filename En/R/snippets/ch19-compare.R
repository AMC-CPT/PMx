# Six models fitted to the same data. The OFV does not penalize the number of
# parameters, so they are compared by AICc. 173 observations, 20 subjects.
mods <- c(tg100 = "exponential", tg101 = "logistic", tg102 = "Gompertz (diagonal)",
          tg102b = "Gompertz (block)", tg103 = "power law", tg104 = "von Bertalanffy",
          tg105 = "reduced Gompertz")
fin <- function(m) {
  e <- read.table(file.path("nm", paste0(m, ".R76"), paste0(m, ".ext")),
                  skip = 1, header = TRUE)
  f <- unlist(e[e$ITERATION == -1000000000, -1])
  p <- sum(f[grep("THETA|OMEGA", names(f))] != 0)     # a zero means it was fixed
  c(OFV = f[["OBJ"]], p = p)
}
tab <- t(sapply(names(mods), fin))
n   <- 173
tab <- data.frame(model = mods, OFV = round(tab[, "OFV"], 1), parameters = tab[, "p"],
                  AICc = round(tab[, "OFV"] + 2 * tab[, "p"] +
                               2 * tab[, "p"] * (tab[, "p"] + 1) / (n - tab[, "p"] - 1), 1))
tab[order(tab$AICc), ]
