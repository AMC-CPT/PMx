# The trap. 130ssx writes the profile after the third dose -- not yet steady
# state -- as SS=1. NONMEM believes the SS=1 and computes as though that dose
# were at steady state. So it reads the concentration being lower than it
# really is as a large clearance.
x <- fin("130ssx"); s <- fin("130ss")
rbind(truth = truth[c("KA", "CL", "V")],
      SS.at.steady.state = signif(s$f[c("THETA1", "THETA2", "THETA3")], 3),
      SS.after.3.doses   = signif(x$f[c("THETA1", "THETA2", "THETA3")], 3))
# After three doses, what percentage of steady-state accumulation is reached?
# Half-life 8.7 h, interval 12 h.
ke <- truth[["CL"]] / truth[["V"]]
c(accumulation.3.doses = round((1 - exp(-3 * ke * 12)) / (1 - exp(-ke * 12)), 3),
  accumulation.steady  = round(1 / (1 - exp(-ke * 12)), 3))
