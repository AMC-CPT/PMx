# Fisher 정보행렬로 채혈 설계를 견준다. 1구획 경구, 30명, 참값은 R/sse.R 과 같다.
# 집단 모형의 FO 근사(PFIM 의 방식). 한 사람의 관측 벡터는 평균 E = F(theta, eta=0),
# 분산 V = G Omega G' + diag(sigma^2(F)) 인 정규분포다. 모수 psi = (theta, omega^2, sigma)
# 에 대한 정보는 평균 부분과 분산 부분의 합이고, 그 역행렬의 대각의 제곱근이 기대 SE 다.
#   I_kl = sum_i [ dE/dpsi_k' V^-1 dE/dpsi_l + 1/2 tr(V^-1 dV/dpsi_k V^-1 dV/dpsi_l) ]
psi0 <- c(KA = 1.2, CL = 4, V = 50, OM_KA = 0.16, OM_CL = 0.09, OM_V = 0.04, ADD = 0.05, PROP = 0.12)
dose <- 100
conc <- function(th, tt) { ka <- th[1]; ke <- th[2] / th[3]
  dose * ka / (th[3] * (ka - ke)) * (exp(-ke * tt) - exp(-ka * tt)) }
jac <- function(fn, x, tt, h = 1e-5)                # 수치 야코비안 (중심차분)
  sapply(seq_along(x), function(j) { e <- x; e[j] <- x[j] * (1 + h); m <- x; m[j] <- x[j] * (1 - h)
    (fn(e, tt) - fn(m, tt)) / (2 * h * x[j]) })
Vmat <- function(psi, tt) {                          # 관측 벡터의 분산행렬
  th <- psi[1:3]; f <- conc(th, tt)
  G  <- sweep(jac(conc, th, tt), 2, th, "*")         # dF/deta = theta * dF/dtheta (로그정규)
  G %*% diag(psi[4:6]) %*% t(G) + diag(psi[7]^2 + psi[8]^2 * f^2, length(tt))
}
fim1 <- function(tt, psi = psi0) {                    # 한 사람의 정보
  V  <- Vmat(psi, tt); Vi <- solve(V)
  dE <- cbind(jac(conc, psi[1:3], tt), matrix(0, length(tt), 5))          # 평균은 theta 에만
  dV <- lapply(seq_along(psi), function(k) { e <- psi; e[k] <- psi[k] * (1 + 1e-5)
    m <- psi; m[k] <- psi[k] * (1 - 1e-5); (Vmat(e, tt) - Vmat(m, tt)) / (2e-5 * psi[k]) })
  I <- t(dE) %*% Vi %*% dE
  for (k in 1:8) for (l in 1:8) I[k, l] <- I[k, l] + 0.5 * sum(diag(Vi %*% dV[[k]] %*% Vi %*% dV[[l]]))
  I
}
# 설계 = 채혈 시각의 목록(군). 군마다 사람 수를 곱해 더한다.
fim <- function(groups, n) Reduce(`+`, Map(function(tt, ni) ni * fim1(tt), groups, n))
rse_of <- function(groups, n = 30) {
  Fi <- fim(groups, n)
  if (rcond(Fi) < 1e-12) return(c(rep(NA, 8), logdet = NA))     # 특이: 설계가 모수를 정하지 못한다
  se <- sqrt(diag(solve(Fi))); c(100 * se / psi0, logdet = log(det(Fi)))
}
designs <- list(rich    = list(list(c(0.5, 1, 2, 4, 8, 12, 24)), 30),
                sparse2 = list(list(c(1, 12)), 30),
                sparse3 = list(list(c(1, 4, 24)), 30),
                sparse2g = list(list(c(1, 12), c(2, 24)), c(15, 15)))   # 두 군, 두 시각씩
out <- t(sapply(designs, function(d) rse_of(d[[1]], d[[2]])))
round(out, 1)
