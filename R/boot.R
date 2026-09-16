# =====================================================================
#  R/boot.R  -  비모수 bootstrap (14장).  라이선스가 있는 PC 에서만.
#  저장소 최상위에서 실행:   Rscript R/boot.R [반복횟수]
#
#  대상자를 복원추출로 다시 뽑아 같은 모형을 다시 적합한다. 그렇게 얻은
#  추정치 200벌의 흩어짐이 파라미터 불확실성이다. 점근 표준오차와 달리
#  정규성도, 표본이 크다는 것도 가정하지 않는다.
#
#  결과는 nm/boot/boot.csv 하나로 남는다(작다). 그 파일만 있으면 14장의
#  R 코드가 NONMEM 없이 돈다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
NREP <- as.integer(c(commandArgs(trailingOnly = TRUE), "200")[1])

d   <- read.csv("data/pheno-nm.csv", colClasses = c(DAT2 = "character",
                                                    TIME = "character"))
uid <- unique(d$ID)
rec <- split(seq_len(nrow(d)), factor(d$ID, levels = uid))   # 대상자별 행 번호
nrec <- lengths(rec)

dir.create("nm/boot", showWarnings = FALSE)
set.seed(20260916)
RNGkind()                              # 재현에 필요한 세 값 (3장)

#  재표집 단위는 **레코드가 아니라 대상자**다. 한 사람의 관측은 서로
#  독립이 아니므로 레코드를 섞으면 상관 구조가 깨진다.
#
#  그리고 뽑은 뒤에 **번호를 다시 매긴다.** 같은 사람이 두 번 뽑혔을 때
#  원래 ID 를 그대로 두면 NONMEM 은 그것을 한 사람의 레코드로 읽는다.
#  ETA 가 하나만 배정되어 개체간 변동이 과소평가된다(14장의 함정 상자).
make_boot <- function() {
  drawn <- sample(uid, length(uid), replace = TRUE)
  b <- d[unlist(rec[as.character(drawn)]), ]
  b$ID <- rep(seq_along(drawn), nrec[as.character(drawn)])
  rownames(b) <- NULL

  # ---- 뽑은 뒤에 반드시 확인한다 -------------------------------------
  stopifnot(nrow(b) == sum(nrec[as.character(drawn)]),
            length(unique(b$ID)) == length(uid),          # 59명 그대로인가
            !is.unsorted(b$ID),                           # 한 사람이 연속인가
            identical(as.vector(table(b$ID)),
                      as.vector(nrec[as.character(drawn)])))  # 행 수가 맞는가
  list(data = b, drawn = drawn)
}

read_run <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".ext"))
  if (!file.exists(f)) return(NULL)
  e <- read.table(f, skip = 1, header = TRUE)
  x <- e[e$ITERATION == -1000000000, ]
  list(OFV = x$OBJ, T1 = x$THETA1, T2 = x$THETA2, T3 = x$THETA3,
       T4 = x$THETA4, T5 = x$THETA5, T6 = x$THETA6,
       O11 = x$OMEGA.1.1., O21 = x$OMEGA.2.1., O22 = x$OMEGA.2.2.)
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

cols <- c("OFV", paste0("T", 1:6), "O11", "O21", "O22")
res  <- data.frame(REP = seq_len(NREP))
for (k in cols) res[[k]] <- NA_real_
res$NOBS <- NA_integer_      # 재표집마다 관측 수가 다르다
res$NUNIQ <- NA_integer_     # 원래 59명 중 몇 명이 뽑혔는가
res$TERM <- NA_character_

t0 <- Sys.time()
for (i in seq_len(NREP)) {
  bb <- make_boot()
  write.csv(bb$data, "data/_boot.csv", row.names = FALSE, quote = FALSE)
  res$NOBS[i]  <- sum(bb$data$MDV == 0)
  res$NUNIQ[i] <- length(unique(bb$drawn))

  suppressWarnings(system2("Rscript", c("R/runnm.R", "boot"),
                           stdout = NULL, stderr = NULL))
  v <- read_run("nm/boot.R76", "boot")
  if (!is.null(v)) for (k in cols) res[[k]][i] <- v[[k]]
  res$TERM[i] <- term_of("nm/boot.R76", "boot")
  if (i %% 10 == 0)
    message(sprintf("  %3d/%d  경과 %s", i, NREP,
                    format(round(Sys.time() - t0))))
}

write.csv(res, "nm/boot/boot.csv", row.names = FALSE, quote = FALSE)
unlink(c("data/_boot.csv", "nm/boot.R76"), recursive = TRUE)
message(sprintf("\n%d회, 산출물 없음 %d회, 총 %s", NREP, sum(is.na(res$OFV)),
                format(round(Sys.time() - t0))))
print(table(res$TERM, useNA = "ifany"))
message("nm/boot/boot.csv 에 썼다.  다음: Rscript R/build.R")
