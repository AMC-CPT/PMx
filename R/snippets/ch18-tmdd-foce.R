# 같은 구조(tm100)를 FOCE-I 로 돌린 것(tm101). 실무에서도 FO 를 최종으로 택했다.
walls <- function(m) as.numeric(sub(".*: ", "", grep("wall seconds", readLines(
  file.path("nm", paste0(m, ".R76"), "nmfe.log")), value = TRUE)))
lst <- function(m) readLines(file.path("nm", paste0(m, ".R76"), paste0(m, ".lst")))
term <- function(m) { l <- lst(m)
  c(종료 = if (any(grepl("MINIMIZATION SUCCESSFUL", l))) "SUCCESSFUL" else "TERMINATED",
    문제 = if (any(grepl("PROBLEMS OCCURRED", l))) "있음" else "없음",
    유효숫자 = sub(".*EST.: *", "", grep("SIG. DIGITS IN FINAL", l, value = TRUE)),
    공분산 = if (any(grepl("STANDARD ERROR OF ESTIMATE", l))) "나옴" else "안 나옴") }
f1 <- fin("tm101")
rbind(FO_tm100 = c(term("tm100"), 초 = walls("tm100"), OFV = round(r0$f[["OBJ"]], 1)),
      FOCEI_tm101 = c(term("tm101"), 초 = walls("tm101"), OFV = round(f1$f[["OBJ"]], 1)))
# 두 방법의 추정치. OFV 는 방법이 다르면 견줄 수 없다. 추정치는 견줄 수 있다.
key2 <- c(CL_kg = "THETA1", V1_kg = "THETA2", KON = "THETA5", KOFF = "THETA6", KINT = "THETA7",
          KDEG = "THETA9", 가법SD = "THETA10", 비례CV = "THETA11")
data.frame(FO = signif(r0$f[key2], 3), FOCEI = signif(f1$f[key2], 3), row.names = names(key2))
