# 고정해 보고 값을 치른다. 고정하면 모수가 하나 줄고 OFV 는 오른다.
ofv <- function(m) fin(m)[["OBJ"]]
o <- c(둘다추정 = ofv("108wt"), V만고정 = ofv("108wts"), 둘다고정 = ofv("108wtx"))
round(rbind(OFV = o, 앞단계대비 = c(NA, diff(o))), 2)

# 문턱 둘을 함께 놓고 본다.
c(전진문턱 = 3.84, 후진문턱 = 10.83)
