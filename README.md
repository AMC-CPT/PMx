# Pharmacometrics with NONMEM and R: example repository

*한국어 설명은 [README.ko.md](README.ko.md) 에 있습니다.*

The companion repository of Kyun-Seop Bae, *Pharmacometrics with NONMEM and R*
(계량약리학 with NONMEM and R). Its purpose is to let a reader **remake every
number and every figure in the book**; the text of the book is not here.

The book exists in two editions, Korean and English, and this one repository
serves both. The R code that appears in the Korean edition is in
`R/snippets/`, with Korean comments; the English edition's translation of the
same code is in `En/R/snippets/`. Both produce the same numbers.

**An English-speaking reader needs nothing from the Korean side.** `En/` is a
complete parallel tree, and the control streams, the NONMEM run artifacts and
the data are not language-bound at all.

> **To study with this book you need a NONMEM license.** The exercise is to
> change a control stream, run it again and see how the result moves, and that
> only happens on a licensed machine. The NONMEM run artifacts are committed
> here, though, so the R code runs without a license and the numbers in the
> book can be checked.

## There is one rule

| | With what | What it needs |
|---|---|---|
| **Run NONMEM** | `Rscript R/runnm.R [model ...]` | A NONMEM 7.6 license and gfortran |
| **Run R (Korean edition)** | `Rscript R/build.R` | R only. Works without NONMEM |
| **Run R (English edition)** | `Rscript En/build.R` | R only. Works without NONMEM |

`R/build.R` never calls NONMEM. It reads the run artifacts committed under
`nm/<model>.R76/` and remakes `output/` (console output) and `figures/`.
Run `R/runnm.R` again only when a control stream or the data has changed.

## Structure

```
R/snippets/chNN-*.R   the R code printed in the book (chapter number = the book's)
R/build.R             runs the snippets and makes output/ and figures/
R/_freeze.R           its helper
R/runnm.R             runs NONMEM (licensed machines only)
R/rpt.R boot.R llp.R sir.R sse.R   the things that run hundreds of times (Ch 13, 14, 22)
R/mkdata/             the scripts that make the simulated data (the seeds are in them)
data/                 the example data. README.md gives the provenance
nm/<model>.ctl        control streams. README.md is the key to the model names
nm/<model>.R76/       their run artifacts (.lst .ext .phi and four tables). The licensee string is removed
nm/boot/ rpt/ llp/ sir/ sse/   the summary csv of the things that ran hundreds of times
output/               frozen console output (as printed in the book)
figures/              frozen figures
En/                   the same for the English edition (see below)
docker/               the Dockerfile and the commands of Ch 15
Ref/growth/dataset/   the tumor volume data published by Benzekry et al. (Ch 19)
```

### `En/`: the English edition

```
En/R/snippets/chNN-*.R   the same code with the comments, labels and messages in English
En/build.R               runs them and makes En/output/ and En/figures/
En/output/               the English edition's frozen console output
En/figures/              the English edition's frozen figures (Latin face)
```

`En/build.R` reuses `R/_freeze.R` and only redirects the three paths, so the
two editions share one pipeline. Every frozen number in `En/output/` is
identical to its counterpart in `output/`; what differs is the labels.

## Getting started

```sh
git clone https://github.com/AMC-CPT/PMx
cd PMx
Rscript R/build.R          # without NONMEM: output/ and figures/ are remade
Rscript En/build.R         # the English edition's
```

With NONMEM (`C:/nm76g64/run/nmfe76.bat`, or the environment variable `NMFE`):

```sh
Rscript R/runnm.R 100base      # one model
Rscript R/runnm.R              # all of them (rpt, boot and sse have their own scripts)
Rscript R/boot.R 200           # the bootstrap of Ch 14
```

R packages needed: `nmw` (CRAN), `deSolve`, `survival`, and `npde` for the NPDE
of Ch 12 (`R/build.R` skips that one snippet when `npde` is missing). The rest is
base R.

## Where the data come from

- `data/pheno.csv`, `data/theo-raw.txt`: examples from the NONMEM distribution
  (PHENO, THEO). Beal & Sheiner.
- `data/sdtm/`, `data/*-sim.csv`: simulated data made by this book. The
  generating scripts and their seeds are in `R/mkdata/`.
- `Ref/growth/dataset/`: the data published with Benzekry S, et al. PLoS Comput
  Biol 2014;10:e1003800 and Vaghi C, et al. PLoS Comput Biol 2020;16:e1007178.

- `data/tmdd-mab.csv`: a **simulated stand-in** for the second example of
  Chapter 18 (TMDD). The book used monkey data the author analyzed in practice
  (with the development code removed), and those data are not published. The
  file here simulates the same design (six doses, the same number of animals,
  the same sampling times, the same limit of quantification) from the estimates
  of the book's final model `tm103` (`R/mkdata/sim_tmdd.R`, seed 2026).
  `nm/tm10?.ctl` runs on it unchanged, but the numbers come out close to the
  book's rather than equal to them, which is why the run artifacts
  `nm/tm10?.R76/` are not here either. `output/ch18-tmdd-*` and
  `figures/ch18-tmdd-*` are committed as printed in the book, from the original
  data; **running `R/build.R` overwrites the ones that need no NONMEM**
  (`ch18-tmdd-data`, `ch18-tmdd-fig`) with the stand-in's numbers, so
  `git checkout -- output figures` puts the book's back.

Apart from that one exception there are no data from a real project here. The
failure cases in the book are reconstructions, and everything here is either
public or simulated.

## Copyright and license

The copyright in the text of the book belongs to the author and the publisher,
and the text is not here. The code, the control streams, the simulated data and
the frozen output and figures in this repository are published under the
**GNU General Public License v3.0 or later** (`LICENSE`). Running them and
changing them is free, and a modified version distributed to others carries the
source under the same terms. NONMEM is commercial software from ICON and no
part of it is included here.

Copyright (C) 2026 Kyun-Seop Bae. This program is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your option) any later
version. It is distributed WITHOUT ANY WARRANTY; see `LICENSE` for details.

## The other books in the series

| | |
|---|---|
| 1 Scientific Computation with R | <https://github.com/AMC-CPT/SciCompR> |
| 2 Scientific Inference in Clinical Trials with R | <https://github.com/AMC-CPT/CTDA> |
| 3 Pharmacokinetics with R | <https://github.com/AMC-CPT/PKwR> |
| 5 Essentials of Clinical Drug Development (online appendix) | <https://github.com/AMC-CPT/CDD> |
