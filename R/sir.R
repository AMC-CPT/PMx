# =====================================================================
#  R/sir.R  -  SIR, sampling importance resampling (14장).
#  저장소 최상위에서 실행:   Rscript R/sir.R [제안표본수]
#
#  점근 공분산행렬을 제안분포로 삼아 모수 벡터를 M 개 뽑고, 각각에서
#  **목적함수만 계산한다**(MAXEVAL=0. 추정하지 않으므로 수렴 실패가 없다).
#  우도와 제안밀도의 비를 가중치로 삼아 m 개를 재표집한다.
#
#  bootstrap 과 다른 점이 둘이다.
#    - 제안분포가 필요하므로 $COV 가 성공해야 한다
#    - 얻는 것은 사후분포에 가깝지 신뢰구간이 아니다
#
#  결과는 nm/sir/sir.csv 하나로 남는다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
M <- as.integer(c(commandArgs(trailingOnly = TRUE), "400")[1])
RESAMPLE <- 200
INFLATE  <- 2          # 제안분포를 부풀린다. 꼬리를 덮지 못하면 가중치가 튄다

e   <- read.table("nm/108wt.R76/108wt.ext", skip = 1, header = TRUE)
fin <- unlist(e[e$ITERATION == -1000000000, -1])

#  $COV 행렬을 읽는다. SIGMA 는 고정이라 행과 열이 0 이므로 뺀다.
cv  <- read.table("nm/108wt.R76/108wt.cov", skip = 1, header = TRUE,
                  check.names = FALSE)
rownames(cv) <- cv$NAME; cv$NAME <- NULL
keep <- setdiff(rownames(cv), "SIGMA(1,1)")
S <- as.matrix(cv[keep, keep]) * INFLATE
mu <- fin[c("THETA1", "THETA2", "THETA3", "THETA4", "THETA5", "THETA6",
            "OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.2.")]
names(mu) <- keep
stopifnot(all(eigen(S, only.values = TRUE)$values > 0))   # 제안이 쓸 만한가

#  다변량 정규에서 뽑는다. Cholesky 한 번이면 된다(패키지 필요 없다).
L <- chol(S)
draw1 <- function() as.vector(mu + t(L) %*% rnorm(length(mu)))

#  뽑은 것이 모형에서 말이 되는가. 안 되면 버리고 다시 뽑는다.
#  버린 개수도 센다. 많으면 제안분포가 자리를 잘못 잡은 것이다.
ok_draw <- function(v) {
  all(v[1:4] > 0) &&                                  # CL, V, 잔차오차 > 0
  v[7] > 0 && v[9] > 0 &&                             # OMEGA 대각 > 0
  (v[7] * v[9] - v[8]^2) > 0                          # 2x2 블록이 양정부호
}

#  제안밀도. 상수항은 가중치에서 약분되므로 이차형식만 있으면 된다.
Si <- solve(S)
logg <- function(v) { z <- v - mu; -0.5 * as.numeric(t(z) %*% Si %*% z) }

tpl <- readLines("nm/sir.ctl", warn = FALSE)
jT  <- grep("<THETA>", tpl, fixed = TRUE)
jO  <- grep("<OMEGA>", tpl, fixed = TRUE)
stopifnot(length(jT) == 1, length(jO) == 1)

write_ctl <- function(v) {
  x <- c(tpl[seq_len(jT - 1)],
         sprintf("  %.8g FIX", v[1:6]),
         tpl[(jT + 1):(jO - 1)],
         sprintf("  %.8g", v[7]),
         sprintf("  %.8g  %.8g", v[8], v[9]),
         tpl[(jO + 1):length(tpl)])
  writeLines(x, "nm/_sir.ctl")
}

dir.create("nm/sir", showWarnings = FALSE)
set.seed(20260917)
RNGkind()

res <- as.data.frame(matrix(NA_real_, M, length(mu)))
names(res) <- c(paste0("T", 1:6), "O11", "O21", "O22")
res$OFV  <- NA_real_
res$LOGG <- NA_real_
nrej <- 0
t0 <- Sys.time()
for (i in seq_len(M)) {
  for (try in 1:1000) { v <- draw1(); if (ok_draw(v)) break; nrej <- nrej + 1 }
  if (!ok_draw(v)) stop("제안분포가 자리를 잘못 잡았다. 1000번 뽑아 다 버렸다.")
  write_ctl(v)
  suppressWarnings(system2("Rscript", c("R/runnm.R", "_sir"),
                           stdout = NULL, stderr = NULL))
  f <- "nm/_sir.R76/_sir.ext"
  if (file.exists(f)) {
    z <- read.table(f, skip = 1, header = TRUE)
    res$OFV[i] <- z[z$ITERATION == -1000000000, "OBJ"]
  }
  res[i, 1:length(mu)] <- v
  res$LOGG[i] <- logg(v)
  if (i %% 25 == 0)
    message(sprintf("  %3d/%d  버린 것 %d  경과 %s", i, M, nrej,
                    format(round(Sys.time() - t0))))
}

#  가중치. log w = -OFV/2 - log g. 큰 값을 빼고 지수화한다(넘침 방지).
lw <- -res$OFV / 2 - res$LOGG
lw[is.na(lw)] <- -Inf
w  <- exp(lw - max(lw, na.rm = TRUE)); w <- w / sum(w)
res$W <- w

#  진단. 유효표본수가 작으면 몇 개가 가중치를 다 가져간 것이다.
ess <- 1 / sum(w^2)
message(sprintf("\nESS = %.1f / %d   최대가중치 = %.3f   버린 것 %d",
                ess, M, max(w), nrej))

res$PICK <- 0L
pick <- sample(seq_len(M), RESAMPLE, replace = TRUE, prob = w)
tb <- table(pick)
res$PICK[as.integer(names(tb))] <- as.integer(tb)

write.csv(res, "nm/sir/sir.csv", row.names = FALSE, quote = FALSE)
unlink(c("nm/_sir.ctl", "nm/_sir.R76"), recursive = TRUE)
message(sprintf("%d개 평가, 총 %s", M, format(round(Sys.time() - t0))))
message("nm/sir/sir.csv 에 썼다.  다음: Rscript R/build.R")
