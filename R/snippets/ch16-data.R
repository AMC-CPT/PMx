# 16장의 자료. 세 회차의 경구 투여, 60명. 참값을 알고 만들었다(R/mkdata/make_iov.R).
d <- read.csv("data/iov-sim.csv", na.strings = ".")
obs <- d[d$MDV == 0, ]
c(대상자 = length(unique(d$ID)), 관측 = nrow(obs), 회차 = length(unique(d$OCC)),
  회차당관측 = nrow(obs) / length(unique(d$ID)) / 3)

# 참값. 아집단(POP 2)은 청소율이 30 % 다. 모형은 POP 열을 쓰지 않는다.
tr <- read.csv("data/iov-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)
table(아집단 = c("정상", "저하")[d$POP[!duplicated(d$ID)]])
