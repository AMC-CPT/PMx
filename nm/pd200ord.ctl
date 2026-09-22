$PROB NRS AS ORDINAL (0-3/4-6/7-10), PROPORTIONAL ODDS   P:ROOT  F:BASE
$INPUT ID ARM DOSE TIME DV MDV
$DATA ../../data/pd-ord.csv IGNORE=@
$PRED
  ; PK is fixed to the pd100 estimates (CL 5.06, V 39.2), rounded
  ; (sequential PK/PD). This dataset carries no concentrations.
  CL   = 5.0
  V    = 40
  CONC = DOSE / V * EXP(-CL / V * TIME)
  IF (TIME.LE.0) CONC = 0

  ; Cumulative logit. The intercepts of P(Y>=1) and P(Y>=2) are written as a
  ; difference so that A1 > A2 is enforced.
  A1   = THETA(1) + ETA(1)
  A2   = A1 - THETA(2)
  PLMX = THETA(3)
  KPL  = THETA(4)
  EMAX = THETA(5)
  EC50 = THETA(6)
  PL   = PLMX * (1 - EXP(-KPL * TIME))
  DR   = EMAX * CONC / (EC50 + CONC)
  EFF  = PL + DR                      ; lowering pain lowers the logit

  L1   = A1 - EFF
  L2   = A2 - EFF
  P1   = EXP(L1) / (1 + EXP(L1))      ; P(Y>=1)
  P2   = EXP(L2) / (1 + EXP(L2))      ; P(Y>=2)
  IF (DV.EQ.0) P = 1 - P1
  IF (DV.EQ.1) P = P1 - P2
  IF (DV.EQ.2) P = P2
  IF (P.LT.1E-10) P = 1E-10
  Y    = P

$THETA
  (2)          ; A1 logit P(Y>=1) at baseline, no effect
  (0, 2)       ; A1 - A2
  (0, 1)       ; PLMAX (logit)
  (0, 0.2)     ; KPL (1/h)
  (0, 2)       ; EMAX (logit)
  (0, 2)       ; EC50 (mg/L)

$OMEGA 1

$EST MAX=9999 PRINT=5 METHOD=COND LAPLACE LIKELIHOOD NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME ARM DOSE DV MDV P P1 P2
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID A1 ETA1
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID DOSE
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID ARM
     ONEHEADER NOPRINT NOAPPEND FILE=catab
