# 위약군을 뺀 적합(pd101, 120명)과 160 mg 군만 남긴 적합(pd101b, 40명).
# 같은 모형이다. 참값과 위약군을 넣은 적합(pd100)에 견준다.
p1 <- fin("pd101"); p2 <- fin("pd101b")
key2 <- c(LB = "THETA3", PLMAX = "THETA4", KPL = "THETA5", EMAX = "THETA6", EC50 = "THETA7",
          OM_PLMAX = "OMEGA.4.4.", OM_EC50 = "OMEGA.5.5.")
rse <- function(z) round(100 * z$s[key2] / abs(z$f[key2]), 1)
data.frame(참값 = signif(truth[c("LB", "PLMAX", "KPL", "EMAX", "EC50", "OM_PLMAX", "OM_EC50")], 3),
           위약포함 = signif(r$f[key2], 3), RSE = rse(r),
           투여군만 = signif(p1$f[key2], 3), RSE. = rse(p1),
           한용량만 = signif(p2$f[key2], 3), RSE.. = rse(p2),
           row.names = names(key2))
