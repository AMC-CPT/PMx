# 개체간 변이. BLOCK(2) 로 두었으므로 공분산이 하나 더 있다.
Om <- matrix(b[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2,
             dimnames = list(c("ETA1.CL", "ETA2.V"), c("ETA1.CL", "ETA2.V")))
round(Om, 4)

# 분산으로 보면 아무 일도 없어 보인다. 상관으로 바꾸면 보인다.
round(cov2cor(Om), 3)

# 로그정규로 두었으므로 sqrt(분산)이 대략의 개체간 변이(CV)다.
round(sqrt(diag(Om)) * 100, 1)
