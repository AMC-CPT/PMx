# The estimates of the logit model (pd100) beside the true values. This is what
# data with a known truth are worth.
nmf <- function(m, f) file.path("nm", paste0(m, ".R76"), f)
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
tr  <- read.csv("data/pd-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
key <- c(CL = "THETA1", V = "THETA2", LB = "THETA3", PLMAX = "THETA4", KPL = "THETA5",
         EMAX = "THETA6", EC50 = "THETA7", prop.CV = "THETA8", floor.SD = "THETA9",
         bounded.coef = "THETA10", OM_CL = "OMEGA.1.1.", OM_V = "OMEGA.2.2.",
         OM_LB = "OMEGA.3.3.", OM_PLMAX = "OMEGA.4.4.", OM_EC50 = "OMEGA.5.5.")
tv  <- truth[c("CL", "V", "LB", "PLMAX", "KPL", "EMAX", "EC50", "B", "A", "B",
               "OM_CL", "OM_V", "OM_LB", "OM_PLMAX", "OM_EC50")]
tv[8] <- 0.15                                      # the proportional error on concentration was made 15 %
r <- fin("pd100")
data.frame(truth = signif(tv, 3), estimate = signif(r$f[key], 3),
           RSE = round(100 * r$s[key] / abs(r$f[key]), 1), row.names = names(key))
c(OFV = round(r$f[["OBJ"]], 2))
