# OQ: compare nm/oq1, the vendor example (examples/setest.ctl) run on this
# machine, against the result the vendor ships with it (examples/setest.ext,
# copied to Ref/oq/). The reference values are the final estimates
# transcribed from that file.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
here   <- fin("oq1")
vendor <- c(OBJ = -1121.02837, THETA1 = 1.68689, THETA2 = 1.61126,
            THETA3 = 0.819484, THETA4 = 2.39152, SIGMA.1.1. = 0.0571570,
            OMEGA.1.1. = 0.165065, OMEGA.2.2. = 0.131447,
            OMEGA.3.3. = 0.187549, OMEGA.4.4. = 0.149922,
            OMEGA.2.1. = -0.000750916, OMEGA.3.1. = 0.0124051,
            OMEGA.3.2. = 0.0159326,    OMEGA.4.1. = -0.0127447,
            OMEGA.4.2. = 0.0138934,    OMEGA.4.3. = 0.0332761)
k   <- names(vendor)[1:10]
sig <- function(x) formatC(x, digits = 6, format = "g")      # 6 significant
data.frame(vendor = sig(vendor[k]), `this PC` = sig(here[k]),
           `rel.diff %` = round(100 * (here[k] - vendor[k]) / vendor[k], 3),
           row.names = k, check.names = FALSE)

# Off-diagonals sit near zero, so look at absolute rather than relative
# difference (the vendor's own .xtl convention does the same).
od <- names(vendor)[11:16]
c(`max abs diff, off-diagonal` = signif(max(abs(here[od] - vendor[od])), 2))
