# The distribution of the clearance ETA. Not one lump but two. It is the first
# sign that a subpopulation is there, and without looking at this, reading OMEGA
# alone ends at "the variability of CL is large".
pa <- read.table(nmf("121iov", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
pop <- d$POP[!duplicated(d$ID)]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
hist(pa$ETA2, breaks = 24, col = "#12366955", border = "white", main = "",
     xlab = "ETA(CL)", ylab = "number of people")
rug(pa$ETA2[pop == 2], col = "#B2182B", lwd = 2)
qqnorm(pa$ETA2, pch = 16, col = "#123669", main = "", xlab = "normal quantile", ylab = "ETA(CL)")
qqline(pa$ETA2, col = "grey50")
shapiro.test(pa$ETA2)$p.value
