$PROB IOV DATA, 1COMP ORAL, IIV ON RESIDUAL MAGNITUDE   P:120base  F:BASE
$INPUT ID TIME AMT DV MDV EVID OCC POP
$DATA ../../data/iov-sim.csv IGNORE=@
$SUBR ADVAN2 TRANS2
$ABBR DERIV2=NO

$PK
  KA = THETA(1) * EXP(ETA(1))
  CL = THETA(2) * EXP(ETA(2))
  V  = THETA(3) * EXP(ETA(3))
  S2 = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2) * EXP(ETA(4))   ; individual error scale
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1)       ; KA (1/h)
  (0, 3)       ; CL (L/h)
  (0, 50)      ; V  (L)
  (0, 0.05)    ; additive error SD (mg/L)
  (0, 0.1)     ; proportional error CV

$OMEGA
  0.1          ; KA
  0.1          ; CL
  0.05         ; V
  0.1          ; residual scale

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID OCC KA CL V IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID KA CL V ETA1 ETA2 ETA3 ETA4
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID OCC
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID POP
     ONEHEADER NOPRINT NOAPPEND FILE=catab
