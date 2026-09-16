# 그림에서 본 것을 숫자로 남긴다. 그래야 인용할 수 있다.
c(T3무너짐 = sum(b$T3 < 0.01),
  그중정상종료 = sum(b$T3 < 0.01 & b$TERM == "SUCCESS"))

# 가법과 비례 오차는 서로 메운다. 8장의 조건수가 말한 것이 여기서 보인다.
c(상관 = round(cor(b$T3, b$T4), 2),
  T4중앙_T3작을때 = round(median(b$T4[b$T3 < 0.01]), 3),
  T4중앙_나머지 = round(median(b$T4[b$T3 >= 0.01]), 3))

# 경계에 붙은 벌이 있는가. 제어파일에서 (-20, 20) 으로 넓혀 두었다.
bd <- round(rbind(T5 = range(b$T5), T6 = range(b$T6)), 3)
colnames(bd) <- c("최소", "최대"); bd
