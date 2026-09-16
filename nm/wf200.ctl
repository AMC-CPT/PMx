$PROB WARFARIN PD, TURNOVER (KIN INHIBITION), IPP: PK FROM wf100 EBE   P:wf100  F:BASE
$INPUT ID TIME DV MDV EVID DOSE IKA ICL IV
$DATA ../../data/warf-ipp.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
$MODEL COMP=(PCA)

$PK
  ; individual PK parameters come in as data columns (empirical Bayes estimates of wf100)
  KA   = IKA
  CL   = ICL
  V    = IV
  KE   = CL / V
  BASE = THETA(1) * EXP(ETA(1))
  KOUT = THETA(2) * EXP(ETA(2))
  C50  = THETA(3) * EXP(ETA(3))
  KIN  = BASE * KOUT
  A_0(1) = BASE                            ; steady state before the dose

$DES
  ; the concentration is a forcing function: closed form of the 1-compartment oral model
  CP = DOSE * KA / (V * (KA - KE)) * (EXP(-KE * T) - EXP(-KA * T))
  DADT(1) = KIN * (1 - CP / (C50 + CP)) - KOUT * A(1)

$ERROR
  IPRE = A(1)
  W    = THETA(4)
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 100)     ; BASE (%)
  (0, 0.05)    ; KOUT (1/h)
  (0, 1)       ; C50 (mg/L)
  (0, 5)       ; additive error SD (%)

$OMEGA
  0.02         ; BASE
  0.1          ; KOUT
  0.1          ; C50

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME DV MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID BASE KOUT C50 ETA1 ETA2 ETA3
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID IKA ICL IV
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID DOSE
     ONEHEADER NOPRINT NOAPPEND FILE=catab
