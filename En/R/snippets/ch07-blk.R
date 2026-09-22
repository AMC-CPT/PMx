# The first-order absorption model with OMEGA diagonal (110ka) and block
# (113blk). Look at the interindividual correlations of KA, CL and V. Read them
# against the 0.991 of PHENO.
x <- fin("113blk")
om <- matrix(x[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.3.1.", "OMEGA.2.1.", "OMEGA.2.2.",
                 "OMEGA.3.2.", "OMEGA.3.1.", "OMEGA.3.2.", "OMEGA.3.3.")], 3,
             dimnames = list(c("KA", "CL", "V"), c("KA", "CL", "V")))
round(cov2cor(om), 3)
c(diagonal = round(fin("110ka")[["OBJ"]], 2), block = round(x[["OBJ"]], 2),
  dOFV = round(fin("110ka")[["OBJ"]] - x[["OBJ"]], 2))
