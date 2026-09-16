# 실행 산출물은 모형마다 제 폴더에 있다: nm/<모형>.R76/ (3장)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# 적합을 보기 전에, 자료가 NONMEM 에 제대로 들어갔는지부터 본다.
# NONMEM 은 DAT2 + TIME 으로 경과시간을 스스로 번역했다(5장). 그 번역이
# 우리가 파생해 둔 TAFD 와 같은가. 이것이 TAFD 를 함께 실어 둔 이유다.
nm <- read.csv("data/pheno-nm.csv",
               colClasses = c(DAT2 = "character", TIME = "character"))
sd <- read.table(nmf("100base", "sdtab"), skip = 1, header = TRUE)

stopifnot(nrow(sd) == nrow(nm))                  # 표가 레코드마다 한 줄인가
c(레코드 = nrow(sd), 최대차이 = max(abs(sd$TIME - nm$TAFD)))
