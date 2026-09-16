# 동시 적합(wf201)과 IPP(wf200)를 나란히 놓는다. PD 모수만 견준다.
# 벽시계 시간은 runnm.R 이 nmfe.log 끝에 적어 둔 것이다.
wall <- function(m) as.numeric(sub("wall seconds: ", "",
                    grep("wall seconds", readLines(nmf(m, "nmfe.log")), value = TRUE)))
si <- fin("wf201")
key2 <- c(BASE = "THETA4", KOUT = "THETA5", C50 = "THETA6", 가법SD = "THETA8",
          OM_BASE = "OMEGA.4.4.", OM_KOUT = "OMEGA.5.5.", OM_C50 = "OMEGA.6.6.")
key1 <- c(BASE = "THETA1", KOUT = "THETA2", C50 = "THETA3", 가법SD = "THETA4",
          OM_BASE = "OMEGA.1.1.", OM_KOUT = "OMEGA.2.2.", OM_C50 = "OMEGA.3.3.")
data.frame(참값 = signif(truth[c("BASE", "KOUT", "C50", "ADDPD", "OM_BASE", "OM_KOUT", "OM_C50")], 3),
           IPP = signif(pd$f[key1], 3), RSE = round(100 * pd$s[key1] / abs(pd$f[key1]), 1),
           동시 = signif(si$f[key2], 3), RSE = round(100 * si$s[key2] / abs(si$f[key2]), 1),
           row.names = names(key1))
c(OFV_PK = round(pk$f[["OBJ"]], 1), OFV_IPP = round(pd$f[["OBJ"]], 1),
  합 = round(pk$f[["OBJ"]] + pd$f[["OBJ"]], 1), OFV_동시 = round(si$f[["OBJ"]], 1))
c(초_PK = wall("wf100"), 초_IPP = wall("wf200"), 초_동시 = wall("wf201"))
