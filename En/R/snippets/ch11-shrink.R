# Two shrinkages. eta-shrinkage is how much smaller the scatter of the EBEs is
# than OMEGA; eps-shrinkage is how much smaller the scatter of IWRES is than 1.
# Check the values NONMEM prints in the .lst (ETASHRINKSD, EPSSHRINKSD) against
# the ones obtained by hand.
e  <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
f  <- unlist(e[e$ITERATION == -1000000000, -1])
pa <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
sd <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
sd <- sd[sd$MDV == 0, ]
hand <- c(ETA1 = 1 - sd(pa$ETA1) / sqrt(f[["OMEGA.1.1."]]),
          ETA2 = 1 - sd(pa$ETA2) / sqrt(f[["OMEGA.2.2."]]),
          EPS  = 1 - sd(sd$IWRE))
l   <- readLines(nmf("108wt", "108wt.lst"), warn = FALSE)
pick <- function(tag) as.numeric(strsplit(trimws(sub(tag, "", grep(tag, l, value = TRUE)[1])), " +")[[1]])
nm <- c(pick("ETASHRINKSD\\(%\\)"), pick("EPSSHRINKSD\\(%\\)"))
round(rbind(by.hand = 100 * hand, NONMEM = nm), 1)
