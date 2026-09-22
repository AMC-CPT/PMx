# DV = 0 is one of three things: missing, BLQ (measured and below the limit),
# or an a priori zero (pre-dose). Keep all three apart to the end. Mix them and
# the BLQ proportion inflates and the M1/M3 judgment itself goes wrong.
pc <- read.csv("data/sdtm/pc.csv")
LLOQ <- pc$PCLLOQ[1]
cls <- ifelse(pc$PCREASND == "PREDOSE", "apriori0",
       ifelse(is.na(pc$PCSTRESN), "missing",
       ifelse(pc$PCSTRESN < LLOQ, "BLQ", "quantified")))
table(cls)

# The denominator of the BLQ proportion is 'quantified + BLQ'. An a priori zero
# enters neither numerator nor denominator.
meas <- cls %in% c("quantified", "BLQ")
c(denominator = sum(meas), BLQ = sum(cls == "BLQ"),
  percent = round(100 * mean(cls[meas] == "BLQ"), 1))

# Count the a priori zeros together with the BLQ and it inflates like this.
# A true 0 % gets reported as this value.
c(if.mixed = round(100 * mean(cls %in% c("BLQ", "apriori0")), 1))
