# 전체 조건수 하나로는 어느 모수가 문제인지 알 수 없다. 블록으로 나눈다.
# 가르는 기준은 **통계적 역할**이다. THETA 인가 OMEGA 인가가 아니다.
#   구조: 전형 PK 모수와 공변량 계수         (THETA1, THETA2)
#   변이: OMEGA, SIGMA, 그리고 THETA 에 저장된 잔차오차 모수
blocks <- function(C) {
  st <- c("THETA1", "THETA2")
  va <- setdiff(rownames(C), st)
  th <- grep("^THETA", rownames(C), value = TRUE)
  c(전체 = kap(C), 구조 = kap(C[st, st]), 변이 = kap(C[va, va]),
    THETA블록 = kap(C[th, th]))
}
round(blocks(C), 2)
