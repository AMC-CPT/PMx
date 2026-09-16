# 왼쪽: 한 사람의 7일. trough 셋과 마지막 프로파일, 그리고 130addl 의 개체 예측.
# 오른쪽: 마지막 투약 뒤 시간(TAD)에 대한 30명의 관측. 반복 투여 자료의 잔차 그림은
# 첫 투약 뒤 시간이 아니라 이 축에 그려야 투약 간격 안의 모양이 보인다.
s <- read.table(nmf("130addl", "sdtab"), skip = 1, header = TRUE)
o <- s[s$MDV == 0, ]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
z <- o[o$ID == 1, ]
tt <- seq(0, 170, by = 0.25)
p <- fin("130addl")$f; pa <- read.table(nmf("130addl", "patab"), skip = 1, header = TRUE); pa <- pa[pa$ID == 1, ][1, ]
ke <- pa$CL / pa$V
cp <- sapply(tt, function(t) { td <- (0:13) * 12; td <- td[td <= t]
  sum(100 * pa$KA / (pa$V * (pa$KA - ke)) * (exp(-ke * (t - td)) - exp(-pa$KA * (t - td)))) })
plot(tt, cp, type = "l", col = "#123669", xlab = "첫 투약 뒤 시간 (h)", ylab = "농도 (mg/L)",
     main = "ID 1: 관측과 개체 예측", ylim = c(0, 3.2))
points(z$TIME, z$DV, pch = 16, col = "#B2182B")
o$TAD <- ifelse(o$TIME < 156, o$TIME %% 12, o$TIME - 156)
plot(o$TAD, o$DV, pch = 16, cex = 0.6, col = "#12366966", xlab = "마지막 투약 뒤 시간 (h)",
     ylab = "농도 (mg/L)", main = "30명, TAD 축")
