$PROB THEO 1COMP, ZERO-ORDER ABSORPTION (RATE=-2)   P:110ka  F:BASE
$INPUT ID TIME AMT RATE DV MDV EVID WT
$DATA ../../data/theo-nm.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  TVD1 = THETA(1)
  TVCL = THETA(2)
  TVV  = THETA(3)
  D1   = TVD1 * EXP(ETA(1))                 ; duration of zero-order input (h)
  CL   = TVCL * EXP(ETA(2))
  V    = TVV  * EXP(ETA(3))
  S1   = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1)       ; D1, input duration (h)
  (0, 3)       ; CL (L/h)
  (0, 30)      ; V  (L)
  (0, 0.5)     ; additive error SD (mg/L)
  (0, 0.1)     ; proportional error CV

$OMEGA
  0.4          ; D1
  0.1          ; CL
  0.05         ; V

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID D1 CL V ETA1 ETA2 ETA3
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID WT
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID EVID
     ONEHEADER NOPRINT NOAPPEND FILE=catab
