# 공변량이 한 일을 OFV 말고 **변이**로 본다. 7장이 남긴 물음의 답이다.
om <- function(m) {
  b <- fin(m)
  M <- matrix(b[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2)
  c(분산.CL = M[1, 1], 분산.V = M[2, 2], 상관 = cov2cor(M)[1, 2])
}
tab <- round(rbind(기저 = om("100base"), 체중 = om("108wt")), 4)
tab

# 체중이 개체간 변이의 얼마를 설명했는가.
round(100 * (1 - tab["체중", 1:2] / tab["기저", 1:2]), 1)

# 지수도 읽는다. 이론값은 CL 0.75, V 1.0 이다.
round(fin("108wt")[c("THETA5", "THETA6")], 3)
