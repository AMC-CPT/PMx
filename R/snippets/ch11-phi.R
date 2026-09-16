# .phi 파일. 사람마다 EBE 와 그 조건부 분산(ETC), 그리고 개인 목적함수값(OBJ)이 있다.
# 2008년에는 verbatim 코드와 R 로 캐내야 했던 것이 NONMEM 7 부터는 파일 하나다.
fin <- function(m) { e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1])) }
phi <- read.table(nmf("108wt", "108wt.phi"), skip = 1, header = TRUE, check.names = FALSE)
names(phi) <- gsub("[(),]", "", names(phi))                  # ETA(1) -> ETA1, ETC(1,1) -> ETC11
head(phi[, c("ID", "ETA1", "ETA2", "ETC11", "ETC22", "OBJ")], 3)
c(개인OFV의합 = round(sum(phi$OBJ), 3), 보고된OFV = round(fin("108wt")$f[["OBJ"]], 3))

# 개인 수축. EBE 의 표준오차(sqrt(ETC))를 omega 로 나눈 것이다. 1 에 가까우면 그 사람의
# 자료가 ETA 를 거의 정하지 못한 것이고, 그 사람의 EBE 는 0 으로 수축해 있다.
om <- fin("108wt")$f[c("OMEGA.1.1.", "OMEGA.2.2.")]
ind <- data.frame(ID = phi$ID, CL = sqrt(phi$ETC11 / om[1]), V = sqrt(phi$ETC22 / om[2]))
summary(ind[, c("CL", "V")])
# 집단 수축과 잇는다. EBE 의 분산은 omega^2 에서 조건부 분산의 평균만큼 모자라므로
# 집단 수축 = 1 - sqrt(1 - mean(개인 수축^2)) 이 되어야 한다.
c(집단_CL = round(100 * (1 - sd(phi$ETA1) / sqrt(om[[1]])), 1),
  개인에서_계산 = round(100 * (1 - sqrt(1 - mean(ind$CL^2))), 1))
