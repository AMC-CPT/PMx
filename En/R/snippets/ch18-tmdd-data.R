# The second example of Ch 18. 50 monkeys given a monoclonal antibody once as
# an intravenous bolus, at six dose levels. Data the author analyzed in practice,
# published here with only the development code and the animal numbers removed
# (R/mkdata/make_tmdd.R). Concentration is mg/L, time h, dose mg/kg, and AMT is
# the actual amount given (mg).
d <- read.csv("data/tmdd-mab.csv")
obs <- d[d$MDV == 0, ]
s <- d[!duplicated(d$ID), ]
data.frame(dose.mgkg = sort(unique(s$LVL)), animals = as.vector(table(s$LVL)),
           weight.kg = tapply(s$BWT, s$LVL, function(x) sprintf("%.1f-%.1f", min(x), max(x))),
           row.names = NULL)
c(observations = nrow(obs), sampling.times = length(unique(obs$TIME)),
  last.time.h = max(obs$TIME), lowest.concentration = min(obs$DV))
