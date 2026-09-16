# 보고 8종은 **커밋된 산출물만** 읽는다. NONMEM 이 없는 PC 에서도 만들어진다.
# 실행 폴더가 nm/<모형>.R76/ 인 것이 여기서 값을 한다(3장). 모형 이름은
# 폴더 이름에서, 표는 sdtab/patab/cotab/catab 에서, 종료 상태는 PRINT.OUT 에서.
library(nmw)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
RUN <- "nm/108wt.R76"

owd <- setwd(RUN); nmw_run(); setwd(owd)
list.files(RUN, pattern = "(?i)^S.-.*[.]PDF$")
