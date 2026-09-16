# SIR 결과다(R/sir.R). 제안분포에서 400개를 뽑아 목적함수만 계산하고,
# 가중치에 따라 200개를 다시 뽑았다. 추정은 한 번도 하지 않았다.
s <- read.csv("nm/sir/sir.csv")
c(평가 = nrow(s), ESS = round(1 / sum(s$W^2), 1),
  최대가중치 = round(max(s$W), 3), 뽑힌벡터 = sum(s$PICK > 0))

# 재표집된 것의 백분위수. PICK 이 그 벡터가 뽑힌 횟수다.
sirq <- t(sapply(c("T3", "T5", "T6"), function(k)
  quantile(rep(s[[k]], s$PICK), c(0.025, 0.975))))
round(sirq, 4)
