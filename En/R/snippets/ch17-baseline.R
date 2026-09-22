# The fit using the observed baseline as a covariate (pd102). The NRS at time 0
# was turned into a logit and used as LB.
p2 <- fin("pd102")
key3 <- c(PLMAX = "THETA3", KPL = "THETA4", EMAX = "THETA5", EC50 = "THETA6",
          OM_PLMAX = "OMEGA.3.3.", OM_EC50 = "OMEGA.4.4.")
data.frame(truth = signif(truth[c("PLMAX", "KPL", "EMAX", "EC50", "OM_PLMAX", "OM_EC50")], 3),
           estimated.baseline = signif(r$f[c("THETA4", "THETA5", "THETA6", "THETA7",
                                 "OMEGA.4.4.", "OMEGA.5.5.")], 3),
           observed.baseline = signif(p2$f[key3], 3), row.names = names(key3))
l <- readLines(nmf("pd102", "pd102.lst"), warn = FALSE)
g <- l[max(grep("GRADIENT:", l))]                     # the gradient of the last iteration
range(abs(as.numeric(strsplit(trimws(sub(".*GRADIENT:", "", g)), " +")[[1]])))
