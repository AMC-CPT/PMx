# OQ: 벤더 예제(examples/setest.ctl)를 이 PC 에서 돌린 nm/oq1 을 벤더가 함께
# 배포한 결과(examples/setest.ext, 사본 Ref/oq/)와 견준다. 기준값은 그 파일의
# 최종 추정치를 옮겨 적은 것이다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
here   <- fin("oq1")
vendor <- c(OBJ = -1121.02837, THETA1 = 1.68689, THETA2 = 1.61126,
            THETA3 = 0.819484, THETA4 = 2.39152, SIGMA.1.1. = 0.0571570,
            OMEGA.1.1. = 0.165065, OMEGA.2.2. = 0.131447,
            OMEGA.3.3. = 0.187549, OMEGA.4.4. = 0.149922,
            OMEGA.2.1. = -0.000750916, OMEGA.3.1. = 0.0124051,
            OMEGA.3.2. = 0.0159326,    OMEGA.4.1. = -0.0127447,
            OMEGA.4.2. = 0.0138934,    OMEGA.4.3. = 0.0332761)
k   <- names(vendor)[1:10]
sig <- function(x) formatC(x, digits = 6, format = "g")      # 유효숫자 6
data.frame(벤더 = sig(vendor[k]), `이 PC` = sig(here[k]),
           `상대차 %` = round(100 * (here[k] - vendor[k]) / vendor[k], 3),
           row.names = k, check.names = FALSE)

# 비대각 성분은 0 근처라 상대차 대신 절대차로 본다(벤더의 .xtl 규약도 그렇다)
od <- names(vendor)[11:16]
c(`비대각 최대 절대차` = signif(max(abs(here[od] - vendor[od])), 2))
