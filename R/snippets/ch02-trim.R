# 행 이름과 값이 다른 줄에 있다. 프린터라면 겹쳐찍혀 한 줄이 되었을 것이다.
# TrimOut() 이 그 일을 대신한다.
library(nmw)
TrimOut(file.path(RUN, "100base.lst"), file.path(RUN, "PRINT.OUT"))

p <- readLines(file.path(RUN, "PRINT.OUT"), warn = FALSE)
c(원본줄 = length(x), 다듬은줄 = length(p),
  원본제어문자 = sum(substr(x, 1, 1) %in% c("1", "0", "+")),
  남은제어문자 = sum(substr(p, 1, 1) %in% c("1", "0", "+")))

j <- grep("OMEGA - COV MATRIX", p)[1]
writeLines(p[j:(j + 7)])
