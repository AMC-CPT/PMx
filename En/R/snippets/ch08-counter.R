# Three demonstrations of what the condition number cannot answer. Every matrix
# here can be checked by hand.

# (1) The absolute uncertainty differs by a factor of a million, yet the
#     correlation matrices are identical and so are the condition numbers, at 1.
V1 <- diag(2)
V2 <- 1e6 * diag(2)
c(SE1 = sqrt(V1[1, 1]), SE2 = sqrt(V2[1, 1]),
  cond1 = kap(cov2cor(V1)), cond2 = kap(cov2cor(V2)))

# (2) No pair has a correlation above 0.5, and the condition number is 7,499.5.
R <- matrix(-0.4999, 3, 3); diag(R) <- 1
c(max.correlation = max(abs(R[upper.tri(R)])), cond = round(kap(R), 1))

# (3) Two blocks are each perfect (condition number 1) and the whole is 1,999.
#     That is, a large overall ratio may belong to no block at all.
B <- rbind(cbind(diag(2), 0.999 * diag(2)),
           cbind(0.999 * diag(2), diag(2)))
c(block1 = kap(B[1:2, 1:2]), block2 = kap(B[3:4, 3:4]), overall = round(kap(B), 1))
