# 다듬는 것이 취향의 문제가 아닌 이유. nmw 의 종료 판정이 이렇게 생겼다.
body(MinSuccess)

# 파일 이름까지 정해져 있다. 그래서 그 폴더로 들어가 부른다.
owd <- setwd(RUN)
res <- c(수렴 = MinSuccess(), 표준오차 = SESuccess())
setwd(owd)
res
