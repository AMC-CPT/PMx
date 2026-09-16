$PROB PHENO SIR   P:108wt  F:CL~WT,V~WT
$INPUT ID DAT2=DROP TIME AMT RATE CMT DV MDV EVID
       WT BWT SEX APGR CREA TAFD=DROP
$DATA ../../data/pheno-nm.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  TVCL = THETA(1) * (WT/1.5)**THETA(5)
  TVV  = THETA(2) * (WT/1.5)**THETA(6)
  CL   = TVCL * EXP(ETA(1))
  V    = TVV  * EXP(ETA(2))
  S1   = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  Y    = IPRE + W * EPS(1)

; This is a TEMPLATE, not a runnable model as it stands.
; R/sir.R replaces the two marked lines with one drawn parameter vector
; and writes the result to nm/_sir.ctl. Control files whose name starts
; with an underscore are generated; R/runnm.R skips them.
;
; Everything is FIXed and MAXEVAL=0, so NONMEM estimates nothing. It only
; evaluates the objective function at the drawn vector. The inner ETA
; optimisation still runs, so this is the FOCE-I objective, not a
; first-order approximation of it.
$THETA
<THETA>
$OMEGA BLOCK(2) FIX
<OMEGA>
$SIGMA 1 FIX

$EST MAXEVAL=0 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
