# 함정. 3번째 투약 뒤의 프로파일(아직 정상상태가 아니다)을 SS=1 로 적은 130ssx.
# NONMEM 은 SS=1 을 믿고 그 투약이 정상상태라고 계산한다. 그래서 농도가 실제보다 낮은
# 것을 청소율이 큰 것으로 읽는다.
x <- fin("130ssx"); s <- fin("130ss")
rbind(참값 = truth[c("KA", "CL", "V")],
      SS_정상상태 = signif(s$f[c("THETA1", "THETA2", "THETA3")], 3),
      SS_3회뿐 = signif(x$f[c("THETA1", "THETA2", "THETA3")], 3))
# 3회 투약 뒤 축적이 정상상태의 몇 % 인가. 반감기 8.7 h, 간격 12 h.
ke <- truth[["CL"]] / truth[["V"]]
c(축적비_3회 = round((1 - exp(-3 * ke * 12)) / (1 - exp(-ke * 12)), 3),
  축적비_정상상태 = round(1 / (1 - exp(-ke * 12)), 3))
