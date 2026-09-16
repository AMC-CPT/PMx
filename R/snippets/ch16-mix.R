# $MIX 를 넣은 결과. 아집단의 청소율 비 FPM 과 비율 PPM 을 추정하고,
# CL 의 IIV 가 참값 0.09 로 돌아오는지 본다. IOV 도 함께 넣은 123mixiov 가 최종이다.
m2 <- fin("122mix"); m3 <- fin("123mixiov")
key <- c(CL = "THETA2", FPM = "THETA6", PPM = "THETA7", OM_CL = "OMEGA.2.2.",
         PI_CL = "OMEGA.4.4.")
tv <- truth[c("CL", "FPM", "PPM", "OM_CL", "PI_CL")]
get <- function(r) sapply(key, function(k) if (k %in% names(r$f)) r$f[[k]] else NA)
rse <- function(r) sapply(key, function(k) if (k %in% names(r$s)) 100 * r$s[[k]] / abs(r$f[[k]]) else NA)
data.frame(참값 = tv, 혼합 = signif(get(m2), 3), RSE = round(rse(m2), 1),
           혼합_IOV = signif(get(m3), 3), RSE = round(rse(m3), 1), row.names = names(key))
c(OFV_IIV만 = round(b$f[["OBJ"]], 1), OFV_혼합 = round(m2$f[["OBJ"]], 1),
  OFV_IOV = round(v$f[["OBJ"]], 1), OFV_혼합_IOV = round(m3$f[["OBJ"]], 1))

# 누가 어느 아집단인가. MIXEST(표에서는 MEST)와 참값 POP 의 대조.
ca <- read.table(nmf("123mixiov", "catab"), skip = 1, header = TRUE)
ca <- ca[!duplicated(ca$ID), ]
table(참값 = c("정상", "저하")[ca$POP], 추정 = c("정상", "저하")[ca$MEST])
