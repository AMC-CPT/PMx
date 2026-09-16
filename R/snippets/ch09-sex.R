# 음성 대조. SEX 는 이 실습 자료에서 **대상자 번호의 홀짝으로 배정한**
# 가짜 공변량이다(data/README.md). 정보가 없다는 것을 우리가 안다.
# 검색 절차가 그것을 걸러 내지 못하면 그 절차를 믿을 수 없다.
drop <- ofv("108wt") - ofv("109sex")          # 넣어서 떨어진 만큼
c(OFV감소 = round(drop, 2), 문턱 = 3.84,
  p = round(pchisq(drop, df = 1, lower.tail = FALSE), 3))

# 효과크기도 함께 본다. 유의하지 않은 데다 크기도 작다.
c(SEX효과 = round(fin("109sex")[["THETA7"]], 3))
