# 겹침의 끝: 같은 공변량이 두 이름으로. WT 와 BWT(이 자료에서 값이 같다)를
# 청소율에 함께 넣은 108wtbwt 를 108wt 와 견준다.
se <- function(m) {                          # 표준오차는 .ext 의 -1000000001 줄
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000001, -1])
}
w <- fin("108wt");    ws  <- se("108wt")
wb <- fin("108wtbwt"); wbs <- se("108wtbwt")
c(OFV.108wt = sprintf("%.3f", w[["OBJ"]]), OFV.108wtbwt = sprintf("%.3f", wb[["OBJ"]]))
rbind(`108wt    WT~CL`   = c(추정 = w[["THETA5"]],  `RSE %` = 100 * ws[["THETA5"]] / w[["THETA5"]]),
      `108wtbwt WT~CL`   = c(wb[["THETA5"]], 100 * wbs[["THETA5"]] / wb[["THETA5"]]),
      `108wtbwt BWT~CL`  = c(wb[["THETA7"]], 100 * wbs[["THETA7"]] / wb[["THETA7"]]),
      `108wtbwt 둘의 합` = c(wb[["THETA5"]] + wb[["THETA7"]], NA))

# 두 지수 추정치의 상관(.cor 의 비대각, 8장)과 조건수(.ext 의 -1000000003 줄)
C <- read.table(nmf("108wtbwt", "108wtbwt.cor"), skip = 1, header = TRUE,
                row.names = 1, check.names = FALSE)
cond <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000003, 2]
}
c(`cor(WT 지수, BWT 지수)` = C["THETA5", "THETA7"],
  `조건수 108wt` = cond("108wt"), `조건수 108wtbwt` = cond("108wtbwt"))
