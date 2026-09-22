# Where NONMEM runs

This repository has one rule.

| | With what | What it needs |
|---|---|---|
| **Run NONMEM** | `Rscript R/runnm.R` | A NONMEM license and a Fortran compiler |
| **Run R** | `Rscript R/build.R` | R only. **Works without NONMEM** |
| **Build the book** | `latexmk -xelatex PMx.tex` | LaTeX only |

The run artifacts (`.lst`, `.ext`, `.phi` and the four tables) are
**committed**, so R and the book build run on a machine without a license.
Run `R/runnm.R` on a licensed machine only when a control stream or the data
has been changed.

`R/build.R` **never calls NONMEM.** It only reads the committed artifacts, and
where they are absent it skips that chapter and says what must be run.

## Model names

Follows the rules of `CTL_Style_Guide.md`. The first digit is the number of
parent compartments.

| Name | What | Ch |
|---|---|---|
| `100base` | 1-compartment IV bolus, no covariates. **The base model** | 7 |
| `101diag` | `$OMEGA` diagonal only | 7 |
| `102sig` | Residual error in `$SIGMA` instead of `$THETA` | 8 |
| `103mats` `104matr` | Covariance estimators S and R | 8 |
| `105start` | Different initial estimates only | 8 |
| `106wtcl` `107wtv` | Weight on `CL`, on `V` | 9 |
| `108wt` | Weight on both. **The final covariate model** | 9 |
| `108wts` `108wtx` | Exponents fixed | 10 |
| `108wtcr` `109sex` | Creatinine, sex | 9, 10 |
| `108wtsim` | `$SIM ONLYSIMULATION`, 200 replicates (VPC) | 12 |
| `rpt` | For the randomization test. `R/rpt.R` runs it on temporary data | 13 |
| `boot` | For bootstrap. `R/boot.R` runs it on temporary data | 14 |
| `llp` `sir` | **Templates. They do not run as they stand** | 14 |
| `pd100x` | Pharmacodynamics. First attempt, effect added on the natural scale | 17 |
| `pd100` | Pharmacodynamics. Logit link, placebo arm included, baseline estimated. **The final model of Ch 17** | 17 |
| `pd101` `pd101b` `pd102` `pd103` | Placebo arm excluded / 160 mg arm only / observed baseline / combined error | 17 |
| `pd100sim` | 200 simulations from the `pd100` estimates (VPC by arm) | 17 |
| `pd200ord` | Proportional odds model with NRS collapsed to three categories. `LAPLACE LIKELIHOOD` | 17 |
| `tg100`--`tg105` | Tumor volume. Exponential / logistic / Gompertz (diagonal, `b` block) / power / von Bertalanffy (ADVAN13) / reduced Gompertz | 19 |
| `tm100` | Full TMDD (2 compartments + target synthesis/degradation/binding/dissociation/internalization, `ADVAN13`), FO. Monkey monoclonal antibody | 18 |
| `tm101` | The same structure with FOCE-I | 18 |
| `tm102` `tm104` | QSS approximation (`KSS`) / Michaelis-Menten limit | 18 |
| `tm103` | Full TMDD with the target-synthesis intercept removed. **The final model of the second example of Ch 18** | 18 |
| `tg103x` | `V0` estimated in the power model (a trap) | 19 |
| `tg102bsim` | 200 simulations from the `tg102b` estimates (VPC) | 19 |
| `tg106` `tg107` | Simulated data with a treatment arm. No effect / effect on growth rate | 19 |
| `110des` | Theophylline through `ADVAN13`. Verbatim code puts `DAETA` and `G` in a table | 8 |
| `120base` `120add` `120prop` | Oral data over three occasions. IIV only. Combined / additive / proportional residual | 16 |
| `121iov` | IOV on clearance and absorption rate (`BLOCK SAME`) | 16 |
| `122mix` `123mixiov` | Clearance subpopulations by `$MIX`. Without IOV / with. **The final model of Ch 16** | 16 |
| `124etaeps` | Interindividual variability on the residual magnitude | 16 |
| `wf100` | Warfarin-type PK only (PCA records IGNOREd) | 18 |
| `wf200` | Indirect response type I, IPP (individual PK as data columns). `data/warf-ipp.csv` | 18 |
| `wf201` | Indirect response type I, PK/PD simultaneously (`ADVAN13`, three compartments). **The final model of Ch 18** | 18 |
| `wf202` `wf203` | Effect compartment + direct Emax / type IV (the wrong mechanism) | 18 |
| `wf201sim` | 200 simulations from the `wf201` estimates (VPC) | 18 |
| `tte100` `tte101` `tte102` | Time-to-event. Constant hazard / Weibull / Weibull + exposure. `LAPLACE LIKELIHOOD` | 20 |
| `cnt100` `cnt101` `cnt102` | Counts. Poisson / negative binomial / negative binomial with no drug effect. `LAPLACE -2LL` | 20 |
| `ped100` `ped101` `ped102` | 120 pediatric subjects. Size only / size + maturation / exponent estimated | 21 |
| `ped104` | 90 subjects with neonates excluded (the source of the prior) | 21 |
| `ped103x` `ped103` | 30 neonates only. Without a prior / with `$PRIOR NWPRI` | 21 |
| `130mult` `130addl` `130ss` | Repeated oral dosing. Every dose / `ADDL II` / `SS=1` (the first two give the same answer) | 7 |
| `130ssx` | A trap. Dosing before steady state written as `SS=1` | 7 |
| `sse` | For the simulation--estimation of the design comparison. `R/sse.R` runs it on temporary data | 22 |

