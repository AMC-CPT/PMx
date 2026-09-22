# A permutation test shuffles a covariate among the subjects. Inside that one
# line hides an error that really happened. Shown here for the case where two
# trials were pooled and the ID have different numbers of digits (Ch 6).
ex <- data.frame(
  ID   = c(rep("20001", 2), rep("110001", 3), rep("110002", 2)),
  TIME = c(0, 1, 0, 1, 2, 0, 1),
  WT   = c(60, 60, 70, 70, 70, 80, 80))
uid <- unique(ex$ID)                      # numeric order: 20001, 110001, 110002
set.seed(4)
perm <- data.frame(ID = uid, WT = sample(ex$WT[match(uid, ex$ID)]))
perm

# (1) Attach it with merge and put the column back into the original data.
#     This is the common way.
m <- merge(ex[, c("ID", "TIME")], perm, by = "ID")   # reordered by character ID
bad <- ex; bad$WT <- m$WT

# (2) Attach it with match. The row order is preserved.
good <- ex; good$WT <- perm$WT[match(ex$ID, perm$ID)]

cbind(ex[, c("ID", "TIME")], by.merge = bad$WT, by.match = good$WT)
