# =====================================================================
#  R/mkdata/make_warf_ipp.R  -  IPP(individual PK parameters) 용 PD 자료를 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_warf_ipp.R
#
#  순차 PK/PD 의 IPP 방법(Zhang, Beal, Sheiner 2003)은 PK 모형의 개인 추정치
#  (EBE)를 자료의 열로 넣고 PD 만 적합한다. 그래서 이 스크립트는 **wf100 의
#  실행 산출물(patab)에 의존한다.** wf100 을 먼저 돌려야 한다.
#
#  결과: data/warf-ipp.csv (ID TIME DV MDV EVID DOSE IKA ICL IV). PCA 레코드만.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")
pt <- "nm/wf100.R76/patab"
if (!file.exists(pt)) stop("nm/wf100.R76/patab 이 없다. 먼저 Rscript R/runnm.R wf100")

pa <- read.table(pt, skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), c("ID", "KA", "CL", "V")]
names(pa) <- c("ID", "IKA", "ICL", "IV")

d <- read.csv("data/warf-sim.csv", na.strings = ".")
pd <- d[d$DVID == 2, c("ID", "TIME", "DV", "MDV", "EVID")]
dose <- d[d$EVID == 1, c("ID", "AMT")]; names(dose)[2] <- "DOSE"
pd <- merge(merge(pd, dose, by = "ID"), pa, by = "ID")
pd <- pd[order(pd$ID, pd$TIME), c("ID", "TIME", "DV", "MDV", "EVID", "DOSE", "IKA", "ICL", "IV")]
pd$IKA <- signif(pd$IKA, 5); pd$ICL <- signif(pd$ICL, 5); pd$IV <- signif(pd$IV, 5)
write.csv(pd, "data/warf-ipp.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/warf-ipp.csv: %d 행, %d 명. 개인 CL 범위 %.3f-%.3f L/h\n",
            nrow(pd), length(unique(pd$ID)), min(pd$ICL), max(pd$ICL)))
