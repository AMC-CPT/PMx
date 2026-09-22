# The .phi file. Per person it holds the EBEs, their conditional variances
# (ETC) and the individual objective function value (OBJ). What in 2008 had to
# be dug out with verbatim code and R has been one file since NONMEM 7.
fin <- function(m) { e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1])) }
phi <- read.table(nmf("108wt", "108wt.phi"), skip = 1, header = TRUE, check.names = FALSE)
names(phi) <- gsub("[(),]", "", names(phi))                  # ETA(1) -> ETA1, ETC(1,1) -> ETC11
head(phi[, c("ID", "ETA1", "ETA2", "ETC11", "ETC22", "OBJ")], 3)
c(sum.of.individual.OFV = round(sum(phi$OBJ), 3),
  reported.OFV = round(fin("108wt")$f[["OBJ"]], 3))

# Individual shrinkage: the standard error of the EBE (sqrt(ETC)) divided by
# omega. Near 1 means that person's data barely determined the ETA at all, and
# that person's EBE has shrunk to 0.
om <- fin("108wt")$f[c("OMEGA.1.1.", "OMEGA.2.2.")]
ind <- data.frame(ID = phi$ID, CL = sqrt(phi$ETC11 / om[1]), V = sqrt(phi$ETC22 / om[2]))
summary(ind[, c("CL", "V")])
# Join it to the population shrinkage. The variance of the EBEs falls short of
# omega^2 by the mean conditional variance, so the population shrinkage must be
# 1 - sqrt(1 - mean(individual shrinkage^2)).
c(population_CL = round(100 * (1 - sd(phi$ETA1) / sqrt(om[[1]])), 1),
  from_individual = round(100 * (1 - sqrt(1 - mean(ind$CL^2))), 1))
