# =====================================================================
#  R/mkdata/make_sdtm.R
#
#  5장의 실습 자료를 만든다. 공개 자료인 phenobarbital 신생아 자료
#  (Beal & Sheiner, NONMEM 배포 예제)를 출발점으로 삼아, 그것을 **거꾸로
#  분해하여** SDTM 형 원천 도메인(DM/EX/PC/VS/LB)을 만든다.
#
#  왜 이렇게 하는가.
#    5장은 흩어진 도메인을 합쳐 가는 과정을 가르치는데, 공개 자료는 이미
#    합쳐진 NONMEM 데이터셋뿐이다. 분해해서 다시 합치게 하면 **정답을 알고
#    있는 자료**가 되어, 독자가 자기 파이프라인이 옳은지 스스로 검증할 수 있다.
#    이 책의 "참값을 아는 자료로 시험한다"는 방침과 같다.
#
#  분해하면서 5장이 가르칠 문제를 의도적으로 심는다.
#    (1) 체중이 DM 이 아니라 VS 에 있고, 방문마다 측정되어 시변이다
#    (2) 계획채혈시각(PC)과 실채혈시각(PC_COLL)이 다르다
#    (3) 검사치에 검열값 "<0.2" 가 문자열로 들어 있다
#    (4) 검사 정상상한이 기관마다 다르고 단위 표기도 다르다
#    (5) 투여 전 채혈 레코드(DV=0)가 들어 있다
#    (6) 시험마다 열 이름과 구분자가 다르다
#
#  실행:  Rscript R/mkdata/make_sdtm.R
#  산출:  data/pheno.csv          (정답 데이터셋)
#         data/sdtm/*.csv         (원천 도메인)
#
#  주의: SDTM 도메인은 **이 책이 만든 가공물**이다. 실제 임상시험 자료가
#        아니며, 원 자료의 출처는 data/README.md 에 밝힌다.
# =====================================================================

set.seed(20260914)
RNGkind()   # 재현에 필요한 세 값을 콘솔에 남긴다

