# The second dataset: counts. 200 subjects, seizure counts over six 28-day
# intervals.
cn <- read.csv("data/cnt-sim.csv")
round(truth[grep("CNT_", names(truth))], 3)
# Mean and variance. Under Poisson they are equal. How many times the mean is
# the variance (overdispersion)?
g <- split(cn$DV, cn$DOSE)
data.frame(arm = paste0(names(g), " mg"), mean = round(sapply(g, mean), 2),
           variance = round(sapply(g, var), 1),
           ratio = round(sapply(g, var) / sapply(g, mean), 1),
           zeros = sapply(g, function(x) sum(x == 0)), row.names = NULL)
