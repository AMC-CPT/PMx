# =====================================================================
#  R/sse.R  -  설계 비교를 위한 모의-추정(SSE, 22장).  라이선스가 있는 PC 에서만.
#  저장소 최상위에서 실행:   Rscript R/sse.R [반복횟수]
#
#  같은 모형(1구획 경구, 참값을 안다)에서 세 채혈 설계로 자료를 만들고, 각각을
#  NONMEM 으로 추정한다. 설계마다 100번. 추정치의 흩어짐(경험적 SE)이 그 설계의
#  정보이고, 22장이 이것을 Fisher 정보행렬로 예측한 SE 와 견준다.
#
#    rich    30명, 0.5 1 2 4 8 12 24 h  (7점)
#    sparse2 30명, 1, 12 h              (2점)
#    sparse3 30명, 1, 4, 24 h           (3점. 정보행렬이 고른 시각)
#
#  결과는 nm/sse/sse.csv 하나로 남는다. 제어파일은 nm/sse.ctl (data/_sse.csv 를 읽는다).
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
NREP <- as.integer(c(commandArgs(trailingOnly = TRUE), "100")[1])

TRUE_PAR <- c(KA = 1.2, CL = 4, V = 50, ADD = 0.05, PROP = 0.12)
OMEGA <- c(KA = 0.16, CL = 0.09, V = 0.04)
DESIGNS <- list(rich = c(0.5, 1, 2, 4, 8, 12, 24), sparse2 = c(1, 12), sparse3 = c(1, 4, 24))
n <- 30; dose <- 100

make_data <- function(tt) {
  rows <- list()
  for (i in seq_len(n)) {
    eta <- rnorm(3, 0, sqrt(OMEGA))
    ka <- TRUE_PAR["KA"] * exp(eta[1]); cl <- TRUE_PAR["CL"] * exp(eta[2]); v <- TRUE_PAR["V"] * exp(eta[3])
    ke <- cl / v
    f <- dose * ka / (v * (ka - ke)) * (exp(-ke * tt) - exp(-ka * tt))
    y <- pmax(f * (1 + TRUE_PAR["PROP"] * rnorm(length(tt))) + TRUE_PAR["ADD"] * rnorm(length(tt)), 0.01)
    rows[[length(rows) + 1]] <- data.frame(ID = i, TIME = c(0, tt), AMT = c(dose, rep(0, length(tt))),
                                           DV = c(NA, round(y, 3)), MDV = c(1L, rep(0L, length(tt))),
                                           EVID = c(1L, rep(0L, length(tt))))
  }
  do.call(rbind, rows)
}
read_run <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".ext"))
  if (!file.exists(f)) return(NULL)
  e <- read.table(f, skip = 1, header = TRUE)
  x <- e[e$ITERATION == -1000000000, ]
  list(OFV = x$OBJ, KA = x$THETA1, CL = x$THETA2, V = x$THETA3, ADD = x$THETA4, PROP = x$THETA5,
       OM_KA = x$OMEGA.1.1., OM_CL = x$OMEGA.2.2., OM_V = x$OMEGA.3.3.)
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

dir.create("nm/sse", showWarnings = FALSE)
set.seed(20260923)
RNGkind()
cols <- c("OFV", "KA", "CL", "V", "ADD", "PROP", "OM_KA", "OM_CL", "OM_V")
res <- expand.grid(REP = seq_len(NREP), DESIGN = names(DESIGNS), stringsAsFactors = FALSE)
for (k in cols) res[[k]] <- NA_real_
res$TERM <- NA_character_
t0 <- Sys.time()
for (r in seq_len(nrow(res))) {
  d <- make_data(DESIGNS[[res$DESIGN[r]]])
  write.csv(d, "data/_sse.csv", row.names = FALSE, quote = FALSE, na = ".")
  suppressWarnings(system2("Rscript", c("R/runnm.R", "sse"), stdout = NULL, stderr = NULL))
  v <- read_run("nm/sse.R76", "sse")
  if (!is.null(v)) for (k in cols) res[[k]][r] <- v[[k]]
  res$TERM[r] <- term_of("nm/sse.R76", "sse")
  if (r %% 20 == 0) message(sprintf("  %3d/%d  경과 %s", r, nrow(res), format(round(Sys.time() - t0))))
}
write.csv(res, "nm/sse/sse.csv", row.names = FALSE, quote = FALSE)
unlink(c("data/_sse.csv", "nm/sse.R76"), recursive = TRUE)
message(sprintf("\n%d회, 산출물 없음 %d회, 총 %s", nrow(res), sum(is.na(res$OFV)), format(round(Sys.time() - t0))))
print(table(res$DESIGN, res$TERM))
message("nm/sse/sse.csv 에 썼다.  다음: Rscript R/build.R")
