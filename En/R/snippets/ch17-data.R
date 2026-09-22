# The data of Ch 17: simulated with known true values (R/mkdata/make_pd.R).
d <- read.csv("data/pd-sim.csv")
arm <- c("placebo", "40 mg", "80 mg", "160 mg")
table(arm = factor(arm[d$ARM], arm),
      type = factor(c("concentration", "NRS")[d$DVID], c("concentration", "NRS")))

# The NRS at time 0 is the baseline. It should be the same across arms
# (randomized allocation).
b <- d[d$DVID == 2 & d$TIME == 0, ]
round(tapply(b$DV, arm[b$ARM], mean), 2)
