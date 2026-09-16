# 완전 모형(tm103), QSS 근사(tm102), Michaelis-Menten(tm104). 세 모형이 같은 자료에
# 같은 FO 로 돌았으므로 OFV 를 견줄 수 있다. 모수 수는 완전 > QSS > MM 이다.
q <- fin("tm102"); mm <- fin("tm104")
rse <- function(z, k) round(100 * z$s[[k]] / abs(z$f[[k]]), 1)
np <- function(z) sum(z$f[grepl("THETA|OMEGA", names(z$f))] != 0)   # 고정한 0 은 빠진다
data.frame(OFV = round(c(r$f[["OBJ"]], q$f[["OBJ"]], mm$f[["OBJ"]]), 1),
           추정모수 = c(np(r), np(q), np(mm)),
           종료 = c(term("tm103")[["종료"]], term("tm102")[["종료"]], term("tm104")[["종료"]]),
           유효숫자 = c(term("tm103")[["유효숫자"]], term("tm102")[["유효숫자"]], term("tm104")[["유효숫자"]]),
           CL_kg = signif(c(r$f[["THETA1"]], q$f[["THETA1"]], mm$f[["THETA1"]]), 3),
           V1_kg = signif(c(r$f[["THETA2"]], q$f[["THETA2"]], mm$f[["THETA2"]]), 3),
           KDEG = c(signif(r$f[["THETA9"]], 3), signif(q$f[["THETA9"]], 3), NA),
           row.names = c("완전(tm103)", "QSS(tm102)", "MM(tm104)"))
# QSS 가 접은 것과 완전 모형이 편 것. 근사의 전제는 복합체가 빨리 평형에 드는 것이다.
c(완전에서_KSS_mg = signif((r$f[["THETA6"]] + r$f[["THETA7"]]) / r$f[["THETA5"]], 3),
  QSS의_KSS_mg = signif(q$f[["THETA5"]], 3), QSS의_KSS_RSE = rse(q, "THETA5"),
  복합체_반감기_h = round(log(2) / (r$f[["THETA6"]] + r$f[["THETA7"]]), 1),
  표적_반감기_h = round(log(2) / r$f[["THETA9"]], 1))
