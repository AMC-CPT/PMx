# Shrinkage. How much smaller is the standard deviation of the EBEs than the
# estimated OMEGA? When the data cannot speak about a subject, the EBE is
# pulled towards 0.
shrink <- function(m, tab) {
  f <- fin(m)
  s <- read.table(nmf(m, tab), skip = 1, header = TRUE)
  s <- s[!duplicated(s$ID), ]
  round(100 * c(ETA1 = 1 - sd(s$ETA1) / sqrt(f[["OMEGA.1.1."]]),
                ETA2 = 1 - sd(s$ETA2) / sqrt(f[["OMEGA.2.2."]])), 1)
}
rbind(base = shrink("100base", "patab"), final = shrink("108wt", "patab"))
