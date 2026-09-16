# 완전 TMDD 모형. 실무에서 그랬듯 FO 로 돌렸다. tm100 은 표적 합성의 절편(THETA8)이
# 하한에 붙었으므로 그것을 뺀 tm103 이 최종이다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]),
       eig = unlist(e[e$ITERATION == -1000000002, -1]))   # 상관행렬의 고유값
}
r0 <- fin("tm100")
c(tm100_OFV = round(r0$f[["OBJ"]], 2), KSYN절편 = signif(r0$f[["THETA8"]], 3),
  절편의_하한 = 1e-4, BWT기울기 = signif(r0$f[["THETA12"]], 3))
r <- fin("tm103")
key <- c(CL_kg = "THETA1", V1_kg = "THETA2", Q = "THETA3", V2 = "THETA4", KON = "THETA5",
         KOFF = "THETA6", KINT = "THETA7", KDEG = "THETA9", 가법SD = "THETA10",
         비례CV = "THETA11", KSYN_kg = "THETA12")
data.frame(추정 = signif(r$f[key], 3), RSE = round(100 * r$s[key] / abs(r$f[key]), 1),
           row.names = names(key))
eig <- r$eig[grepl("THETA|OMEGA|SIGMA", names(r$eig))]; eig <- eig[eig != 0]
c(OFV = round(r$f[["OBJ"]], 2), 조건수 = round(max(eig) / min(eig)))

# 유도량. 전형 원숭이(4 kg)에서. KD 는 양(mg)으로 추정되었으므로 V1 로 나누어 농도로 옮긴다.
th <- r$f; bwt <- 4
cl <- th[["THETA1"]] * bwt; v1 <- th[["THETA2"]] * bwt
c(선형_반감기_h = round(log(2) * (v1 + th[["THETA4"]]) / cl, 1),
  KD_mgL = signif(th[["THETA6"]] / th[["THETA5"]] / v1, 3),
  표적_반감기_h = round(log(2) / th[["THETA9"]], 1),
  복합체_반감기_h = round(log(2) / (th[["THETA6"]] + th[["THETA7"]]), 1),   # 해리와 내재화가 함께 없앤다
  기저_표적_mg = signif(th[["THETA12"]] * bwt / th[["THETA9"]], 3))
