# Compare sampling designs with the Fisher information matrix. One-compartment
# oral, 30 subjects, the same true values as R/sse.R. The FO approximation for a
# population model (PFIM's approach). One person's observation vector is normal
# with mean E = F(theta, eta=0) and variance V = G Omega G' + diag(sigma^2(F)).
# The information about psi = (theta, omega^2, sigma) is the sum of a mean part
# and a variance part, and the square roots of the diagonal of its inverse are
# the expected SEs.
#   I_kl = sum_i [ dE/dpsi_k' V^-1 dE/dpsi_l + 1/2 tr(V^-1 dV/dpsi_k V^-1 dV/dpsi_l) ]
psi0 <- c(KA = 1.2, CL = 4, V = 50, OM_KA = 0.16, OM_CL = 0.09, OM_V = 0.04, ADD = 0.05, PROP = 0.12)
dose <- 100
conc <- function(th, tt) { ka <- th[1]; ke <- th[2] / th[3]
  dose * ka / (th[3] * (ka - ke)) * (exp(-ke * tt) - exp(-ka * tt)) }
jac <- function(fn, x, tt, h = 1e-5)                # numerical Jacobian (central differences)
  sapply(seq_along(x), function(j) { e <- x; e[j] <- x[j] * (1 + h); m <- x; m[j] <- x[j] * (1 - h)
    (fn(e, tt) - fn(m, tt)) / (2 * h * x[j]) })
Vmat <- function(psi, tt) {                          # variance matrix of the observation vector
  th <- psi[1:3]; f <- conc(th, tt)
  G  <- sweep(jac(conc, th, tt), 2, th, "*")         # dF/deta = theta * dF/dtheta (log-normal)
  G %*% diag(psi[4:6]) %*% t(G) + diag(psi[7]^2 + psi[8]^2 * f^2, length(tt))
}
fim1 <- function(tt, psi = psi0) {                    # the information of one person
  V  <- Vmat(psi, tt); Vi <- solve(V)
  dE <- cbind(jac(conc, psi[1:3], tt), matrix(0, length(tt), 5))          # the mean depends on theta only
  dV <- lapply(seq_along(psi), function(k) { e <- psi; e[k] <- psi[k] * (1 + 1e-5)
    m <- psi; m[k] <- psi[k] * (1 - 1e-5); (Vmat(e, tt) - Vmat(m, tt)) / (2e-5 * psi[k]) })
  I <- t(dE) %*% Vi %*% dE
  for (k in 1:8) for (l in 1:8) I[k, l] <- I[k, l] + 0.5 * sum(diag(Vi %*% dV[[k]] %*% Vi %*% dV[[l]]))
  I
}
# A design is a list of sampling-time vectors (one per group). Multiply each by
# its number of subjects and add.
fim <- function(groups, n) Reduce(`+`, Map(function(tt, ni) ni * fim1(tt), groups, n))
rse_of <- function(groups, n = 30) {
  Fi <- fim(groups, n)
  if (rcond(Fi) < 1e-12) return(c(rep(NA, 8), logdet = NA))     # singular: the design does not determine the parameters
  se <- sqrt(diag(solve(Fi))); c(100 * se / psi0, logdet = log(det(Fi)))
}
designs <- list(rich    = list(list(c(0.5, 1, 2, 4, 8, 12, 24)), 30),
                sparse2 = list(list(c(1, 12)), 30),
                sparse3 = list(list(c(1, 4, 24)), 30),
                sparse2g = list(list(c(1, 12), c(2, 24)), c(15, 15)))   # two groups, two times each
out <- t(sapply(designs, function(d) rse_of(d[[1]], d[[2]])))
round(out, 1)
