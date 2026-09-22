# The three datasets Benzekry and colleagues published. The separators and the
# column names differ between them.
for (f in c("LLC_sc_CCSB.txt", "LM2-4LUC.txt", "MDA-MB-231dTomato.txt"))
  cat(sprintf("%-22s %s\n", f, readLines(file.path("Ref/growth/dataset", f), n = 1)))

# data/tgi-*.csv is the same content brought into one format (R/mkdata/make_tgi.R).
llc <- read.csv("data/tgi-llc.csv")
c(animals = length(unique(llc$ID)), observations = nrow(llc),
  per.animal = paste(range(table(llc$ID)), collapse = "-"),
  time = paste(range(llc$TIME), collapse = "-"),
  volume = paste(round(range(llc$DV)), collapse = "-"))
