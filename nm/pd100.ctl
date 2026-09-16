$PROB NRS PD, PLACEBO+ACTIVE, LOGIT LINK, EST-BASELINE   P:pd100x  F:BASE
$INPUT ID ARM DOSE TIME DV DVID MDV BSL=DROP BFLG=DROP
$DATA ../../data/pd-sim.csv IGNORE=@
$PRED
  CL   = THETA(1) * EXP(ETA(1))
  V    = THETA(2) * EXP(ETA(2))
  LB   = THETA(3) + ETA(3)                  ; baseline logit. logit(7/10) = 0.85
  PLMX = THETA(4) * EXP(ETA(4))             ; placebo response (logit units)
  KPL  = THETA(5)
  EMAX = THETA(6)                           ; drug effect (logit units)
  EC50 = THETA(7) * EXP(ETA(5))

  CONC = DOSE / V * EXP(-CL / V * TIME)
  IF (TIME.LE.0) CONC = 0                   ; the baseline score is taken before the dose
  PL   = PLMX * (1 - EXP(-KPL * TIME))
  DR   = EMAX * CONC / (EC50 + CONC)
  L    = LB - PL - DR
  NRS  = 10 * EXP(L) / (1 + EXP(L))         ; always strictly between 0 and 10

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
  (0.85)       ; LB, baseline logit
  (0, 0.8)     ; PLMAX (logit)
  (0, 0.2)     ; KPL (1/h)
  (0, 1.5)     ; EMAX (logit)
  (0, 2)       ; EC50 (mg/L)
  (0, 0.2)     ; PK proportional error CV
  (0, 0.4)     ; NRS error, floor SD
  (0, 0.15)    ; NRS error, bounded-scale coefficient

$OMEGA
  0.1          ; CL
  0.05         ; V
  0.1          ; LB
  0.2          ; PLMAX
  0.3          ; EC50

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DVID ARM DOSE DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V LB PLMX EC50 ETA1 ETA2 ETA3 ETA4 ETA5
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID DOSE
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID ARM
     ONEHEADER NOPRINT NOAPPEND FILE=catab
