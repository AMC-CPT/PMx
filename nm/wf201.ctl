$PROB WARFARIN PK/PD SIMULTANEOUS, TURNOVER (KIN INHIBITION)   P:wf100  F:BASE
$INPUT ID TIME AMT CMT DV DVID MDV EVID
$DATA ../../data/warf-sim.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
$MODEL COMP=(DEPOT DEFDOSE) COMP=(CENT DEFOBS) COMP=(PCA)

$PK
  KA   = THETA(1) * EXP(ETA(1))
  CL   = THETA(2) * EXP(ETA(2))
  V    = THETA(3) * EXP(ETA(3))
  BASE = THETA(4) * EXP(ETA(4))
  KOUT = THETA(5) * EXP(ETA(5))
  C50  = THETA(6) * EXP(ETA(6))
  KIN  = BASE * KOUT
  KE   = CL / V
  S2   = V
  A_0(3) = BASE

$DES
  CP = A(2) / V
  DADT(1) = -KA * A(1)
  DADT(2) =  KA * A(1) - KE * A(2)
  DADT(3) = KIN * (1 - CP / (C50 + CP)) - KOUT * A(3)

$ERROR
  IPRE = F
  W    = 1
  IF (DVID.EQ.1) W = THETA(7) * IPRE       ; concentration: proportional
  IF (DVID.EQ.2) W = THETA(8)              ; PCA: additive
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1)       ; KA (1/h)
  (0, 0.1)     ; CL (L/h)
  (0, 10)      ; V  (L)
  (0, 100)     ; BASE (%)
  (0, 0.05)    ; KOUT (1/h)
  (0, 1)       ; C50 (mg/L)
  (0, 0.1)     ; concentration proportional error CV
  (0, 5)       ; PCA additive error SD (%)

$OMEGA
  0.2          ; KA
  0.1          ; CL
  0.05         ; V
  0.02         ; BASE
  0.1          ; KOUT
  0.1          ; C50

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT CMT DV DVID MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID KA CL V BASE KOUT C50 ETA1 ETA2 ETA3 ETA4 ETA5 ETA6
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID AMT
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID DVID
     ONEHEADER NOPRINT NOAPPEND FILE=catab
