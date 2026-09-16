# 꼬리가 무엇으로 되어 있는지 본다. 순열마다 남겨 둔 것이 여기서 쓰인다.
rpt$dOFV <- base - rpt$OFV
table(종료 = rpt$TERM)

# dOFV 가 큰 다섯. 지수(T5, T6)는 경계 근처에도 가지 않았다.
top <- head(rpt[order(-rpt$dOFV), ], 5)
with(top, data.frame(REP, dOFV = round(dOFV, 2), T5 = round(T5, 3),
                     T6 = round(T6, 3), TERM))

# 수렴한 것만 골라 다시 견준다.
ok <- rpt$dOFV[rpt$TERM == "SUCCESS"]
round(rbind(전체 = quantile(null, pr), 성공만 = quantile(ok, pr),
            카이제곱 = qchisq(pr, 2)), 2)
c(전체최대 = round(max(null), 2), 성공최대 = round(max(ok), 2))
