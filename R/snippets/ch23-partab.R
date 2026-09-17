# 최종 모형의 파라미터 표. 보고서의 그 표를 이 책의 산출물만으로 만든다.
# 점추정치와 RSE 는 .ext 에서, 재표집 구간은 14장의 boot.csv 에서, 가능도 구간은
# 14장의 llp.csv 에서 온다. 어느 구간인지를 열 이름이 말한다.
fin <- unlist(e[e$ITERATION == -1000000000, -1])
se  <- unlist(e[e$ITERATION == -1000000001, -1])
key <- c(T1 = "THETA1", T2 = "THETA2", T3 = "THETA3", T4 = "THETA4",
         T5 = "THETA5", T6 = "THETA6",
         O11 = "OMEGA.1.1.", O21 = "OMEGA.2.1.", O22 = "OMEGA.2.2.")
b  <- read.csv("nm/boot/boot.csv")
bq <- sapply(names(key), function(k) quantile(b[[k]], c(0.025, 0.975)))
p  <- read.csv("nm/llp/llp.csv")
p$dOFV <- p$OFV - fin[["OBJ"]]
p  <- p[p$dOFV >= -0.01, ]; p$dOFV <- pmax(p$dOFV, 0)        # 깨진 점은 뺀다 (14장)
li <- function(z, lv = 2 * log(8)) {                          # 1/8 가능도 구간
  i <- which.min(z$dOFV)
  c(approx(z$dOFV[1:i], z$VALUE[1:i], lv)$y,
    approx(z$dOFV[i:nrow(z)], z$VALUE[i:nrow(z)], lv)$y)
}
lq <- sapply(names(key), function(k)
  if (k %in% p$PAR) li(p[p$PAR == k, ]) else c(NA, NA))

tab <- data.frame(추정치 = fin[key], RSE = 100 * se[key] / abs(fin[key]),
                  boot하 = bq[1, ], boot상 = bq[2, ], LI하 = lq[1, ], LI상 = lq[2, ])
rownames(tab) <- names(key)
signif(tab, 3)

# 개체간 변이 줄에는 셋을 더 적는다. CV, shrinkage, 기저 모형 대비 omega^2 감소분.
pa <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
e0 <- read.table(nmf("100base", "100base.ext"), skip = 1, header = TRUE)
f0 <- unlist(e0[e0$ITERATION == -1000000000, -1])
om <- c("OMEGA.1.1.", "OMEGA.2.2.")
data.frame(row.names = c("CL", "V"), CV = round(100 * sqrt(fin[om]), 1),
           shrinkage = round(100 * (1 - c(sd(pa$ETA1), sd(pa$ETA2)) / sqrt(fin[om])), 1),
           감소분 = round(100 * (1 - fin[om] / f0[om]), 1))
