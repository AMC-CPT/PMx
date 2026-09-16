# =====================================================================
#  R/mkdata/make_tgi.R  -  17장의 종양 부피 자료를 NONMEM 데이터셋으로 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_tgi.R
#
#  원 자료는 Benzekry 등(2014)이 논문과 함께 공개한 전임상 자료 3종이다
#  (Ref/growth/dataset/). 세 파일의 구분자와 열 이름이 서로 다르다.
#  이 스크립트가 그것을 한 형식으로 맞춘다. 5장의 작은 복습이다.
#
#    LLC_sc_CCSB.txt       쉼표 구분, 열 Vol.          Lewis lung carcinoma, 피하
#    LM2-4LUC.txt          탭 구분,   열 Observation.  LM2-4LUC1 유방암
#    MDA-MB-231dTomato.txt 탭 구분,   열 Observation.  형광 신호(광자 수)
#
#  결과.
#    data/tgi-llc.csv      ID TIME DV MDV            $PRED 용 (닫힌 식)
#    data/tgi-llc-ode.csv  ID TIME DV MDV EVID      ADVAN13 용. 시각 0 에 빈
#                          레코드(EVID=2)를 하나 둔다. 적분의 초기 조건이
#                          거기서 걸리기 때문이다(17장)
#    data/tgi-lm2.csv, data/tgi-mda.csv   같은 형식 (연습문제)
#  투약이 없으므로 AMT 는 없다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

read_tgi <- function(file, sep, vcol) {
  d <- read.table(file.path("Ref/growth/dataset", file), header = TRUE, sep = sep)
  names(d)[names(d) == vcol] <- "DV"
  d <- d[order(d$ID, d$Time), ]
  data.frame(ID = as.integer(factor(d$ID)), TIME = d$Time, DV = d$DV, MDV = 0L)
}
llc <- read_tgi("LLC_sc_CCSB.txt",       ",",  "Vol")
lm2 <- read_tgi("LM2-4LUC.txt",          "\t", "Observation")
mda <- read_tgi("MDA-MB-231dTomato.txt", "\t", "Observation")

# 0 인 부피는 관측이 아니라 "아직 만져지지 않음"이다. 로그를 취할 수 없고
# 성장 모형의 초기값으로 쓸 수도 없으므로 MDV=1 로 남긴다(5장의 규칙: 지우지
# 않고 표시한다).
for (nm in c("llc", "lm2", "mda")) {
  d <- get(nm)
  d$MDV[d$DV <= 0] <- 1L
  assign(nm, d)
}
# 형광 신호는 자릿수가 커서 그대로 두면 초기값과 경계를 잡기 어렵다.
# 10^8 광자를 단위로 한다. 단위를 바꾼 것이지 자료를 바꾼 것이 아니다.
mda$DV <- mda$DV / 1e8

# ADVAN13 용: 동물마다 시각 0 에 EVID=2 레코드를 하나 앞세운다.
ode <- do.call(rbind, lapply(split(llc, llc$ID), function(z)
  rbind(data.frame(ID = z$ID[1], TIME = 0, DV = 0, MDV = 1L, EVID = 2L),
        data.frame(z, EVID = 0L))))
rownames(ode) <- NULL

dir.create("data", showWarnings = FALSE)
write.csv(llc, "data/tgi-llc.csv",     row.names = FALSE, quote = FALSE)
write.csv(ode, "data/tgi-llc-ode.csv", row.names = FALSE, quote = FALSE)
write.csv(lm2, "data/tgi-lm2.csv",     row.names = FALSE, quote = FALSE)
write.csv(mda, "data/tgi-mda.csv",     row.names = FALSE, quote = FALSE)
for (nm in c("llc", "lm2", "mda")) {
  d <- get(nm)
  cat(sprintf("%s: %d 마리, 관측 %d (MDV=1 %d), 시간 %g-%g 일, 부피 %.3g-%.3g\n",
              nm, length(unique(d$ID)), nrow(d), sum(d$MDV), min(d$TIME), max(d$TIME),
              min(d$DV[d$MDV == 0]), max(d$DV[d$MDV == 0])))
}
