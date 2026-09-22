# A check only ever seen to pass may have checked nothing (the as.numeric
# above did exactly that). So before believing a checker, **make it fail
# first**. Break three things on purpose.
d1 <- nm; d1$ID[d1$ID == 7] <- 70              # disturb the ID ordering
d2 <- nm; d2$WT[d2$ID == 3][1] <- 9.9          # change a time-invariant covariate in one place
d3 <- nm; d3$TIME <- sub(":", ".", d3$TIME)    # break the time format

broken <- list("ID order" = d1, "time-invariant covariate" = d2,
               "time format" = d3)
for (k in names(broken)) {
  cat("\n-- broken:", k, "\n")
  check_nm(broken[[k]])
}
