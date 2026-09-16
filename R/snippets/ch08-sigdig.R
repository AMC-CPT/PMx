# 실행 산출물은 모형마다 제 폴더에 있다: nm/<모형>.R76/ (3장)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# SIGDIG 는 정수가 아니라 실수다. 정의는 상대오차의 -log10 이다.
# 참값 10.000 을 10.001 로 추정했다면 유효숫자는 넷이다.
round(-log10(abs((10.001 - 10.000) / 10.000)), 2)

# 참값을 모르므로 실제로는 인접한 반복 사이의 변화율을 쓴다.
# .ext 의 ITERATION 이 0 이상인 줄이 추정 반복이다(PRINT=5 이므로 다섯 걸음마다).
e  <- read.table(nmf("100base", "100base.ext"), skip = 1, header = TRUE)
it <- e[e$ITERATION >= 0, ]
p  <- paste0("THETA", 1:4)

# 마지막 줄은 최종 추정치를 한 번 더 적은 것이라 앞줄과 같다. 빼고 본다.
it <- it[!duplicated(it[, p]), ]
it[nrow(it) - 1:0, c("ITERATION", p)]

a <- unlist(it[nrow(it) - 1, p])
b <- unlist(it[nrow(it),     p])
round(-log10(abs((b - a) / b)), 2)

# .lst 가 보고한 값은 3.1 이다. 모수마다 2.15 에서 4.55 까지 흩어진다.
# 보고값은 모수 하나하나의 자리수가 아니라, NONMEM 이 **UCP 공간에서** 벡터
# 전체에 대해 정하는 하나의 수이기 때문이다. 둘은 같은 척도의 값이 아니다.