OUT <- "data"
dir.create(file.path(OUT, "sdtm"), recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------
# 1. 원본 읽기: 마지막 FIN 표지를 걷어낸다
#
#    원본은 NONMEM 기본 설치의 util/PHENO 다(버전이 다르면 nm75g64 등).
#    없으면 이미 커밋된 data/pheno.csv 로 대신한다. 그 파일은 아래 write.csv
#    가 만든 것이라 내용이 같고, 그래서 **NONMEM 이 없는 PC 에서도 이 스크립트
#    전체가 돈다.** 실제로 다시 돌릴 일은 없다(산출물이 커밋되어 있다).
# ---------------------------------------------------------------------
SRC <- c("C:/nm76g64/util/PHENO", "C:/nm75g64/util/PHENO", "data/PHENO")
SRC <- SRC[file.exists(SRC)]

if (length(SRC)) {
  message("원본: ", SRC[1])
  ln <- readLines(SRC[1])
  ln <- ln[nzchar(trimws(ln)) & !grepl("FIN", ln)]
  d <- read.table(text = ln, header = FALSE, na.strings = ".",
                  col.names = c("ID", "TIME", "AMT", "WT", "APGR", "DV", "MDV", "EVID"))
} else {
  message("원본(util/PHENO)이 없다. 커밋된 data/pheno.csv 로 대신한다.")
  d <- read.csv(file.path(OUT, "pheno.csv"), na.strings = ".")
}
stopifnot(nrow(d) == 744, length(unique(d$ID)) == 59, sum(d$MDV == 0) == 155)

write.csv(d, file.path(OUT, "pheno.csv"), row.names = FALSE, na = ".")
message("data/pheno.csv  (정답): ", nrow(d), "행 / ", length(unique(d$ID)), "명")

# ---------------------------------------------------------------------
# 2. 시간축을 날짜시각으로 되돌린다
#    TIME 은 첫 투약부터의 시간(h). 대상자마다 다른 날 입원했다고 둔다.
# ---------------------------------------------------------------------
ids <- sort(unique(d$ID))
start0 <- as.POSIXct("2026-01-05 08:00", tz = "UTC")
subj_start <- setNames(start0 + (seq_along(ids) - 1) * 86400 * 3, ids)

d$DTC <- subj_start[as.character(d$ID)] + d$TIME * 3600
fmt <- function(x) format(x, "%Y-%m-%dT%H:%M")

# USUBJID 와 기관: 3개 기관에 나누어 배정한다
site <- setNames(sprintf("%02d", (ids - 1) %% 3 + 1), ids)
usub <- setNames(sprintf("PHN-%s-%03d", site[as.character(ids)], ids), ids)
d$USUBJID <- usub[as.character(d$ID)]
d$SITEID  <- site[as.character(d$ID)]

# ---------------------------------------------------------------------
# 3. DM: 시험 내내 변하지 않는 것만. 체중은 여기 없다(5장의 핵심)
# ---------------------------------------------------------------------
first <- !duplicated(d$ID)
dm <- data.frame(
  STUDYID  = "PHN-001",
  USUBJID  = d$USUBJID[first],
  SUBJID   = d$ID[first],
  SITEID   = d$SITEID[first],
  SEX      = ifelse(d$ID[first] %% 2 == 0, "F", "M"),
  RACE     = ifelse(d$ID[first] %% 5 == 0, "WHITE", "ASIAN"),
  ARMCD    = "PHENO",
  BRTHDTC  = format(subj_start[as.character(d$ID[first])] - 86400 * 2, "%Y-%m-%d"),
  RFSTDTC  = fmt(d$DTC[first]),
  APGAR    = d$APGR[first],       # 출생 시 1회 측정이라 DM 에 둔다
  stringsAsFactors = FALSE
)
write.csv(dm, file.path(OUT, "sdtm/dm.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 4. EX: 투약 기록
# ---------------------------------------------------------------------
e <- d[d$EVID == 1, ]
ex <- data.frame(
  STUDYID = "PHN-001", USUBJID = e$USUBJID,
  EXTRT   = "PHENOBARBITAL",
  EXDOSE  = e$AMT, EXDOSU = "mg",
  EXROUTE = "INTRAVENOUS",
  EXSTDTC = fmt(e$DTC), EXENDTC = fmt(e$DTC),
  stringsAsFactors = FALSE
)
write.csv(ex, file.path(OUT, "sdtm/ex.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 5. PC: 농도. 계획시각으로 기록된다(실채혈시각은 따로)
#    투여 전 0 레코드를 심는다: 외인성 약물이므로 선험적으로 0 이다.
# ---------------------------------------------------------------------
o <- d[d$MDV == 0, ]
LLOQ <- 2.0
pc_main <- data.frame(
  USUBJID = o$USUBJID,
  PCTESTCD = "PHENO", PCTEST = "Phenobarbital",
  # 계획시각은 30분 눈금으로 기록된다 (참값에서 최대 15분 어긋난다)
  PCDTC = fmt(as.POSIXct(round(as.numeric(o$DTC) / 1800) * 1800,
                         origin = "1970-01-01", tz = "UTC")),
  ACTDTC = fmt(o$DTC),            # 실채혈시각 = 참값. pc_coll 로만 내보낸다
  PCSTRESN = o$DV, PCSTRESU = "mg/L", PCLLOQ = LLOQ,
  PCSTAT = "", PCREASND = "",
  stringsAsFactors = FALSE
)
# 투여 전 채혈: 각 대상자의 첫 투약 시각에 DV=0 (계획과 실제가 같다)
pre <- data.frame(
  USUBJID = dm$USUBJID,
  PCTESTCD = "PHENO", PCTEST = "Phenobarbital",
  PCDTC = fmt(d$DTC[first]), ACTDTC = fmt(d$DTC[first]),
  PCSTRESN = 0, PCSTRESU = "mg/L", PCLLOQ = LLOQ,
  PCSTAT = "", PCREASND = "PREDOSE",
  stringsAsFactors = FALSE
)
pc <- rbind(pre, pc_main)
pc <- pc[order(pc$USUBJID, pc$PCDTC), ]

# 실채혈시각은 별도 도메인에 있고 **그것이 참값이다**. PC 의 시각은 30분 눈금으로
# 반올림된 계획시각일 뿐이다. 그래서 5장의 조립이 실채혈시각을 쓰면 pheno.csv 와
# 정확히 일치하고, 계획시각을 쓰면 최대 15분 어긋난다. 차이를 눈으로 볼 수 있다.
coll <- data.frame(
  USUBJID = pc$USUBJID, PCTESTCD = pc$PCTESTCD,
  PCDTC_PLANNED = pc$PCDTC, PCDTC_ACTUAL = pc$ACTDTC,
  stringsAsFactors = FALSE
)
write.csv(coll, file.path(OUT, "sdtm/pc_coll.csv"), row.names = FALSE)

pc$ACTDTC <- NULL
write.csv(pc, file.path(OUT, "sdtm/pc.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 6. VS: 체중. 방문마다 측정되어 시변이다. 기저값이 원자료의 WT 와 같다.
#    탭 구분에 열 이름도 다르게 두어 5장에서 손보게 한다.
# ---------------------------------------------------------------------
wt0 <- setNames(d$WT[first], d$ID[first])
vs <- do.call(rbind, lapply(ids, function(i) {
  rng <- range(d$TIME[d$ID == i])
  vt <- unique(c(0, seq(0, rng[2], by = 72)))            # 3일마다
  gain <- 1 + 0.004 * (vt / 24)                          # 신생아 체중 증가
  data.frame(USUBJID = unname(usub[as.character(i)]),
             VISIT = ifelse(vt == 0, "DAY 1", paste0("DAY ", round(vt / 24) + 1)),
             VSTESTCD = "WEIGHT",
             VSDTC = fmt(subj_start[as.character(i)] + vt * 3600),
             VSORRES = unname(round(wt0[as.character(i)] * gain, 2)),
             VSORRESU = "kg", stringsAsFactors = FALSE)
}))
write.table(vs, file.path(OUT, "sdtm/vs.txt"), sep = "\t",
            row.names = FALSE, quote = FALSE)

# ---------------------------------------------------------------------
# 7. LB: 혈청 크레아티닌. 검열값과 기관별 정상상한을 심는다.
# ---------------------------------------------------------------------
lb <- do.call(rbind, lapply(ids, function(i) {
  rng <- range(d$TIME[d$ID == i])
  lt <- unique(c(0, seq(0, rng[2], by = 96)))
  v <- round(pmax(0.1, rnorm(length(lt), 0.35, 0.12)), 2)
  orres <- ifelse(v < 0.2, "<0.2", format(v, trim = TRUE))  # 검열값은 문자열
  data.frame(USUBJID = unname(usub[as.character(i)]),
             SITEID = unname(site[as.character(i)]),
             LBTESTCD = "CREAT",
             LBDTC = fmt(subj_start[as.character(i)] + lt * 3600),
             LBORRES = orres,
             LBORRESU = unname(ifelse(site[as.character(i)] == "03", "umol/L", "mg/dL")),
             stringsAsFactors = FALSE)
}))
# 기관 03 은 단위가 달라 값도 그 단위로 기록되어 있다 (1 mg/dL = 88.4 umol/L)
i3 <- lb$SITEID == "03" & lb$LBORRES != "<0.2"
lb$LBORRES[i3] <- format(round(as.numeric(lb$LBORRES[i3]) * 88.4, 1), trim = TRUE)
lb$LBORRES[lb$SITEID == "03" & lb$LBORRES == "<0.2"] <- "<17.7"
write.csv(lb, file.path(OUT, "sdtm/lb.csv"), row.names = FALSE)

# 기관별 정상상한: 값도 단위도 다르다
lbnorm <- data.frame(
  SITEID = c("01", "02", "03"), LBTESTCD = "CREAT",
  LBORNRLO = c(0.10, 0.10, 8.8), LBORNRHI = c(0.50, 0.60, 53.0),
  LBORRESU = c("mg/dL", "mg/dL", "umol/L"), stringsAsFactors = FALSE
)
write.csv(lbnorm, file.path(OUT, "sdtm/lb_norm.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
message("\ndata/sdtm/ 생성:")
for (f in list.files(file.path(OUT, "sdtm"), full.names = TRUE)) {
  message(sprintf("  %-16s %5d행", basename(f),
                  length(readLines(f)) - 1L))
}
message("\n정답 대조용: data/pheno.csv (", nrow(d), "행)")
