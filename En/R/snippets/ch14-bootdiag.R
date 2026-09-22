# Put what the figure showed into numbers, so that it can be quoted.
c(T3.collapsed = sum(b$T3 < 0.01),
  of.those.SUCCESS = sum(b$T3 < 0.01 & b$TERM == "SUCCESS"))

# The additive and proportional errors fill in for each other. What the
# condition number of Ch 8 said is visible here.
c(correlation = round(cor(b$T3, b$T4), 2),
  median.T4.when.T3.small = round(median(b$T4[b$T3 < 0.01]), 3),
  median.T4.otherwise = round(median(b$T4[b$T3 >= 0.01]), 3))

# Is any resample stuck on a boundary? The control file widened them to (-20, 20).
bd <- round(rbind(T5 = range(b$T5), T6 = range(b$T6)), 3)
colnames(bd) <- c("min", "max"); bd
