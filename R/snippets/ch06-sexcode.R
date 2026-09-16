# 범주형 코딩은 사전과 보고서에 산문으로만 적혀 있다. 어떤 계산도 그 문장을
# 소비하지 않으므로, 수치가 전부 옳아도 라벨만 뒤집혀 있을 수 있다.
# 그래서 문서를 문서와 대조하지 않고 **자료에서 코딩을 독립적으로 끌어낸다**.
set.seed(6)
n <- 20
cov <- data.frame(AGE = round(runif(n, 20, 70)), BWT = round(runif(n, 50, 90), 1),
                  SEX = rep(0:1, each = n / 2), CREA = round(runif(n, 0.6, 1.2), 2))

# 의뢰사가 CRCL 열을 함께 보내왔다. 어떤 성별 코딩으로 계산했는지는 적혀 있지 않다.
# (이 한 줄은 설명을 위해 우리가 만들어 넣은 것이다. 실제로는 CRCL 열만 온다.)
cov$CRCL <- with(cov, (140 - AGE) * BWT * ifelse(SEX == 0, 0.85, 1) / (72 * CREA))

# 역산. Cockcroft-Gault 의 여성 계수 0.85 를 뺀 값으로 나누면 둘 중 하나만 나온다.
r <- with(cov, round(CRCL / ((140 - AGE) * BWT / (72 * CREA)), 3))
table(SEX = cov$SEX, 계수 = r)
