# 섞은 자료로 200번 다시 적합한 결과다(R/rpt.R). 체중이 아무 정보도 갖지
# 않으므로, 여기서 나오는 dOFV 가 **우연으로 얻을 수 있는 크기**다.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
ofv <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000000, "OBJ"]
}
base <- ofv("100base")
obs  <- base - ofv("108wt")                  # 실제로 얻은 dOFV

rpt  <- read.csv("nm/rpt/rpt.csv")
null <- base - rpt$OFV[!is.na(rpt$OFV)]

c(실제 = round(obs, 2), 순열횟수 = length(null),
  귀무최대 = round(max(null), 2), 귀무중앙 = round(median(null), 2))

# p 값. 귀무분포에서 실제만큼 큰 값이 몇 번 나왔는가(자기 자신을 포함해 센다).
c(p = round((sum(null >= obs) + 1) / (length(null) + 1), 4))

# 카이제곱이 말하는 문턱과 견준다. 자유도 2 다(공변량 모수 둘).
c(카이제곱95 = round(qchisq(0.95, 2), 2),
  순열95 = round(unname(quantile(null, 0.95)), 2))
