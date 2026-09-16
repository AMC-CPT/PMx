# 셋째 예제. 반복 경구 투여, 30명, 100 mg 을 12시간마다 14회. 같은 관측을 세 가지로
# 적었다(R/mkdata/make_mult.R). 투약 레코드 14개 / ADDL 로 접은 하나 / SS=1 의 하나.
d1 <- read.csv("data/mult-explicit.csv", na.strings = ".")
d2 <- read.csv("data/mult-addl.csv", na.strings = ".")
d3 <- read.csv("data/mult-ss.csv", na.strings = ".")
c(전부 = nrow(d1), ADDL = nrow(d2), SS = nrow(d3), 관측_전부 = sum(d1$MDV == 0), 관측_SS = sum(d3$MDV == 0))
d2[d2$ID == 1 & d2$EVID == 1, ]                    # 투약 레코드 하나가 열넷을 대신한다
d3[d3$ID == 1 & d3$EVID == 1, ]                    # SS=1: 이 투약이 정상상태의 투약이다

# 세 실행. 앞의 둘은 같아야 하고, 셋째는 자료가 적으니 다르되 참값 근처여야 한다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
tr <- read.csv("data/mult-truth.csv"); truth <- setNames(tr$value, tr$name)
key <- c(KA = "THETA1", CL = "THETA2", V = "THETA3", OM_KA = "OMEGA.1.1.", OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3.")
tab <- sapply(c("130mult", "130addl", "130ss"), function(m) { r <- fin(m); c(OFV = r$f[["OBJ"]], signif(r$f[key], 4)) })
colnames(tab) <- c("투약 전부", "ADDL", "SS=1")
cbind(참값 = c(NA, truth[c("KA", "CL", "V", "OM_KA", "OM_CL", "OM_V")]), round(tab, 4))
