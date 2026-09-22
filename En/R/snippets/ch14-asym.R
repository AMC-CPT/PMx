# The asymptotic standard errors are already in hand. $COV produced them and
# they sit on the -1000000001 row of the .ext (Ch 8). Estimate +- 1.96 SE is
# the normal-approximation interval.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
e   <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
fin <- unlist(e[e$ITERATION == -1000000000, -1])
se  <- unlist(e[e$ITERATION == -1000000001, -1])

key <- c(T1 = "THETA1", T2 = "THETA2", T3 = "THETA3", T4 = "THETA4",
         T5 = "THETA5", T6 = "THETA6",
         O11 = "OMEGA.1.1.", O21 = "OMEGA.2.1.", O22 = "OMEGA.2.2.")
asym <- data.frame(estimate = fin[key], SE = se[key],
                   lower = fin[key] - 1.96 * se[key],
                   upper = fin[key] + 1.96 * se[key],
                   RSE = 100 * se[key] / abs(fin[key]))
rownames(asym) <- names(key)
signif(asym, 3)
