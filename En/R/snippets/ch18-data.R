# The data of Ch 18. Warfarin-type PK/PD simulated data, 40 subjects, a single
# oral 100 mg dose. Built with known true values (R/mkdata/make_warf.R).
# Concentration and PCA are in one file, separated by DVID.
d <- read.csv("data/warf-sim.csv", na.strings = ".")
obs <- d[d$MDV == 0, ]
table(type = c("concentration", "PCA")[obs$DVID])
tr <- read.csv("data/warf-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)

# The baseline (PCA at time 0) and the nadir. How many days to recovery?
pca <- obs[obs$DVID == 2, ]
m <- tapply(pca$DV, pca$TIME, mean)
round(m, 1)
