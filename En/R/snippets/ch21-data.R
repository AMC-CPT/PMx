# The data of Ch 21. 120 subjects from neonates to adolescents, 5 mg/kg
# intravenous bolus. The truth is known (R/mkdata/make_ped.R). The neonates are
# sparsely sampled, two or three times each.
d <- read.csv("data/ped-sim.csv", na.strings = ".")
s <- d[!duplicated(d$ID), ]
obs <- d[d$MDV == 0, ]
grp <- c("neonate", "infant", "child", "adolescent")
data.frame(group = grp, n = as.vector(table(s$GRP)),
           weight = tapply(s$WT, s$GRP, function(x) sprintf("%.1f-%.1f", min(x), max(x))),
           PMA.weeks = tapply(s$PMA, s$GRP, function(x) sprintf("%.0f-%.0f", min(x), max(x))),
           obs.per.subject = round(tapply(obs$ID, obs$GRP, length) / 30, 1), row.names = NULL)
tr <- read.csv("data/ped-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)
