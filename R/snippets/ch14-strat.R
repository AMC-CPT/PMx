# 층화가 필요한지는 자료가 말해 준다. 단순 재표집이 만드는 성별 구성을 본다.
d   <- read.csv("data/pheno-nm.csv")
uid <- unique(d$ID)
sex <- d$SEX[match(uid, d$ID)]
table(원자료 = sex)

# 재표집 10000벌에서 SEX=1 이 몇 명이 되는가. NONMEM 은 필요 없다.
set.seed(20260916)
m <- replicate(10000, sum(sample(sex, length(sex), replace = TRUE)))
c(원래 = sum(sex), 평균 = round(mean(m), 1),
  round(quantile(m, c(0.025, 0.975))))
