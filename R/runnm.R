# =====================================================================
#  R/runnm.R  -  NONMEM 을 실제로 돌린다.  라이선스가 있는 PC 에서만.
#  저장소 최상위에서 실행:   Rscript R/runnm.R [모델이름 ...]
#
#  이 저장소의 규칙은 하나다.
#
#      NONMEM 실행 = 이 스크립트.        라이선스가 필요하다.
#      R 실행      = R/build.R.          NONMEM 이 없어도 돈다.
#
#  실행 산출물(.lst .ext .phi 와 표 네 개)은 **커밋되어 있다.** 그래서
#  라이선스가 없는 PC 에서도 R/build.R 과 책 빌드가 그대로 돈다.
#  제어파일이나 자료를 고쳤을 때만 라이선스가 있는 PC 에서 이것을 돌린다.
# =====================================================================
if (!file.exists("PMx.tex"))
  stop("저장소 최상위에서 실행하라 (PMx.tex 가 있는 곳).")

NMDIR <- "nm"

#  실행 폴더(nm/<모형>.R76/)를 **그대로 남긴다.** nmw 의 후처리가 그 구조를
#  전제하기 때문이다. 모형 이름은 폴더 이름의 첫 마디에서 나오고(GetCurModelName),
#  표는 번호 없이 sdtab/patab/cotab/catab 여야 하며(CTL_Style_Guide 15절),
#  보고 8종은 .xml, .phi, .grd, PRINT.OUT, FDATA.CSV 를 읽는다.
#  아래 목록에 없는 것은 전부 중간 파일이므로 지운다(nonmem.exe 가 30 MB 다).
KEEP <- function(model) c(
  paste0(model, c(".ctl", ".lst", ".ext", ".xml", ".phi", ".grd",
                  ".cov", ".cor", ".coi")),
  "sdtab", "patab", "cotab", "catab",     # nmw 호환 표준 4종
  "simtab.csv",                           # $SIM 전용 실행의 모의 표 (12장)
  "FCON",                                 # SumOut 이 P:/F: 를 여기서 읽는다
  "PRINT.OUT",                            # TrimOut 산출 (2장)
  "FDATA.csv",                            # NONMEM 이 쓰는 자료 사본
  "nmfe.log")

# ---- nmfe 를 찾는다. 없으면 여기서 끝난다 ----------------------------
find_nmfe <- function() {
  cand <- c("C:/nm76g64/run/nmfe76.bat", "C:/nm75g64/run/nmfe75.bat",
            Sys.getenv("NMFE", ""))
  cand <- cand[nzchar(cand) & file.exists(cand)]
  if (!length(cand)) return(NA_character_)
  cand[1]
}

NMFE <- find_nmfe()
if (is.na(NMFE)) {
  message("NONMEM 을 찾지 못했다. 이 PC 에서는 실행할 수 없다.\n",
          "  실행 산출물은 nm/ 에 커밋되어 있으므로 Rscript R/build.R 은\n",
          "  그대로 돈다. 제어파일을 고쳤다면 라이선스가 있는 PC 에서 돌려라.")
  quit(save = "no", status = 0)     # 실패가 아니다. 할 일이 없을 뿐이다
}
message("nmfe: ", NMFE)

