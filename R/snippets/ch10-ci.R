# 실행 산출물은 모형마다 제 폴더에 있다: nm/<모형>.R76/ (3장)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# 표준오차는 .ext 의 ITERATION = -1000000001 줄에 있다.
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
est <- fin("108wt")
se  <- fin("108wt", -1000000001)

ci <- function(k) c(추정 = est[[k]], SE = se[[k]],
                    하한 = est[[k]] - 1.96 * se[[k]],
                    상한 = est[[k]] + 1.96 * se[[k]])
round(rbind(`WT~CL` = ci("THETA5"), `WT~V` = ci("THETA6")), 3)

# 생리학적으로 뜻이 있는 값을 CI 가 포함하는가.
# allometric 이론값은 CL 0.75, V 1.0 이다.
c(`CL 의 CI 가 0.75 를 포함` = 0.75 >= ci("THETA5")[["하한"]],
  `V 의 CI 가 1.0 을 포함`  = 1.00 <= ci("THETA6")[["상한"]])
