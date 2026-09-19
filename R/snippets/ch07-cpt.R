# 참값을 아는 2구획 정맥 자료(40명, R/mkdata/make_iv2.R)를 1·2·3구획으로 적합했다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
cond <- function(m) {                       # 조건수는 .ext 의 -1000000003 줄
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000003, 2]
}
truth <- read.csv("data/iv2-sim-truth.csv")
f1 <- fin("140iv2"); f2 <- fin("200iv2"); f3 <- fin("300iv2")
s2 <- fin("200iv2", -1000000001); s3 <- fin("300iv2", -1000000001)

c(`1구획` = f1[["OBJ"]], `2구획` = f2[["OBJ"]], `3구획` = f3[["OBJ"]])
c(dOFV.1to2 = f1[["OBJ"]] - f2[["OBJ"]], dOFV.2to3 = f2[["OBJ"]] - f3[["OBJ"]],
  p.2to3 = pchisq(f2[["OBJ"]] - f3[["OBJ"]], df = 4, lower.tail = FALSE))

c(`1구획 CL` = f1[["THETA1"]], `1구획 V` = f1[["THETA2"]])
th <- paste0("THETA", 1:4)
data.frame(참값 = truth$value[1:4], `2구획` = f2[th], SE = s2[th],
           `3구획` = f3[th], `RSE %` = 100 * s3[th] / f3[th],
           row.names = c("CL", "V1", "Q", "V2"), check.names = FALSE)

# 3구획이 더한 것: 셋째 구획의 두 파라미터와 Q3 의 개체간 변이
c(Q3 = f3[["THETA5"]], V3 = f3[["THETA6"]], `RSE % V3` = 100 * s3[["THETA6"]] / f3[["THETA6"]])
c(om.Q3 = f3[["OMEGA.5.5."]], `RSE % om.Q3` = 100 * s3[["OMEGA.5.5."]] / f3[["OMEGA.5.5."]])
c(`조건수 1구획` = cond("140iv2"), `2구획` = cond("200iv2"), `3구획` = cond("300iv2"))
