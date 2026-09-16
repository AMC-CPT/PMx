$PROB TTE, CONSTANT HAZARD, DOSE EFFECT   P:ROOT  F:BASE
$INPUT ID TIME DV MDV EVID DOSE CAVG
$DATA ../../data/tte-sim.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$MODEL COMP=(CUMHAZ)

$PK
  LAM  = THETA(1) * EXP(ETA(1))           ; ETA(1) is a placeholder (OMEGA 0 FIX)
  BETA = THETA(2)
  RH   = EXP(-BETA * DOSE / 100)          ; hazard ratio per 100 mg

$DES
  DADT(1) = LAM * RH                      ; cumulative hazard

$ERROR
  CHZ = A(1)
  SUR = EXP(-CHZ)                         ; survival to this time
  HAZ = LAM * RH                          ; hazard at this time
  IF (DV.EQ.0) Y = SUR                    ; censored
  IF (DV.EQ.1) Y = HAZ * SUR              ; event: density

$THETA
  (0, 0.1)     ; LAM (1/month)
  (0.5)        ; BETA, log hazard ratio per 100 mg

$OMEGA 0 FIX

$EST MAX=9999 PRINT=5 METHOD=COND LAPLACE LIKELIHOOD NSIG=3 SIGL=9 NOABORT
$COV UNCOND PRINT=E
$TAB ID TIME DV MDV EVID DOSE CAVG CHZ SUR HAZ
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID LAM RH
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID CAVG
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID DOSE
     ONEHEADER NOPRINT NOAPPEND FILE=catab
