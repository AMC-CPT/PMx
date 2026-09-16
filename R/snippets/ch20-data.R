# 20장의 첫 자료. 시간-사건. 300명을 세 군에, 12개월 추적. 참값을 안다(R/mkdata/make_tte.R).
d <- read.csv("data/tte-sim.csv")
ev <- d[d$MDV == 0, ]                                # 사람마다 사건/절단 레코드 하나
table(군 = paste0(ev$DOSE, " mg"), 사건 = c("절단", "사건")[ev$DV + 1])
tr <- read.csv("data/tte-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth[grep("TTE_", names(truth))], 3)

# Kaplan-Meier 의 중앙 사건시각. 위약 6개월로 만들었다.
library(survival)
km <- survfit(Surv(TIME, DV) ~ DOSE, data = ev)
summary(km)$table[, c("records", "events", "median")]
