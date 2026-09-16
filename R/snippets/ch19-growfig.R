# 20마리의 종양 부피. 로그 축에서 직선이면 지수 성장이고, 굽으면 성장률이
# 시간에 따라 떨어지는 것이다. 굽는다. 그래서 지수 모형은 후보에서 빠진다.
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(DV ~ TIME, llc, type = "n", xlab = "이식 후 일수", ylab = expression(부피~(mm^3)),
     main = "선형 축")
for (i in split(llc, llc$ID)) lines(i$TIME, i$DV, col = "#12366966")
plot(DV ~ TIME, llc, type = "n", log = "y", xlab = "이식 후 일수", ylab = "",
     main = "로그 축")
for (i in split(llc, llc$ID)) lines(i$TIME, i$DV, col = "#12366966")
