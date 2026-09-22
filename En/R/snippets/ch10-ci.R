# Run artefacts live in one folder per model: nm/<model>.R76/ (Ch 3)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# The standard errors are on the ITERATION = -1000000001 row of the .ext.
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
est <- fin("108wt")
se  <- fin("108wt", -1000000001)

ci <- function(k) c(estimate = est[[k]], SE = se[[k]],
                    lower = est[[k]] - 1.96 * se[[k]],
                    upper = est[[k]] + 1.96 * se[[k]])
round(rbind(`WT~CL` = ci("THETA5"), `WT~V` = ci("THETA6")), 3)

# Does the CI contain the physiologically meaningful value?
# The allometric theoretical values are CL 0.75 and V 1.0.
c(`CI of CL contains 0.75` = 0.75 >= ci("THETA5")[["lower"]],
  `CI of V contains 1.0`   = 1.00 <= ci("THETA6")[["upper"]])
