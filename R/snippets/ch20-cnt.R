# 둘째 자료. 카운트. 200명, 28일 구간 여섯 번의 발작 횟수.
cn <- read.csv("data/cnt-sim.csv")
round(truth[grep("CNT_", names(truth))], 3)
# 평균과 분산. Poisson 이면 둘이 같다. 분산이 평균의 몇 배인가(과산포).
g <- split(cn$DV, cn$DOSE)
data.frame(군 = paste0(names(g), " mg"), 평균 = round(sapply(g, mean), 2),
           분산 = round(sapply(g, var), 1), 비 = round(sapply(g, var) / sapply(g, mean), 1),
           영 = sapply(g, function(x) sum(x == 0)), row.names = NULL)