# ---- 라이선스 등록자 문자열을 지운다 ---------------------------------
#  NONMEM 출력 머리에 라이선스 등록자와 만료일이 박힌다. 공개 저장소
#  (PUBLIC.md)로 나갈 수 있으므로 **생성하는 자리에서** 지운다. 그래야
#  git 이력에 한 번도 들어가지 않는다.
scrub <- function(f) {
  if (!file.exists(f)) return(invisible())
  x <- readLines(f, warn = FALSE)
  x <- sub("(?i)^(\\s*License(d| Registered)? ?(to)?:).*$", "\\1 <LICENSEE>",
           x, perl = TRUE)
  x <- sub("(?i)^(\\s*Expiration Date:).*$",  "\\1 <DATE>", x, perl = TRUE)
  x <- sub("(?i)^(\\s*Current Date:).*$",     "\\1 <DATE>", x, perl = TRUE)
  x <- sub("(?i)^(\\s*Days until program expires).*$", "\\1 : <N>", x, perl = TRUE)

  # 실행 시각과 경과 초는 돌릴 때마다 달라진다. 추정 결과는 한 비트도 바뀌지
  # 않는데 파일은 바뀌므로, 그대로 두면 nm/ 의 diff 가 신호 노릇을 못 한다.
  # 지워 두면 **diff 가 나면 진짜로 무엇인가 달라진 것**이다.
  # (R/_freeze.R 이 nlr() 의 $`Elapsed Time` 을 지우는 것과 같은 이유다.)
  x <- sub("^\\d{4}-\\d{2}-\\d{2}\\s*$", "<DATE>", x)
  x <- sub("^\\d{2}:\\d{2}\\s*$",        "<TIME>", x)
  x <- sub("^(\\s*Elapsed \\w+\\s+time in seconds:).*$", "\\1 <SEC>", x, perl = TRUE)
  x <- sub("^(\\s*#CPUT: Total CPU Time in Seconds,).*$", "\\1 <SEC>", x, perl = TRUE)
  writeLines(x, f)
}

