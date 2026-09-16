# 16장의 자료. 참값을 알고 만든 모의 자료다(R/mkdata/make_pd.R).
d <- read.csv("data/pd-sim.csv")
arm <- c("위약", "40 mg", "80 mg", "160 mg")
table(군 = arm[d$ARM], 종류 = c("농도", "NRS")[d$DVID])

# 시각 0 의 NRS 가 기저치다. 군별로 같아야 한다(무작위 배정).
b <- d[d$DVID == 2 & d$TIME == 0, ]
round(tapply(b$DV, arm[b$ARM], mean), 2)
