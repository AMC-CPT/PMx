# Put the four side by side: asymptotic approximation, resampling, profile
# likelihood, SIR.
span <- function(k) {
  m <- fin[[key[[k]]]]; s2 <- se[[key[[k]]]]
  x <- rbind(asymptotic = m + c(-1.96, 1.96) * s2,
             resampling = unname(quantile(b[[k]], c(0.025, 0.975), na.rm = TRUE)),
             profile    = llp[k, ],
             SIR        = sirq[k, ])
  colnames(x) <- c("lower", "upper")
  cbind(x, width = x[, 2] - x[, 1])
}
for (k in c("T3", "T5", "T6")) {
  cat("\n", k, "   estimate ", signif(fin[[key[[k]]]], 4), "\n", sep = "")
  print(round(span(k), 4))
}
