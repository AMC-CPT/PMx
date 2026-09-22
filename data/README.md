# Example data

The examples of this book use **public data and simulated data this book
made**. The data of real projects are the source of the workflows and the
failure cases only; they are in neither the text nor this repository. For the
second example of Ch 18 alone the book used data from a real analysis (with the
development code removed), and the `tmdd-mab.csv` here is a stand-in that
simulates the same design from the book's final model (`R/mkdata/sim_tmdd.R`,
seed 2026). So rerunning `nm/tm10?.ctl` gives numbers close to the book's
rather than equal to them, and the run artifacts `nm/tm10?.R76/` are not here
either.

## `pheno.csv` — the known-answer dataset

Phenobarbital neonate data. A **NONMEM distribution example** (Beal &
Sheiner); the original is the fixed-width file `PHENO` (the `FIN` on its last
line is NONMEM's end marker).

| | |
|---|---|
| Rows | 744 (589 doses, 155 observations) |
| Subjects | 59 |
| Columns | `ID TIME AMT WT APGR DV MDV EVID` |
| Note | `WT` and `APGR` are constant within a subject. Median 12 doses per subject |

## `theo-raw.txt` — the mistyped dose of Ch 6

A copy of `util/THEO` from the NONMEM distribution (132 rows, 12 subjects).
The columns are `ID DOSE TIME CP WT`, and `DOSE` is in mg/kg.

The design gives **320 mg of theophylline orally to everyone**. Multiplying
back by the weight gives 318.6–320.6 mg for eleven of them and **267.8 mg for
subject 9 alone** (3.10 × 86.4), 52 mg short. Since $320/86.4 = 3.7037$, the
value that should have been written is 3.70, and corrected to 3.7 it gives
319.68 mg.

A 7 written in the American way looks almost like a 1 (the Korean 7 has one
more stroke at the upper left), so it appears to be an error made in
transcribing handwriting. **The same error is in R's built-in `Theoph`.**

Chapter 6 opens with this. The reproduction is `R/snippets/ch06-theo-dose.R`
and `R/snippets/ch06-theo-fix.R`, and the frozen output is in `output/`.

## `sdtm/` — source domains for the Ch 5 exercise

> **These domains are an artifact this book made.** They are not real clinical
> trial data. They were made by **decomposing** `pheno.csv` above.

Chapter 5 teaches the process of assembling scattered domains, and the only
public data available are NONMEM datasets that are already assembled.
Decomposing one means that when it is put back together **the answer is
already known**, so a reader can verify their own pipeline for themselves.
This is the same policy as this book's "test it on data whose true values you
know".

| File | Rows | Contents |
|---|---|---|
| `dm.csv` | 59 | Demographics. **The weight is not here** (the first point of Ch 5) |
| `ex.csv` | 589 | Dosing records |
| `pc.csv` | 214 | Concentrations, recorded at the **nominal time**. Includes 59 pre-dose zero records |
| `pc_coll.csv` | 214 | The **actual collection time** (the true value). The nominal time is on a 30-minute grid, so it is out by up to 12 minutes |
| `vs.txt` | 146 | Weight. **Tab separated.** Measured at every visit, so time-varying |
| `lb.csv` | 118 | Creatinine. **The censored values are strings** (`"<0.2"`, `"<17.7"`) |
| `lb_norm.csv` | 3 | **Upper limit of normal by site.** Site 03 uses different units |

### The six problems planted on purpose

What Chapter 5 has to teach was put into the data beforehand.

1. **The weight is in VS, not in DM.** And it is measured at every visit, so it
   is time-varying. The baseline (DAY 1) equals the `WT` of `pheno.csv`, so
   treating it as time-invariant matches the known answer and treating it as
   time-varying does not. The difference between the two choices can be seen
   with the eye
2. **The nominal time and the actual collection time differ.** `pc.csv` holds
   the nominal time on a 30-minute grid and the actual time is in
   `pc_coll.csv`. Fitting on the nominal time creates bias. **The actual
   collection time is the true value of the raw data.** Assembled with it, the
   result matches `pheno.csv` exactly; assembled with the nominal time, 63 of
   the 155 observations are out by up to 12 minutes
3. **The censored values are strings.** `LBORRES` holds `"<0.2"`, so
   `as.numeric()` turns it into `NA`
4. **The upper limit of normal and the units differ by site.** Sites 01 and 02
   are in mg/dL (limits 0.50 and 0.60) and site 03 in umol/L (limit 53.0).
   Without joining `lb_norm.csv` on `SITEID`, a renal-function covariate ends
   up measuring a site effect
5. **There are pre-dose zero records.** The drug is not endogenous, so they are
   a priori zero. For NCA they must be included; for NONMEM they are left with
   `MDV=1` or removed. They are also excluded from both the numerator and the
   denominator of the BLQ proportion (identified by `PCREASND == "PREDOSE"`)
6. **The file formats differ.** `vs.txt` alone is tab separated; the rest are
   comma separated

### Reproduction

```sh
Rscript R/mkdata/make_sdtm.R
```

`set.seed(20260914)`, with `RNGkind()` being
`"Mersenne-Twister" "Inversion" "Rejection"`. The generator needs the original
`PHENO` file (the `SRC` path of `make_sdtm.R`).
**The generated files are committed, so it need not be run again.**

### How to cite

When these data are used in the text, state the following.

> Phenobarbital neonate data (Beal SL, Sheiner LB. NONMEM distribution
> example). The SDTM-form domains of Chapter 5 were made by this book by
> decomposing those data.

## `pheno-nm.csv` — what Ch 5 assembled

The `sdtm/` above put back together by the pipeline of Chapter 5. **It is not
made by hand.** The last line of `R/snippets/ch05-check.R` writes it, and only
what passes the `stopifnot()` just before that comes out. So this file is a
by-product of `Rscript R/build.R`.

| | |
|---|---|
| Rows | 803 (589 doses, 155 observations, **59 pre-dose samples**) |
| Columns | `ID TIME AMT RATE CMT DV MDV EVID WT BWT SEX APGR CREA DAT2 CLOCK` |
| Against the answer | Excluding the 59 pre-dose rows, it matches the 744 rows of `pheno.csv` throughout |

It differs from `pheno.csv` in three ways: (i) the 59 pre-dose samples remain,
with `MDV=1`; (ii) the covariates `BWT` (time-varying weight), `SEX` and `CREA`
are added; (iii) the wall-clock time `DAT2`/`CLOCK` is kept for tracing.
**`SEX` is a spurious covariate assigned by the parity of the subject number**,
so it must not be used as an example of a covariate search.

Chapter 6 takes this file as its input and checks it
(`R/snippets/ch06-*.R`).

## Simulated data (the true values are known)

| File | Generating script | Contents | Ch |
|---|---|---|---|
| `pd-sim.csv` `pd-ord.csv` | `R/mkdata/make_pd.R` | Pain NRS, four arms including placebo, 160 subjects | 17 |
| `iov-sim.csv` | `R/mkdata/make_iov.R` | Three oral occasions, 60 subjects. IOV and clearance subpopulations (the `POP` column is the true value) | 16 |
| `warf-sim.csv` `warf-ipp.csv` | `R/mkdata/make_warf.R`, `make_warf_ipp.R` | Warfarin-type PK/PD, 40 subjects. The IPP version carries the EBEs of `wf100` as columns | 18 |
| `tmdd-mab.csv` | `R/mkdata/sim_tmdd.R` (a simulated stand-in, seed 2026) | Monoclonal antibody in 50 monkeys, six doses. The same design as the book's original data | 18 |
| `tgi-*.csv` | `R/mkdata/make_tgi.R`, `make_tgi_trt.R` | Tumor volume (public data re-tidied) and a simulated treatment arm | 19 |
| `tte-sim.csv` `cnt-sim.csv` | `R/mkdata/make_tte.R` | Time-to-event, 300 subjects; seizure counts, 200 subjects | 20 |
| `ped-sim.csv` `ped-neo.csv` `ped-old.csv` | `R/mkdata/make_ped.R` | 120 pediatric subjects and subsets of them | 21 |
| `theo-nm.csv` | `R/mkdata/make_theo.R` | THEO as a NONMEM dataset | 7, 8 |
| `mult-explicit.csv` `mult-addl.csv` `mult-ss.csv` `mult-ssx.csv` | `R/mkdata/make_mult.R` | Repeated oral dosing in 30 subjects coded three ways, and the trap | 7 |

`*-truth.csv` holds the true values of each dataset. Every script carries its
seed.

## Added 2026-09-19 (the data of the four supplements)

| File | Generating script | Contents | Ch |
|---|---|---|---|
| `iov-blq.csv` | `R/mkdata/make_blq.R` | The observations of `iov-sim.csv` cut at an LLOQ of 0.5 mg/L. The `DV` of rows whose `BLQ` column is 1 is LLOQ/2. Of 1,260 observations, 164 are BLQ (13.0 %) | 6 |
| `iv2-sim.csv` `iv2-sim-truth.csv` | `R/mkdata/make_iv2.R` | Two-compartment IV bolus, 40 subjects, 11 samples each. `WT` and `SEX` are spurious covariates that fill out the table | 7 |
| `example1.csv` | (the NONMEM 7.6 distribution's `examples/`) | The data of the vendor OQ example `setest.ctl`. Third-party work; excluded from the public repository | 3 |
