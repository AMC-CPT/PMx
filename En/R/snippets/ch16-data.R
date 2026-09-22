# The data of Ch 16: oral dosing on three occasions, 60 subjects. Built with
# known true values (R/mkdata/make_iov.R).
d <- read.csv("data/iov-sim.csv", na.strings = ".")
obs <- d[d$MDV == 0, ]
c(subjects = length(unique(d$ID)), observations = nrow(obs),
  occasions = length(unique(d$OCC)),
  obs.per.occasion = nrow(obs) / length(unique(d$ID)) / 3)

# The true values. The subpopulation (POP 2) has 30 % of the clearance. The
# model does not use the POP column.
tr <- read.csv("data/iov-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)
table(subpopulation = c("normal", "reduced")[d$POP[!duplicated(d$ID)]])
