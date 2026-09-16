# 왼쪽: 개인 목적함수값. 한 사람이 유난히 크면 그 사람의 자료를 본다. 오른쪽: 관측 수와
# 개인 수축. 관측이 적은 사람일수록 EBE 가 덜 정해진다.
nobs <- table(read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)$ID[
          read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)$MDV == 0])
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(phi$ID, phi$OBJ, type = "h", lwd = 3, col = "#123669", xlab = "ID", ylab = "개인 OFV",
     main = "개인 목적함수값")
abline(h = mean(phi$OBJ) + 2 * sd(phi$OBJ), lty = 3, col = "#B2182B")
plot(jitter(as.numeric(nobs[as.character(phi$ID)]), 0.3), ind$CL, pch = 16, col = "#12366999",
     xlab = "관측 수", ylab = "CL 의 개인 수축", ylim = c(0, 1), main = "개인 수축과 관측 수")
