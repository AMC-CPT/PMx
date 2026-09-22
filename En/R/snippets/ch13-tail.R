# See what the tail is made of. What was kept for each permutation is used here.
rpt$dOFV <- base - rpt$OFV
table(termination = rpt$TERM)

# The five largest dOFV. The exponents (T5, T6) went nowhere near a boundary.
top <- head(rpt[order(-rpt$dOFV), ], 5)
with(top, data.frame(REP, dOFV = round(dOFV, 2), T5 = round(T5, 3),
                     T6 = round(T6, 3), TERM))

# Take only the ones that converged and compare again.
ok <- rpt$dOFV[rpt$TERM == "SUCCESS"]
round(rbind(all = quantile(null, pr), success.only = quantile(ok, pr),
            chisq = qchisq(pr, 2)), 2)
c(max.all = round(max(null), 2), max.success = round(max(ok), 2))
