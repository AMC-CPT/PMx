# 모형 계보. $PROB 의 P: 와 F: 를 SumOut 이 읽어 표로 만든다(4장).
# 읽는 자리는 실행 폴더의 FCON 이다. 그래서 그 파일을 남겨 둔다.
owd <- setwd("nm")
mdl <- SumOut(FileExt = ".ctl", RunExt = ".R76", OutExt = ".lst")
setwd(owd)

# 모의 전용 실행(12장)은 추정을 하지 않으므로 OFV 가 없다. 계보에서 뺀다.
# 이 장은 3부의 phenobarbital 계보(100-109)만 본다. 다른 장의 모형은 각 장에서.
mdl <- mdl[!is.na(mdl$OFV) & grepl("^10[0-9]", mdl$OutName), ]
mdl[, c("OutName", "Parent", "Formula", "OFV", "Parameter", "AICc")]
