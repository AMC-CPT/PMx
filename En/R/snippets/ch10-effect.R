# Effect size. Across the range actually observed in the data, by what factor
# does the parameter change? A p value carries the sample size with it; this
# number does not.
d <- read.csv("data/pheno-nm.csv")
fold <- function(x, expo) (max(x) / min(x))^expo

round(c(weight.min = min(d$WT), weight.max = max(d$WT),
        CL.fold = fold(d$WT, est[["THETA5"]]),
        if.fixed = fold(d$WT, 0.75)), 2)

# Measure the two that were not significant with the same rule.
cr <- fin("108wtcr"); sx <- fin("109sex")
round(c(CREA.fold = fold(d$CREA, cr[["THETA7"]]),
        SEX.fold  = 1 + sx[["THETA7"]]), 3)

# What it is compared against is the interindividual variability that remains.
c(remaining.CV.CL = round(100 * sqrt(est[["OMEGA.1.1."]]), 1))
