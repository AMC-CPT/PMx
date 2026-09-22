# The second example. Theophylline, single oral dose, 12 subjects, 11
# concentrations each (R/mkdata/make_theo.R built it from data/theo-raw.txt,
# the data of Ch 6).
th <- read.csv("data/theo-nm.csv", na.strings = ".")
c(subjects = length(unique(th$ID)), doses = sum(th$EVID == 1),
  observations = sum(th$MDV == 0),
  excluded = sum(th$EVID == 0 & th$MDV == 1))
# The concentration at time 0 is not zero. It is a pre-dose observation, so it
# was excluded from the fit (MDV=1).
round(th$DV[th$EVID == 0 & th$TIME == 0], 2)
