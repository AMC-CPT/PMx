# The same structure (tm100) run with FOCE-I (tm101). In practice too, FO was
# chosen as the final method.
walls <- function(m) as.numeric(sub(".*: ", "", grep("wall seconds", readLines(
  file.path("nm", paste0(m, ".R76"), "nmfe.log")), value = TRUE)))
lst <- function(m) readLines(file.path("nm", paste0(m, ".R76"), paste0(m, ".lst")))
term <- function(m) { l <- lst(m)
  c(term = if (any(grepl("MINIMIZATION SUCCESSFUL", l))) "SUCCESSFUL" else "TERMINATED",
    probs = if (any(grepl("PROBLEMS OCCURRED", l))) "yes" else "no",
    sigdig = sub(".*EST.: *", "", grep("SIG. DIGITS IN FINAL", l, value = TRUE)),
    cov = if (any(grepl("STANDARD ERROR OF ESTIMATE", l))) "yes" else "no") }
f1 <- fin("tm101")
rbind(FO_tm100 = c(term("tm100"), sec = walls("tm100"), OFV = round(r0$f[["OBJ"]], 1)),
      FOCEI_tm101 = c(term("tm101"), sec = walls("tm101"), OFV = round(f1$f[["OBJ"]], 1)))
# The estimates of the two methods. OFVs from different methods cannot be
# compared; the estimates can.
key2 <- c(CL_kg = "THETA1", V1_kg = "THETA2", KON = "THETA5", KOFF = "THETA6", KINT = "THETA7",
          KDEG = "THETA9", add.SD = "THETA10", prop.CV = "THETA11")
data.frame(FO = signif(r0$f[key2], 3), FOCEI = signif(f1$f[key2], 3), row.names = names(key2))
