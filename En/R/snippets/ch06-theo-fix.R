# Only subject 9 is 52 mg away from 320 mg. The scatter of the other eleven is
# rounding.
round(range(dz$TOTAL[dz$ID != 9]), 2)     # range excluding subject 9
round(320 / dz$WT[dz$ID == 9], 4)         # the dose subject 9 needs to reach 320 mg
round(3.7 * dz$WT[dz$ID == 9], 2)         # what 3.7 gives
