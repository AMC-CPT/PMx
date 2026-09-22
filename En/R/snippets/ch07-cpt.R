# Two-compartment IV data with known true values (40 subjects,
# R/mkdata/make_iv2.R) fitted with one, two and three compartments.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
cond <- function(m) {                       # the condition number is the -1000000003 row of the .ext
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000003, 2]
}
truth <- read.csv("data/iv2-sim-truth.csv")
f1 <- fin("140iv2"); f2 <- fin("200iv2"); f3 <- fin("300iv2")
s2 <- fin("200iv2", -1000000001); s3 <- fin("300iv2", -1000000001)

c(`1 compartment` = f1[["OBJ"]], `2 compartments` = f2[["OBJ"]],
  `3 compartments` = f3[["OBJ"]])
c(dOFV.1to2 = f1[["OBJ"]] - f2[["OBJ"]], dOFV.2to3 = f2[["OBJ"]] - f3[["OBJ"]],
  p.2to3 = pchisq(f2[["OBJ"]] - f3[["OBJ"]], df = 4, lower.tail = FALSE))

c(`1-cpt CL` = f1[["THETA1"]], `1-cpt V` = f1[["THETA2"]])
th <- paste0("THETA", 1:4)
data.frame(truth = truth$value[1:4], `2 cpt` = f2[th], SE = s2[th],
           `3 cpt` = f3[th], `RSE %` = 100 * s3[th] / f3[th],
           row.names = c("CL", "V1", "Q", "V2"), check.names = FALSE)

# What the third compartment added: two parameters and the interindividual
# variability of Q3
c(Q3 = f3[["THETA5"]], V3 = f3[["THETA6"]],
  `RSE % V3` = 100 * s3[["THETA6"]] / f3[["THETA6"]])
c(om.Q3 = f3[["OMEGA.5.5."]],
  `RSE % om.Q3` = 100 * s3[["OMEGA.5.5."]] / f3[["OMEGA.5.5."]])
c(`cond. 1 cpt` = cond("140iv2"), `2 cpt` = cond("200iv2"), `3 cpt` = cond("300iv2"))
