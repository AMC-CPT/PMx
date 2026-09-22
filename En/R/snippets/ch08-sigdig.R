# Run artefacts live in a folder of their own per model: nm/<model>.R76/ (Ch 3)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# SIGDIG is not an integer but a real number. It is defined as minus the log10
# of the relative error. Estimate a true 10.000 as 10.001 and there are four
# significant digits.
round(-log10(abs((10.001 - 10.000) / 10.000)), 2)

# The truth is unknown, so in practice the change between adjacent iterations is
# used. Rows of the .ext with ITERATION at least 0 are estimation iterations
# (every fifth step, because PRINT=5).
e  <- read.table(nmf("100base", "100base.ext"), skip = 1, header = TRUE)
it <- e[e$ITERATION >= 0, ]
p  <- paste0("THETA", 1:4)

# The last row repeats the final estimates, so it equals the row before it.
# Drop it before looking.
it <- it[!duplicated(it[, p]), ]
it[nrow(it) - 1:0, c("ITERATION", p)]

a <- unlist(it[nrow(it) - 1, p])
b <- unlist(it[nrow(it),     p])
round(-log10(abs((b - a) / b)), 2)

# The value reported in the .lst is 3.1. Per parameter they scatter from 2.15 to
# 4.55, because the reported value is not the digit count of any one parameter
# but a single number NONMEM settles for the whole vector **in UCP space**. The
# two are not values on the same scale.
