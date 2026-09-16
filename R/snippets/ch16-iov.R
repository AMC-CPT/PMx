# IOV 를 넣기 전과 후. 모수 둘(IOV 분산 두 개)로 OFV 가 얼마나 내려가고,
# 남은 분산들이 어디로 가는지를 참값과 나란히 본다.
b <- fin("120base"); v <- fin("121iov")
key <- c(KA = "THETA1", CL = "THETA2", V = "THETA3", 가법SD = "THETA4", 비례CV = "THETA5",
         OM_KA = "OMEGA.1.1.", OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3.",
         PI_CL = "OMEGA.4.4.", PI_KA = "OMEGA.7.7.")
tv <- c(truth[c("KA", "CL", "V", "ADD", "PROP", "OM_KA")],
        OM_CL = NA, truth[c("OM_V", "PI_CL", "PI_KA")])   # CL 의 IIV 참값은 아집단이 섞여 하나가 아니다
get <- function(r) sapply(key, function(k) if (k %in% names(r$f)) r$f[[k]] else NA)
rse <- function(r) sapply(key, function(k) if (k %in% names(r$s)) 100 * r$s[[k]] / abs(r$f[[k]]) else NA)
data.frame(참값 = signif(tv, 3), IIV만 = signif(get(b), 3), RSE = round(rse(b), 1),
           IIV_IOV = signif(get(v), 3), RSE = round(rse(v), 1), row.names = names(key))
c(OFV_IIV만 = round(b$f[["OBJ"]], 2), OFV_IOV = round(v$f[["OBJ"]], 2),
  dOFV = round(v$f[["OBJ"]] - b$f[["OBJ"]], 1))
