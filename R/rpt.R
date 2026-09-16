# =====================================================================
#  R/rpt.R  -  무작위 순열 검정 (13장).  라이선스가 있는 PC 에서만.
#  저장소 최상위에서 실행:   Rscript R/rpt.R [반복횟수]
#
#  체중을 대상자들 사이에서 무작위로 섞은 뒤 같은 공변량 모형을 다시 적합하여
#  dOFV 의 귀무분포를 만든다. 섞었으므로 체중은 아무 정보도 갖지 않는다.
#  거기서 나오는 dOFV 가 우연으로 얻을 수 있는 크기다.
#
#  결과는 nm/rpt/rpt.csv 하나로 남는다(작다). 그 파일만 있으면 13장의
#  R 코드가 NONMEM 없이 돈다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
NREP <- as.integer(c(commandArgs(trailingOnly = TRUE), "200")[1])

d <- read.csv("data/pheno-nm.csv", colClasses = c(DAT2 = "character",
                                                  TIME = "character"))
uid <- unique(d$ID)
wt  <- d$WT[match(uid, d$ID)]          # 대상자마다 하나. 시불변이다
stopifnot(length(wt) == length(uid), !anyNA(wt))

dir.create("nm/rpt", showWarnings = FALSE)
set.seed(20260915)
RNGkind()                              # 재현에 필요한 세 값 (3장)

#  순열마다 무엇을 남길지 미리 정한다. OFV 만 남기면 나중에 귀무분포의
#  꼬리가 왜 무거운지 물을 수 없다(13장). 지수와 종료 상태를 함께 적는다.
read_run <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".ext"))
  if (!file.exists(f)) return(list(OFV = NA_real_, T5 = NA_real_, T6 = NA_real_))
  e <- read.table(f, skip = 1, header = TRUE)
  x <- e[e$ITERATION == -1000000000, ]
  list(OFV = x$OBJ, T5 = x$THETA5, T6 = x$THETA6)
}
term_of <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".lst"))
  if (!file.exists(f)) return("NO OUTPUT")
  x <- readLines(f, warn = FALSE)
  if (any(grepl("MINIMIZATION SUCCESSFUL", x)))       "SUCCESS"
  else if (any(grepl("ROUNDING ERRORS", x)))          "ROUNDING"
  else if (any(grepl("MINIMIZATION TERMINATED", x)))  "TERMINATED"
  else                                                "OTHER"
}

res <- data.frame(REP = seq_len(NREP), OFV = NA_real_, T5 = NA_real_,
                  T6 = NA_real_, TERM = NA_character_)
t0  <- Sys.time()
for (i in seq_len(NREP)) {
  # ---- 섞는다 -------------------------------------------------------
  #  ID 가 정렬되어 있다고 가정하지 않는다. match() 는 행 순서를 보존한다.
  #  merge() 는 join key 로 재정렬하므로 섞은 값이 다른 행에 배정된다
  #  (Analects 22.C 의 실제 오류. 13장에서 재현한다).
  perm <- data.frame(ID = uid, WT = sample(wt))
  p <- d
  p$WT <- perm$WT[match(p$ID, perm$ID)]

  # ---- 섞은 뒤에 반드시 확인한다 -------------------------------------
  n1 <- tapply(p$WT, p$ID, function(x) length(unique(x)))
  stopifnot(all(n1 == 1),                                   # 여전히 시불변인가
            identical(sort(unique(p$WT)), sort(unique(d$WT))))  # 값 집합이 같은가

  write.csv(p, "data/_perm.csv", row.names = FALSE, quote = FALSE)
  suppressWarnings(system2("Rscript", c("R/runnm.R", "rpt"),
                           stdout = NULL, stderr = NULL))
  v <- read_run("nm/rpt.R76", "rpt")
  res$OFV[i] <- v$OFV; res$T5[i] <- v$T5; res$T6[i] <- v$T6
  res$TERM[i] <- term_of("nm/rpt.R76", "rpt")
  if (i %% 10 == 0)
    message(sprintf("  %3d/%d  경과 %s", i, NREP,
                    format(round(Sys.time() - t0))))
}

write.csv(res, "nm/rpt/rpt.csv", row.names = FALSE, quote = FALSE)
unlink(c("data/_perm.csv", "nm/rpt.R76"), recursive = TRUE)
message(sprintf("\n%d회, 실패 %d회, 총 %s", NREP, sum(is.na(res$OFV)),
                format(round(Sys.time() - t0))))
message("nm/rpt/rpt.csv 에 썼다.  다음: Rscript R/build.R")
