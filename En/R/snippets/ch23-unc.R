# The table above was made with the estimates taken as true. To lay the
# uncertainty of the estimates on top, repeat the same calculation for each of
# the 200 resampled parameter sets (Ch 14).
b  <- read.csv("nm/boot/boot.csv")
b  <- b[b$TERM %in% c("SUCCESS", "ROUNDING"), ]
# A resample whose OMEGA is not positive definite cannot be drawn from. Count them.
ok <- b$O11 > 0 & b$O22 > 0 & b$O11 * b$O22 - b$O21^2 > 0
c(used = sum(ok), dropped = sum(!ok))
b  <- b[ok, ]
pta_boot <- sapply(seq_len(nrow(b)), function(r) {
  th <<- unlist(b[r, paste0("T", 1:6)])
  Om <<- matrix(unlist(b[r, c("O11", "O21", "O21", "O22")]), 2)
  ct <- trough72(wt, 2.5, MASS::mvrnorm(n, c(0, 0), Om))
  tapply(ct >= 15 & ct <= 30, bin, mean)
})
# Median and 90 % interval of the attainment rate per bin. One point estimate
# becomes a band.
out <- t(apply(100 * pta_boot, 1, quantile, c(0.05, 0.5, 0.95)))
colnames(out) <- c("5 %", "median", "95 %")
round(out, 1)
