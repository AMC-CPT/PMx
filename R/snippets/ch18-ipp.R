# 2단계. 개인 PK 추정치(EBE)를 자료의 열로 넣고 PD 만 적합한다(IPP, wf200).
# R/mkdata/make_warf_ipp.R 이 wf100 의 patab 에서 data/warf-ipp.csv 를 만들었다.
head(read.csv("data/warf-ipp.csv"), 3)
pd <- fin("wf200")
show(pd, c(BASE = "THETA1", KOUT = "THETA2", C50 = "THETA3", 가법SD = "THETA4",
           OM_BASE = "OMEGA.1.1.", OM_KOUT = "OMEGA.2.2.", OM_C50 = "OMEGA.3.3."),
     truth[c("BASE", "KOUT", "C50", "ADDPD", "OM_BASE", "OM_KOUT", "OM_C50")])
c(OFV = round(pd$f[["OBJ"]], 2),
  회전반감기_h = round(log(2) / pd$f[["THETA2"]], 1))
