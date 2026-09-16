$PROB NRS PD, FIRST ATTEMPT: NATURAL SCALE WITH IF CLIPPING   P:ROOT  F:BASE
$INPUT ID ARM DOSE TIME DV DVID MDV BSL=DROP BFLG=DROP
$DATA ../../data/pd-sim.csv IGNORE=@
$PRED
  CL   = THETA(1) * EXP(ETA(1))
  V    = THETA(2) * EXP(ETA(2))
  BASE = THETA(3) * EXP(ETA(3))
  PLMX = THETA(4) * EXP(ETA(4))
  KPL  = THETA(5)
  EMAX = THETA(6)
  EC50 = THETA(7) * EXP(ETA(5))

  CONC = DOSE / V * EXP(-CL / V * TIME)
  IF (TIME.LE.0) CONC = 0                   ; the baseline score is taken before the dose
  PL   = PLMX * (1 - EXP(-KPL * TIME))
  DR   = EMAX * CONC / (EC50 + CONC)
  NRS  = BASE - PL - DR
  IF (NRS.LT.0)  NRS = 0                    ; the scale is bounded
  IF (NRS.GT.10) NRS = 10

  F    = CONC
  IF (DVID.EQ.2) F = NRS
  IPRE = F
  W    = 1
  IF (DVID.EQ.1) W = THETA(8) * IPRE
  IF (DVID.EQ.2) W = SQRT(THETA(9)**2 + THETA(10)**2 * IPRE * (10 - IPRE))
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 5)       ; CL (L/h)
  (0, 40)      ; V (L)
  (0, 7)       ; BASE (NRS)
  (0, 2)       ; PLMAX (NRS)
  (0, 0.2)     ; KPL (1/h)
  (0, 3)       ; EMAX (NRS)
  (0, 2)       ; EC50 (mg/L)
  (0, 0.2)     ; PK proportional error CV
  (0, 0.4)     ; NRS error, floor SD
  (0, 0.15)    ; NRS error, bounded-scale coefficient

$OMEGA
  0.1          ; CL
  0.05         ; V
  0.03         ; BASE
  0.2          ; PLMAX
  0.3          ; EC50

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DVID ARM DOSE DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V BASE PLMX EC50 ETA1 ETA2 ETA3 ETA4 ETA5
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID DOSE
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID ARM
     ONEHEADER NOPRINT NOAPPEND FILE=catab
