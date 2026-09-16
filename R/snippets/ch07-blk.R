# 1차 흡수 모형에서 OMEGA 를 대각(110ka)과 블록(113blk)으로 둔 것. KA, CL, V 의
# 개체간 상관을 본다. PHENO 의 0.991 과 견주어 읽는다.
x <- fin("113blk")
om <- matrix(x[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.3.1.", "OMEGA.2.1.", "OMEGA.2.2.",
                 "OMEGA.3.2.", "OMEGA.3.1.", "OMEGA.3.2.", "OMEGA.3.3.")], 3,
             dimnames = list(c("KA", "CL", "V"), c("KA", "CL", "V")))
round(cov2cor(om), 3)
c(대각 = round(fin("110ka")[["OBJ"]], 2), 블록 = round(x[["OBJ"]], 2),
  dOFV = round(fin("110ka")[["OBJ"]] - x[["OBJ"]], 2))
