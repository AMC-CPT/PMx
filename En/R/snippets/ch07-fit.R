# The estimation result is in the .ext. The row with ITERATION -1000000000
# holds the final estimates.
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
b <- fin("100base")

data.frame(estimate = round(b[paste0("THETA", 1:4)], 4),
           row.names = c("CL (L/h)", "V (L)",
                         "additive error SD (mg/L)", "proportional error CV"))
c(OFV = round(b[["OBJ"]], 2))
