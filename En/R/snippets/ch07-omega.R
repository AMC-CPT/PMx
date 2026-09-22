# Interindividual variability. It was set as BLOCK(2), so there is one
# covariance as well.
Om <- matrix(b[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2,
             dimnames = list(c("ETA1.CL", "ETA2.V"), c("ETA1.CL", "ETA2.V")))
round(Om, 4)

# Seen as variances nothing seems to be happening. Turn it into a correlation
# and it shows.
round(cov2cor(Om), 3)

# It was set log-normal, so sqrt(variance) is roughly the interindividual CV.
round(sqrt(diag(Om)) * 100, 1)
