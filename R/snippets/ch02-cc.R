# NONMEM 의 .lst 는 라인프린터 시대의 FORTRAN 출력이다. 각 줄의 **1열**은
# 글자가 아니라 프린터에 보내는 신호다.
#   '1' 새 쪽,  '0' 두 줄 띄움,  '+' **앞 줄에 겹쳐찍기**,  ' ' 한 줄
# 실행 산출물은 모형마다 제 폴더에 있다: nm/<모형>.R76/ (3장)
RUN <- "nm/100base.R76"
x  <- readLines(file.path(RUN, "100base.lst"), warn = FALSE)
cc <- substr(x, 1, 1)
c(전체 = length(x), 새쪽 = sum(cc == "1"), 두줄 = sum(cc == "0"),
  겹쳐찍기 = sum(cc == "+"), 보통 = sum(cc == " "))

# 겹쳐찍기가 무엇을 하는지는 보면 안다. OMEGA 행렬 자리다.
i <- grep("OMEGA - COV MATRIX", x)[1]
writeLines(x[i:(i + 9)])
