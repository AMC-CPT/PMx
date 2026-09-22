# The ETA correlation that remains. In Ch 9, 0.991 became 0.880. Still high.
om <- function(m) {
  f <- fin(m)
  M <- matrix(f[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2)
  c(CV.CL = 100 * sqrt(M[1, 1]), CV.V = 100 * sqrt(M[2, 2]),
    corr = cov2cor(M)[1, 2])
}
round(rbind(base = om("100base"), final = om("108wt")), 3)

# The correlation fell only a little, yet the variability dropped below half.
# So do not judge on 'the correlation is high' alone. Look at what it is a
# correlation of, as well.
