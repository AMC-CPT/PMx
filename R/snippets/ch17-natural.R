# 자연 척도 모형(pd100x)과 로짓 모형(pd100). 모수 수가 같으므로 OFV 를 바로 견준다.
x <- fin("pd100x")
c(자연척도 = round(x$f[["OBJ"]], 2), 로짓 = round(r$f[["OBJ"]], 2),
  차이 = round(x$f[["OBJ"]] - r$f[["OBJ"]], 2))
# 자연 척도의 전형 곡선은 어디까지 내려가는가. 160 mg 군의 전형 NRS.
# EBE 없이 전형값만으로도 두 모형이 다른 자리를 가리킨다.
nat <- function(t, d) { C <- if (t > 0) d / x$f["THETA2"] * exp(-x$f["THETA1"] / x$f["THETA2"] * t) else 0
  x$f["THETA3"] - x$f["THETA4"] * (1 - exp(-x$f["THETA5"] * t)) -
  x$f["THETA6"] * C / (x$f["THETA7"] + C) }
lgt <- function(t, d) { C <- if (t > 0) d / r$f["THETA2"] * exp(-r$f["THETA1"] / r$f["THETA2"] * t) else 0
  L <- r$f["THETA3"] - r$f["THETA4"] * (1 - exp(-r$f["THETA5"] * t)) -
       r$f["THETA6"] * C / (r$f["THETA7"] + C); 10 / (1 + exp(-L)) }
out <- rbind(자연척도 = sapply(c(0, 2, 12, 24), nat, d = 160),
             로짓 = sapply(c(0, 2, 12, 24), lgt, d = 160))
colnames(out) <- paste0(c(0, 2, 12, 24), "h"); round(out, 2)
