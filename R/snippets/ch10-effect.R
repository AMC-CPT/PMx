# 효과크기. 자료에서 실제로 관측된 범위에 걸쳐 파라미터가 몇 배 변하는가.
# p 값은 표본 크기를 함께 담고 있지만, 이 숫자는 담고 있지 않다.
d <- read.csv("data/pheno-nm.csv")
fold <- function(x, expo) (max(x) / min(x))^expo

round(c(체중.최소 = min(d$WT), 체중.최대 = max(d$WT),
        CL배수 = fold(d$WT, est[["THETA5"]]),
        고정하면 = fold(d$WT, 0.75)), 2)

# 유의하지 않았던 둘도 같은 자로 재 본다.
cr <- fin("108wtcr"); sx <- fin("109sex")
round(c(CREA배수 = fold(d$CREA, cr[["THETA7"]]),
        SEX배수  = 1 + sx[["THETA7"]]), 3)

# 견주는 대상은 남아 있는 개체간 변이다.
c(남은변이.CL = round(100 * sqrt(est[["OMEGA.1.1."]]), 1))
