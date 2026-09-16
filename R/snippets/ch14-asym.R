# 점근 표준오차는 이미 갖고 있다. $COV 가 내놓은 것이고 .ext 의
# -1000000001 줄에 들어 있다(8장). 추정치 +- 1.96 SE 가 정규 근사 구간이다.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
e   <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
fin <- unlist(e[e$ITERATION == -1000000000, -1])
se  <- unlist(e[e$ITERATION == -1000000001, -1])

key <- c(T1 = "THETA1", T2 = "THETA2", T3 = "THETA3", T4 = "THETA4",
         T5 = "THETA5", T6 = "THETA6",
         O11 = "OMEGA.1.1.", O21 = "OMEGA.2.1.", O22 = "OMEGA.2.2.")
asym <- data.frame(추정 = fin[key], SE = se[key],
                   하한 = fin[key] - 1.96 * se[key],
                   상한 = fin[key] + 1.96 * se[key],
                   RSE = 100 * se[key] / abs(fin[key]))
rownames(asym) <- names(key)
signif(asym, 3)
