# What extrapolation means. Carry an adult clearance of 6 L/h at 70 kg down to
# four children: by weight alone (mg/kg as it stands, then the 0.75 exponent)
# and with maturation as well. The mg/kg dose that gives the same exposure
# (AUC) is proportional to clearance.
kids <- data.frame(who = c("preterm (28 wk)", "term neonate (40 wk)", "age 2 (144 wk)",
                           "age 10 (562 wk)"),
                   WT = c(1.0, 3.4, 12, 32), PMA = c(28, 40, 144, 562))
mat <- function(pma) pma^3.4 / (55^3.4 + pma^3.4)
kids$CL.linear     <- round(6 * kids$WT / 70, 3)
kids$CL.exp0.75    <- round(6 * (kids$WT / 70)^0.75, 3)
kids$CL.mat    <- round(6 * (kids$WT / 70)^0.75 * mat(kids$PMA), 3)
adult_mgkg <- 5
kids$mgkg      <- round(adult_mgkg * kids$CL.mat / kids$WT / (6 / 70), 2)
kids
