# full block 을 대각으로 줄이면 공분산 하나가 빠진다. OFV 위계를 본다.
# 중첩된 두 모형이므로 OFV 차이가 근사적으로 카이제곱을 따른다(LRT).
d <- fin("101diag")
dOFV <- d[["OBJ"]] - b[["OBJ"]]

c(full = round(b[["OBJ"]], 2), diag = round(d[["OBJ"]], 2),
  dOFV = round(dOFV, 2), df = 1)
c(p = signif(pchisq(dOFV, df = 1, lower.tail = FALSE), 3))

# 대각으로 물러서면 두 분산이 어떻게 달라지는가.
round(rbind(full = b[c("OMEGA.1.1.", "OMEGA.2.2.")],
            diag = d[c("OMEGA.1.1.", "OMEGA.2.2.")]), 4)