The suffixes are `s` (simplified, or `$COV MAT=S`), `i` (iteration) and
`x` (experimental). `pd` is pharmacodynamics, `tg` tumor growth, `wf`
warfarin-type PK/PD, `tte` and `cnt` time-to-event and counts, and `ped`
pediatric models. Naming by the number of compartments applies to PK models
only.

### What is left out when `R/runnm.R` is called with no name

| | Why | How to run them all | Result | Time |
|---|---|---|---|---|
| `rpt` | Reads `data/_perm.csv` (temporary) | `Rscript R/rpt.R 200` | `nm/rpt/rpt.csv` | ~37 min |
| `boot` | Reads `data/_boot.csv` (temporary) | `Rscript R/boot.R 200` | `nm/boot/boot.csv` | ~30 min |
| `sse` | Reads `data/_sse.csv` (temporary) | `Rscript R/sse.R 100` | `nm/sse/sse.csv` | ~45 min |
| Names beginning with `_` | They are produced by a script | `Rscript R/llp.R`, `R/sir.R` | `nm/llp/llp.csv`, `nm/sir/sir.csv` | |

`llp.ctl` and `sir.ctl` are **templates** carrying markers (`<T3>`,
`<THETA>` and the like). `R/llp.R` and `R/sir.R` substitute those lines only,
write `nm/_llp.ctl` and `nm/_sir.ctl`, run them and delete them afterward.
`runnm.R` leaves control streams beginning with `_` out of its list.

The results of the things that run hundreds of times all come down to
**one small csv**. With that file alone, the R code of Chapters 13 and 14 runs
without NONMEM.

Simulation-only runs (those with `$SIM` and no `$EST`) are handled separately by
`runnm.R`. There is no such thing as convergence for them, so it does not judge
by that; and it reduces the original `simtab` (8 MB) to `simtab.csv` (0.6 MB),
keeping the observation records only.

## How runs are made

NONMEM is run **in a working folder** (Analects 3). `R/runnm.R` creates
`nm/<model>.R76/`, copies the control stream into it and runs with `-rundir`.
When it finishes it deletes only the intermediate files and **leaves the folder
in place**.

Leaving the folder matters, because `nmw`'s post-processing presumes that
structure.

| What nmw looks for | Where |
|---|---|
| Model name | The first token of the folder name (`108wt.R76` -> `108wt`) |
| Tables | `sdtab` `patab` `cotab` `catab` (**no numbers attached**) |
| Termination status | `PRINT.OUT` (`runnm.R` makes it with `TrimOut`) |
| Model lineage | The `P:` and `F:` written in `$PROB`, read from `FCON` |
| The rest | `.xml` `.ext` `.phi` `.grd` `.cov` `.cor` `.coi`, `FDATA.csv` |

The eight reports (`S1-OFV.PDF` and so on) are produced by
`Rscript R/build.R` and are covered by `.gitignore`. They read only the
committed artifacts, so **they can be produced without NONMEM.**

Control streams are written in pure ASCII. Non-ASCII comments bring a flood of
missing-font warnings when the reports are produced (CTL_Style_Guide 20.2).

Note also that the `$DATA` of a control stream points two levels up, because it
is resolved **relative to the working folder**.

```
$DATA ../../data/pheno-nm.csv IGNORE=@
```

## The licensee string

NONMEM stamps the licensee and the date at the head of its output. This
repository may go out as a public companion (`PUBLIC.md`), so `R/runnm.R`
replaces that line with `<LICENSEE>` **at the point of collection**. It never
enters the git history at all.

Check once more on the raw bytes before publishing.

## Do not modify `nmfe76.bat`

