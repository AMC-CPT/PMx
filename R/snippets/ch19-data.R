# Benzekry 등이 공개한 세 자료. 구분자도 열 이름도 서로 다르다.
for (f in c("LLC_sc_CCSB.txt", "LM2-4LUC.txt", "MDA-MB-231dTomato.txt"))
  cat(sprintf("%-22s %s\n", f, readLines(file.path("Ref/growth/dataset", f), n = 1)))

# 한 형식으로 맞춘 것이 data/tgi-*.csv 다(R/mkdata/make_tgi.R).
llc <- read.csv("data/tgi-llc.csv")
c(마리 = length(unique(llc$ID)), 관측 = nrow(llc),
  마리당 = paste(range(table(llc$ID)), collapse = "-"),
  시간 = paste(range(llc$TIME), collapse = "-"),
  부피 = paste(round(range(llc$DV)), collapse = "-"))
