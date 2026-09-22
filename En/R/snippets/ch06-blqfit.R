# Compare the three methods run on the same data (data/iov-blq.csv, LLOQ
# 0.5 mg/L) against the fit on the uncut data (120base).
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
runs <- c(uncut = "120base", M1 = "120m1", M5 = "120m5", M3 = "120m3")
par  <- c(KA = "THETA1", CL = "THETA2", V = "THETA3",
          add = "THETA4", prop = "THETA5",
          om.KA = "OMEGA.1.1.", om.CL = "OMEGA.2.2.", om.V = "OMEGA.3.3.")
est <- sapply(runs, function(m) fin(m)[par])
rownames(est) <- names(par)
round(est, 3)

round(est[, -1] / est[, 1], 2)     # ratio to the uncut fit; 1 means the same
