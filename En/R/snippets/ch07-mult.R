# The third example. Repeated oral dosing, 30 subjects, 100 mg every 12 h for
# 14 doses. The same observations were written three ways
# (R/mkdata/make_mult.R): 14 dosing records / one folded with ADDL / one with
# SS=1.
d1 <- read.csv("data/mult-explicit.csv", na.strings = ".")
d2 <- read.csv("data/mult-addl.csv", na.strings = ".")
d3 <- read.csv("data/mult-ss.csv", na.strings = ".")
c(every.dose = nrow(d1), ADDL = nrow(d2), SS = nrow(d3),
  obs.every = sum(d1$MDV == 0), obs.SS = sum(d3$MDV == 0))
d2[d2$ID == 1 & d2$EVID == 1, ]                    # one dosing record stands for fourteen
d3[d3$ID == 1 & d3$EVID == 1, ]                    # SS=1: this dose is the steady-state dose

# Three runs. The first two must agree; the third has less data, so it should
# differ yet stay near the truth.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
tr <- read.csv("data/mult-truth.csv"); truth <- setNames(tr$value, tr$name)
key <- c(KA = "THETA1", CL = "THETA2", V = "THETA3", OM_KA = "OMEGA.1.1.",
         OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3.")
tab <- sapply(c("130mult", "130addl", "130ss"),
              function(m) { r <- fin(m); c(OFV = r$f[["OBJ"]], signif(r$f[key], 4)) })
colnames(tab) <- c("every dose", "ADDL", "SS=1")
cbind(truth = c(NA, truth[c("KA", "CL", "V", "OM_KA", "OM_CL", "OM_V")]), round(tab, 4))
