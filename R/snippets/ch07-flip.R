# 같은 1차 흡수 모형을 자릿수가 틀린 초기값(CL 0.04, V 0.5)으로 돌린 것(110kax).
# 수렴했고 OFV 는 오히려 낮다. 그런데 KA 와 k = CL/V 가 자리를 바꾸었다.
x <- fin("110kax"); o <- fin("110ka")
rbind(옳은자릿수 = c(KA = signif(o[["THETA1"]], 3), CL = signif(o[["THETA2"]], 3),
                     V = signif(o[["THETA3"]], 3), k = signif(o[["THETA2"]] / o[["THETA3"]], 3),
                     OFV = round(o[["OBJ"]], 2)),
      틀린자릿수 = c(KA = signif(x[["THETA1"]], 3), CL = signif(x[["THETA2"]], 3),
                     V = signif(x[["THETA3"]], 3), k = signif(x[["THETA2"]] / x[["THETA3"]], 3),
                     OFV = round(x[["OBJ"]], 2)))
