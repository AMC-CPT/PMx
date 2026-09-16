# 1단계. 농도만으로 PK 를 적합한다(wf100). PCA 레코드는 IGNORE 로 뺐다.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
show <- function(r, key, tv) data.frame(참값 = signif(tv, 3), 추정 = signif(r$f[key], 3),
       RSE = round(100 * r$s[key] / abs(r$f[key]), 1), row.names = names(key))
pk <- fin("wf100")
show(pk, c(KA = "THETA1", CL = "THETA2", V = "THETA3", 비례CV = "THETA4",
           OM_KA = "OMEGA.1.1.", OM_CL = "OMEGA.2.2.", OM_V = "OMEGA.3.3."),
     truth[c("KA", "CL", "V", "PROP", "OM_KA", "OM_CL", "OM_V")])
c(OFV = round(pk$f[["OBJ"]], 2))
