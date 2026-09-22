# Simulation-estimation (SSE). The same three designs, 100 datasets each, all
# estimated with NONMEM (R/sse.R). The standard deviation of the estimates is
# the empirical SE, and its RSE is set beside the expected RSE of the
# information matrix.
sse <- read.csv("nm/sse/sse.csv")
table(design = sse$DESIGN, termination = sse$TERM)
ok <- sse[sse$TERM %in% c("SUCCESS", "ROUNDING"), ]     # a rounding error counts as a success (Ch 8)
emp <- function(d) { z <- ok[ok$DESIGN == d, c("KA", "CL", "V", "OM_KA", "OM_CL", "OM_V", "ADD", "PROP")]
  c(n = nrow(z), bias_CL = 100 * (median(z$CL) - psi0["CL"]) / psi0["CL"],
    100 * apply(z, 2, sd) / psi0) }
emp_tab <- t(sapply(c("rich", "sparse2", "sparse3"), emp))
colnames(emp_tab)[3:10] <- paste0("RSE_", colnames(emp_tab)[3:10])
round(emp_tab, 1)
# Compare with the information matrix's prediction (previous section), for rich
# and sparse3 only. sparse2 has no prediction (singular).
cmp <- rbind(FIM_rich = out["rich", 1:8], SSE_rich = emp_tab["rich", 3:10],
             FIM_sparse3 = out["sparse3", 1:8], SSE_sparse3 = emp_tab["sparse3", 3:10])
round(cmp, 1)