Modifying the distribution's `nmfe76.bat` (469 lines) is convenient, but when
NONMEM goes to 7.7 that modification has to be made **all over again**. So this
repository calls the original untouched and attaches what it needs before and
after. `R/runnm.R` is that shell.

```
[before] create the working folder and copy the control stream in
[call]   invoke the distribution's nmfe76.bat, untouched
[after]  make PRINT.OUT, substitute the licensee string, delete intermediates
```

Comparing with the author's own long-used modified version `nmfe76.bat`
(559 lines), the modifications fall into five kinds, and **four of them have no
business being inside nmfe**.

| Kind | The author's version | Moved into the shell |
|---|---|---|
| Environment | `chcp 437`, `Editor`, `NMaDir` | Variables of the shell |
| **Before** | `MD %rundir%`, `COPY %1`, deleting a stale `PRINT.OUT` | The shell's before step |
| **After** | Eight R scripts, `PP1--PP5` and `PPa--PPc` | **One line: `nmw::nmw_run()`.** Those eight are from the 2022 edition; the author's `nmw` package now does the same work |
| **After** | Deleting some twenty intermediate files, deleting `worker1--23` | Fix a list of what to keep and delete the rest |
| Finishing | `SumOut.R`, `PAUSE`, opening an editor | Conveniences for a person. Make them optional arguments of the shell |

**Only the remaining kind is a real modification.** Two bugs in the
distribution.

- `pushdon=1` is missing its `set` (line 118 of the 469-line version). It only
  prints one error line to the console and does not affect the result
- `call gfcompile.bat` may fail to find the current folder.
  `call .\gfcompile.bat` always finds it

The second shows up only where `NoDefaultCurrentDirectoryInExePath` is set, and
in that case **clearing that variable from outside makes the original run as
it is**. `R/runnm.R` does exactly that. So this repository keeps no copy of
`nmfe76.bat`.

If you would rather write the shell as a batch file, the same structure carries
over directly.

```bat
@echo off
set NM=C:\nm76g64\run\nmfe76.bat
set MODEL=%1
md "%MODEL%.R76" 2>nul
copy "%MODEL%.ctl" "%MODEL%.R76" >nul
set NoDefaultCurrentDirectoryInExePath=
call "%NM%" %MODEL%.ctl %MODEL%.lst -rundir=%MODEL%.R76
Rscript -e "nmw::nmw_run('%MODEL%.R76')"
```

The R side is recommended. The post-processing is already R; keeping it in one
place lets nm75 and nm76 be handled by the same code; and nothing needs fixing
when the version goes up.

## What is not committed

Intermediate files such as `nonmem.exe`, `temp_dir/`, `FSUBS*` and `*.o` are
deleted by `R/runnm.R` immediately after the run. The eight report PDFs are
covered by `.gitignore`.
**The run folders themselves are committed.**

## Models added on 2026-09-19 (four supplements, run the same day)

These are the control streams of the four items under "supplements needing a
NONMEM run" in the WORKLOG. The data were made by `R/mkdata/make_blq.R` and
`R/mkdata/make_iv2.R`, and the run artifacts are committed too (all nine
MINIMIZATION SUCCESSFUL).

```sh
Rscript R/runnm.R 120m1 120m3 120m5 140iv2 200iv2 300iv2 108full 108wtbwt oq1
```

| Name | What | Ch |
|---|---|---|
| `120m1` `120m5` `120m3` | The Ch 16 data cut at an LLOQ of 0.5 mg/L, `data/iov-blq.csv` (13 % BLQ), handled by M1 (discard) / M5 (LLOQ/2) / M3 (`F_FLAG`, LAPLACE). The uncut fit is `120base` and the true values are in `iov-sim-truth.csv` | 6 |
| `140iv2` `200iv2` `300iv2` | Simulated two-compartment IV data `data/iv2-sim.csv` (40 subjects; true CL 5, V1 20, Q 8, V2 60) fitted with one, two and three compartments. One compartment bends the residuals; three is not supported by the data (condition number, SE) | 7 |
| `108full` | The full-model approach. CREA, APGR and SEX added to `108wt` all at once (judged by effect size and interval). SEX is a spurious covariate, so zero is the right answer | 9-10 |
| `108wtbwt` | Multicollinearity. WT and BWT (which have the same values in this data) put on clearance together. Only the sum of the two exponents is identifiable, so the SE, the condition number and the R matrix collapse | 9-10 |
| `oq1` | A worked OQ. The vendor example `examples/setest.ctl` verbatim (two compartments, FOCE-I). The reference output is in `Ref/oq/` | 3 |
