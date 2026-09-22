# The same first-order absorption model run with initial estimates that are off
# by an order of magnitude (CL 0.04, V 0.5), as 110kax. It converged, and the
# OFV is actually lower. Yet KA and k = CL/V have swapped places.
x <- fin("110kax"); o <- fin("110ka")
rbind(right.magnitude = c(KA = signif(o[["THETA1"]], 3), CL = signif(o[["THETA2"]], 3),
                          V = signif(o[["THETA3"]], 3),
                          k = signif(o[["THETA2"]] / o[["THETA3"]], 3),
                          OFV = round(o[["OBJ"]], 2)),
      wrong.magnitude = c(KA = signif(x[["THETA1"]], 3), CL = signif(x[["THETA2"]], 3),
                          V = signif(x[["THETA3"]], 3),
                          k = signif(x[["THETA2"]] / x[["THETA3"]], 3),
                          OFV = round(x[["OBJ"]], 2)))
