# 관측 기저치를 공변량으로 쓴 적합(pd102). 시각 0 의 NRS 를 로짓으로 바꿔 LB 로 썼다.
p2 <- fin("pd102")
key3 <- c(PLMAX = "THETA3", KPL = "THETA4", EMAX = "THETA5", EC50 = "THETA6",
          OM_PLMAX = "OMEGA.3.3.", OM_EC50 = "OMEGA.4.4.")
data.frame(참값 = signif(truth[c("PLMAX", "KPL", "EMAX", "EC50", "OM_PLMAX", "OM_EC50")], 3),
           추정기저치 = signif(r$f[c("THETA4", "THETA5", "THETA6", "THETA7",
                                 "OMEGA.4.4.", "OMEGA.5.5.")], 3),
           관측기저치 = signif(p2$f[key3], 3), row.names = names(key3))
l <- readLines(nmf("pd102", "pd102.lst"), warn = FALSE)
g <- l[max(grep("GRADIENT:", l))]                     # 마지막 반복의 gradient
range(abs(as.numeric(strsplit(trimws(sub(".*GRADIENT:", "", g)), " +")[[1]])))
