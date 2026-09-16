$PROB IOV DATA, 1COMP ORAL, IIV + MIXTURE ON CL   P:120base  F:BASE
$INPUT ID TIME AMT DV MDV EVID OCC POP
$DATA ../../data/iov-sim.csv IGNORE=@
$SUBR ADVAN2 TRANS2
$ABBR DERIV2=NO

$PK
  ; two subpopulations that differ in CL. NONMEM sets MIXNUM (1 or 2) for each call.
  FPM = THETA(6)                          ; CL of subpopulation 2 relative to 1 (< 1)
  CLF = 1
  IF (MIXNUM.EQ.2) CLF = FPM
  KA = THETA(1) * EXP(ETA(1))
  CL = THETA(2) * CLF * EXP(ETA(2))
  V  = THETA(3) * EXP(ETA(3))
  S2 = V

$MIX
  NSPOP = 2
  P(1) = 1 - THETA(7)
  P(2) = THETA(7)                         ; fraction in subpopulation 2

$ERROR
  MEST = MIXEST                           ; estimated subpopulation, meaningful at the table step
  IPRE = F
  W    = 1
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2)
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
  (0, 0.4, 1)  ; FPM, CL ratio of subpopulation 2
  (0, 0.2, 1)  ; fraction of subpopulation 2

$OMEGA
  0.1          ; KA
  0.1          ; CL
  0.05         ; V

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID OCC KA CL V IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID KA CL V ETA1 ETA2 ETA3
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID OCC
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID POP MEST
     ONEHEADER NOPRINT NOAPPEND FILE=catab
