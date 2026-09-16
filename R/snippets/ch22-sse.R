# 모의-추정(SSE). 같은 세 설계로 자료를 100번씩 만들어 NONMEM 으로 추정했다(R/sse.R).
# 추정치의 표준편차가 경험적 SE 이고, 그 RSE 를 정보행렬의 기대 RSE 와 나란히 놓는다.
sse <- read.csv("nm/sse/sse.csv")
table(설계 = sse$DESIGN, 종료 = sse$TERM)
ok <- sse[sse$TERM %in% c("SUCCESS", "ROUNDING"), ]           # rounding error 는 성공으로 센다(8장)
emp <- function(d) { z <- ok[ok$DESIGN == d, c("KA", "CL", "V", "OM_KA", "OM_CL", "OM_V", "ADD", "PROP")]
  c(n = nrow(z), 편향_CL = 100 * (median(z$CL) - psi0["CL"]) / psi0["CL"],
    100 * apply(z, 2, sd) / psi0) }
emp_tab <- t(sapply(c("rich", "sparse2", "sparse3"), emp))
colnames(emp_tab)[3:10] <- paste0("RSE_", colnames(emp_tab)[3:10])
round(emp_tab, 1)
# 정보행렬의 예측(앞 절)과 견준다. rich 와 sparse3 만. sparse2 는 예측이 없다(특이).
cmp <- rbind(FIM_rich = out["rich", 1:8], SSE_rich = emp_tab["rich", 3:10],
             FIM_sparse3 = out["sparse3", 1:8], SSE_sparse3 = emp_tab["sparse3", 3:10])
round(cmp, 1)
