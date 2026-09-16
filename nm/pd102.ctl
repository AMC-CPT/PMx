$PROB NRS PD, OBS-BASELINE (TIME 0 NRS AS COVARIATE)   P:pd100  F:LB=logit(BSL)
$INPUT ID ARM DOSE TIME DV DVID MDV BSL BFLG
$DATA ../../data/pd-sim.csv IGNORE=@ IGNORE=(BFLG.EQ.1)
$PRED
  CL   = THETA(1) * EXP(ETA(1))
  V    = THETA(2) * EXP(ETA(2))
  BS   = BSL
  IF (BS.GT.9.9) BS = 9.9                   ; logit needs BSL < 10
  IF (BS.LT.0.1) BS = 0.1
  LB   = LOG(BS / (10 - BS))                ; baseline logit from the observed value
  PLMX = THETA(3) * EXP(ETA(3))
  KPL  = THETA(4)
  EMAX = THETA(5)
  EC50 = THETA(6) * EXP(ETA(4))

  CONC = DOSE / V * EXP(-CL / V * TIME)
  IF (TIME.LE.0) CONC = 0                   ; the baseline score is taken before the dose
  PL   = PLMX * (1 - EXP(-KPL * TIME))
  DR   = EMAX * CONC / (EC50 + CONC)
  L    = LB - PL - DR
  NRS  = 10 * EXP(L) / (1 + EXP(L))

  F    = CONC
  IF (DVID.EQ.2) F = NRS
  IPRE = F
  W    = 1
  IF (DVID.EQ.1) W = THETA(7) * IPRE
  IF (DVID.EQ.2) W = SQRT(THETA(8)**2 + THETA(9)**2 * IPRE * (10 - IPRE))
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 5)       ; CL (L/h)
  (0, 40)      ; V (L)
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
  0.2          ; PLMAX
  0.3          ; EC50

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DVID ARM DOSE DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V PLMX EC50 ETA1 ETA2 ETA3 ETA4
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID DOSE BSL
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID ARM
     ONEHEADER NOPRINT NOAPPEND FILE=catab