# ---- 모델 하나를 돌린다 ----------------------------------------------
run_one <- function(model) {
  stopifnot(file.exists(file.path(NMDIR, paste0(model, ".ctl"))))
  nmfe <- normalizePath(NMFE)

  # NONMEM 은 nm/ 아래 작업 폴더에서 돌린다(Analects 3). 그래서 제어파일의
  # $DATA 는 거기서 두 단계 위를 가리킨다: ../../data/...
  owd <- setwd(NMDIR); on.exit(setwd(owd), add = TRUE)
  # nmfe 는 작업 폴더로 들어간 뒤 그 안에서 제어파일을 찾는다("Make sure
  # directory exists with all necessary input files"). 그래서 먼저 복사한다.
  rundir <- paste0(model, ".R76")
  unlink(rundir, recursive = TRUE)
  dir.create(rundir)
  file.copy(paste0(model, ".ctl"), rundir)

  # nmfe 는 작업 폴더에 gfcompile.bat 을 만들어 `call gfcompile.bat` 한다.
  # NoDefaultCurrentDirectoryInExePath 가 켜져 있으면 cmd 가 현재 폴더의
  # 배치파일을 찾지 않아 "is not recognized" 로 선다(일부 보안 정책과 일부
  # 셸이 이것을 켠다). 배치파일 안에서라면 `call .\gfcompile.bat` 로 고치지만,
  # 우리는 nmfe 를 고치지 않으므로(nm/README.md) 밖에서 변수를 해제한다.
  Sys.unsetenv("NoDefaultCurrentDirectoryInExePath")

  message("\n== ", model, " ", strrep("-", 50))
  t0 <- Sys.time()
  st <- system2(nmfe, c(paste0(model, ".ctl"), paste0(model, ".lst"),
                        paste0("-rundir=", rundir)),
                stdout = TRUE, stderr = TRUE)
  # 벽시계 시간. .lst 의 경과 시간은 scrub() 이 지우므로(diff 를 위해) 여기 남긴다.
  # 8장이 추정 방법의 비용을 견줄 때 이 줄을 읽는다.
  wall <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
  writeLines(c(st, sprintf("wall seconds: %.1f", wall)), file.path(rundir, "nmfe.log"))

  # ---- 후처리의 입구를 만든다 (2장) -----------------------------------
  #  PRINT.OUT 은 제어문자를 다듬은 출력이다. nmw 의 종료 판정이 이 **이름**을
  #  찾으므로 실행 폴더 안에 만들어 둔다. FDATA.csv 는 NONMEM 이 스스로 쓴다.
  lst <- file.path(rundir, paste0(model, ".lst"))
  if (file.exists(lst) && requireNamespace("nmw", quietly = TRUE))
    try(nmw::TrimOut(lst, file.path(rundir, "PRINT.OUT")), silent = TRUE)

  # ---- 모의 표를 정리한다 (12장) --------------------------------------
  #  NONMEM 은 재현마다 머리글을 새로 쓰고 투약 레코드까지 모두 적어 파일이
  #  8 MB 가 된다. VPC 가 쓰는 것은 **관측 레코드**뿐이므로 그것만 남기고
  #  REP 번호를 붙인 CSV 로 바꾼다(1 MB 아래로 내려간다).
  #  중간 파일을 지우기 **전에** 해야 한다. 원본 simtab 은 남기지 않는다.
  ctl <- readLines(paste0(model, ".ctl"), warn = FALSE)
  simonly <- any(grepl("^[$]SIM", ctl)) && !any(grepl("^[$]EST", ctl))
  raw <- file.path(rundir, "simtab")
  if (simonly && file.exists(raw)) {
    x   <- readLines(raw, warn = FALSE)
    hdr <- grepl("^TABLE NO", x)
    col <- grepl("^ +ID", x)
    nms <- strsplit(trimws(x[which(col)[1]]), "[ ]+")[[1]]     # 표의 머리글에서 열 이름을 읽는다
    d   <- read.table(text = x[!hdr & !col], col.names = nms)
    d$REP <- rep(seq_len(sum(hdr)), each = nrow(d) / sum(hdr))
    d <- d[d$MDV == 0, c("REP", setdiff(nms, "MDV"))]
    write.csv(d, file.path(rundir, "simtab.csv"), row.names = FALSE, quote = FALSE)
    message(sprintf("  SIMULATION %d회, 관측 %d행", sum(hdr), nrow(d)))
  }

  # ---- 중간 파일을 지우고 남을 것만 다듬는다 ---------------------------
  #  Windows 는 파일 이름의 대소문자를 가리지 않는다. NONMEM 은 FDATA.csv 를
  #  소문자로 쓰는데 nmw 는 FDATA.CSV 로 찾으므로, 비교도 대소문자를 무시한다.
  keep <- toupper(KEEP(model))
  have <- list.files(rundir)
  for (f in have[!toupper(have) %in% keep])
    unlink(file.path(rundir, f), recursive = TRUE)
  for (f in have[toupper(have) %in% keep]) scrub(file.path(rundir, f))
  unlink("trash.tmp")

  if (simonly) {
    ok <- file.exists(file.path(rundir, "simtab.csv"))
    if (!ok) message("  ** 모의 표가 없다. .lst 를 보라")
  } else {
    #  gradient 계열은 MINIMIZATION SUCCESSFUL, EM 계열과 BAYES 는 다른 말로 끝난다.
    ok <- file.exists(lst) &&
          any(grepl("MINIMIZATION SUCCESSFUL|WAS NOT TESTED FOR CONVERGENCE|WAS COMPLETED",
                    readLines(lst, warn = FALSE)))
    message(if (ok) "  MINIMIZATION SUCCESSFUL" else "  ** 수렴하지 않았다. .lst 를 보라")
  }
  invisible(ok)
}

models <- commandArgs(trailingOnly = TRUE)
if (!length(models)) {
  models <- sub("\\.ctl$", "", basename(list.files(NMDIR, "\\.ctl$")))
  # 이름 없이 전체를 돌릴 때 빼는 것이 둘 있다.
  #   rpt, boot : 임시 자료로만 돌아간다 (R/rpt.R, R/boot.R)
  #   _ 로 시작 : 스크립트가 만들어 낸 것이다 (R/llp.R)
  models <- setdiff(models, c("rpt", "boot"))
  models <- models[!startsWith(models, "_")]
}

for (m in models) run_one(m)
message("\ndone.  다음: Rscript R/build.R")
