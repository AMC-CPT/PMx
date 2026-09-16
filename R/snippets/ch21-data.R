# 21장의 자료. 신생아부터 청소년까지 120명, 정맥 bolus 5 mg/kg. 참값을 안다
# (R/mkdata/make_ped.R). 신생아는 채혈이 2-3회로 희박하다.
d <- read.csv("data/ped-sim.csv", na.strings = ".")
s <- d[!duplicated(d$ID), ]
obs <- d[d$MDV == 0, ]
grp <- c("신생아", "영아", "소아", "청소년")
data.frame(군 = grp, 명 = as.vector(table(s$GRP)),
           체중 = tapply(s$WT, s$GRP, function(x) sprintf("%.1f-%.1f", min(x), max(x))),
           PMA주 = tapply(s$PMA, s$GRP, function(x) sprintf("%.0f-%.0f", min(x), max(x))),
           관측_1인 = round(tapply(obs$ID, obs$GRP, length) / 30, 1), row.names = NULL)
tr <- read.csv("data/ped-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)
