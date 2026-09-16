# =====================================================================
#  R/llp.R  -  로그우도 프로파일 (14장).  라이선스가 있는 PC 에서만.
#  저장소 최상위에서 실행:   Rscript R/llp.R
#
#  모수 하나를 격자 위의 값에 고정하고 **나머지는 전부 다시 추정**한다.
#  그렇게 얻은 OFV 곡선이 프로파일 우도다. dOFV 가 3.84 가 되는 자리가
#  95 % 신뢰구간의 끝이다(자유도 1).
#
#  결과는 nm/llp/llp.csv 하나로 남는다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

e   <- read.table("nm/108wt.R76/108wt.ext", skip = 1, header = TRUE)
fin <- e[e$ITERATION == -1000000000, ]
se  <- e[e$ITERATION == -1000000001, ]

#  격자는 점근 표준오차를 자로 삼아 놓는다. 정규 근사가 맞다면 dOFV = 3.84
#  가 +-1.96 SE 에 온다. 그것이 맞는지를 보려는 것이므로 +-3 SE 까지 본다.
#
#  경계가 있는 모수는 경계를 넘을 수 없다. 넘어가는 격자점은 경계 바로
#  앞으로 당긴다. 그 자리에서도 dOFV 가 3.84 에 못 미치면, 그 방향으로는
#  95 % 구간의 끝이 없다는 뜻이다(경계가 구간 안에 있다).
STEP <- seq(-3, 3, by = 0.5)
PARS <- c("T3", "T5", "T6")
LO   <- c(T3 = 0, T5 = -20, T6 = -20)     # 제어파일에 적은 하한
grid <- do.call(rbind, lapply(PARS, function(p) {
  k <- paste0("THETA", substr(p, 2, 2))
  v <- pmax(fin[[k]] + STEP * se[[k]], LO[[p]] + 0.01 * se[[k]])
  data.frame(PAR = p, VALUE = sort(unique(v)))
}))
stopifnot(grid$VALUE[grid$PAR == "T3"] > 0)

tpl <- readLines("nm/llp.ctl", warn = FALSE)
dir.create("nm/llp", showWarnings = FALSE)

grid$OFV  <- NA_real_
grid$TERM <- NA_character_
t0 <- Sys.time()
for (i in seq_len(nrow(grid))) {
  #  표시가 붙은 줄 하나만 "<값> FIX" 로 바꾼다. 나머지는 손대지 않는다.
  mark <- paste0("<", grid$PAR[i], ">")
  j <- grep(mark, tpl, fixed = TRUE)
  stopifnot(length(j) == 1)
  x <- tpl
  x[j] <- sprintf("  %.8g FIX  ; %s", grid$VALUE[i], mark)
  writeLines(x, "nm/_llp.ctl")

  suppressWarnings(system2("Rscript", c("R/runnm.R", "_llp"),
                           stdout = NULL, stderr = NULL))

  f <- "nm/_llp.R76/_llp.ext"
  if (file.exists(f)) {
    z <- read.table(f, skip = 1, header = TRUE)
    grid$OFV[i] <- z[z$ITERATION == -1000000000, "OBJ"]
  }
  l <- "nm/_llp.R76/_llp.lst"
  grid$TERM[i] <- if (!file.exists(l)) "NO OUTPUT" else {
    y <- readLines(l, warn = FALSE)
    if (any(grepl("MINIMIZATION SUCCESSFUL", y)))      "SUCCESS"
    else if (any(grepl("ROUNDING ERRORS", y)))         "ROUNDING"
    else if (any(grepl("MINIMIZATION TERMINATED", y))) "TERMINATED"
    else                                               "OTHER"
  }
  message(sprintf("  %2d/%d  %s = %.4g  OFV = %.2f  %s", i, nrow(grid),
                  grid$PAR[i], grid$VALUE[i], grid$OFV[i], grid$TERM[i]))
}

#  프로파일 OFV 는 전체 자료의 최소보다 **작을 수 없다.** 모수 하나를
#  묶어 놓고 최적화한 것이므로 최소한 그만큼 나쁘다. 작게 나왔다면 그
#  run 은 깨진 것이다(목적함수가 같은 자료 위에서 계산되지 않았다).
#  이것은 가정이 아니라 부등식이므로 그대로 점검이 된다.
#  최적점 바로 그 자리의 격자점은 수치 오차로 1e-6 쯤 작게 나온다.
#  그만큼은 봐 주고, 그보다 크게 작은 것만 깨진 것으로 본다.
bad <- which(!is.na(grid$OFV) & grid$OFV < fin$OBJ - 0.01)
if (length(bad)) {
  message("\n** 전체 최소보다 작은 점 ", length(bad), "개. 깨진 run 이다.")
  print(grid[bad, c("PAR", "VALUE", "OFV", "TERM")])
}

write.csv(grid, "nm/llp/llp.csv", row.names = FALSE, quote = FALSE)
unlink(c("nm/_llp.ctl", "nm/_llp.R76"), recursive = TRUE)
message(sprintf("\n%d점, 총 %s", nrow(grid), format(round(Sys.time() - t0))))
message("nm/llp/llp.csv 에 썼다.  다음: Rscript R/build.R")
