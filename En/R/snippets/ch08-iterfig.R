# Three traces left by each iteration: the OFV from the .ext, the gradient from
# the .grd, and the significant digits approximated from the change between
# adjacent iterations (the lowest of the four parameters). The grid is that of
# PRINT=5.
g <- read.table(nmf("100base", "100base.grd"), skip = 1, header = TRUE)
g <- g[!duplicated(g[, -1]), ]                     # the last row repeats the one before
gmax <- apply(abs(g[, -1]), 1, max)
sig  <- sapply(2:nrow(it), function(i) {
  a <- unlist(it[i - 1, p]); b <- unlist(it[i, p])
  min(-log10(abs((b - a) / b)))
})
tr <- data.frame(iteration = it$ITERATION, OFV = round(it$OBJ, 2),
                 gradient = signif(gmax, 2), sig.digits = c(NA, round(sig, 2)))
tr

par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(tr$iteration, tr$OFV, type = "b", pch = 16, xlab = "iteration", ylab = "OFV",
     main = "objective function")
plot(tr$iteration, tr$gradient, type = "b", pch = 16, log = "y", xlab = "iteration",
     ylab = "max |gradient|", main = "gradient")
abline(h = 1, lty = 2)
plot(tr$iteration, tr$sig.digits, type = "b", pch = 16, xlab = "iteration",
     ylab = "significant digits (approx.)", main = "significant digits")
abline(h = 3, lty = 2)
