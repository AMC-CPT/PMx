# The first dataset of Ch 20: time to event. 300 subjects in three arms,
# followed for 12 months. The truth is known (R/mkdata/make_tte.R).
d <- read.csv("data/tte-sim.csv")
ev <- d[d$MDV == 0, ]                        # one event/censoring record per person
table(arm = factor(paste0(ev$DOSE, " mg"), paste0(sort(unique(ev$DOSE)), " mg")),
      status = factor(c("censored", "event")[ev$DV + 1], c("event", "censored")))
tr <- read.csv("data/tte-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth[grep("TTE_", names(truth))], 3)

# The Kaplan-Meier median event time. Placebo was made 6 months.
library(survival)
km <- survfit(Surv(TIME, DV) ~ DOSE, data = ev)
summary(km)$table[, c("records", "events", "median")]
