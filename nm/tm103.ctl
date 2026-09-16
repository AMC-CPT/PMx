$PROB MAB IN MONKEY, 2COMP + FULL TMDD, KSYN INTERCEPT DROPPED (FINAL)   P:tm100  F:CL~BWT,V1~BWT,KSYN~BWT
$INPUT ID LVL SEX BWT TIME AMT DV MDV
$DATA ../../data/tmdd-mab.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
$MODEL COMP=(CENTRAL DEFDOSE DEFOBS) COMP=(PERIPH) COMP=(TARGET) COMP=(COMPLEX)

$PK
  ; amounts (mg) in every compartment. KON is therefore per mg per hour.
  TVCL = THETA(1) * BWT
  TVV1 = THETA(2) * BWT
  CL   = TVCL * EXP(ETA(1))
  V1   = TVV1 * EXP(ETA(2))
  Q    = THETA(3)
  V2   = THETA(4) * EXP(ETA(3))
  K    = CL / V1
  K12  = Q / V1
  K21  = Q / V2
  S1   = V1

  KON  = THETA(5)
  KOFF = THETA(6)
  KINT = THETA(7)
  TVSY = THETA(12) * BWT                  ; tm100 put the intercept on its bound: synthesis scales with size
  TVDE = THETA(9)
  KSYN = TVSY * EXP(ETA(4))
  KDEG = TVDE * EXP(ETA(5))
  BASE = KSYN / KDEG                        ; free target at steady state before the dose
  A_0(3) = BASE

$DES
  ; mass balance: every term that leaves one compartment enters another
  DADT(1) = -(K + K12) * A(1) + K21 * A(2) - KON * A(1) * A(3) + KOFF * A(4)
  DADT(2) = K12 * A(1) - K21 * A(2)
  DADT(3) = KSYN - KDEG * A(3) - KON * A(1) * A(3) + KOFF * A(4)
  DADT(4) = KON * A(1) * A(3) - (KOFF + KINT) * A(4)

$ERROR
  IPRE = F                                  ; free drug concentration (the assay measures free drug)
  RO   = A(4) / (A(3) + A(4))               ; receptor occupancy at this time
  RTOT = A(3) + A(4)                        ; total target
  W    = SQRT(THETA(10)**2 + THETA(11)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (1E-5, 0.0003, 0.003)   ; CL per kg (L/h/kg)
  (1E-3, 0.03, 0.3)       ; V1 per kg (L/kg)
  (1E-4, 0.004, 0.04)     ; Q (L/h)
  (1E-3, 0.02, 0.2)       ; V2 (L)
  (1E-2, 0.4, 4)          ; KON (1/mg/h)
  (1E-4, 0.003, 0.03)     ; KOFF (1/h)
  (1E-3, 0.02, 0.2)       ; KINT (1/h)
  0 FIX                   ; KSYN intercept, dropped (kept so THETA numbers match tm100)
  (1E-3, 0.2, 2)          ; KDEG (1/h)
  (1E-8, 0.1, 20)         ; additive error SD (mg/L)
  (1E-3, 0.07, 0.2)       ; proportional error CV
  (1E-3, 0.2, 2)          ; KSYN slope on BWT (mg/h/kg)

$OMEGA BLOCK(3)
  0.2
  0.1 0.2
  0.1 0.1 0.9
$OMEGA BLOCK(2)
  0.2
  0.1 0.2

$SIGMA 1 FIX

; FO with POSTHOC etas, as this model was run in practice: a 4-state ODE with five
; etas is slow under FOCE-I, and FO gave a usable answer in minutes (see the text).
$EST MAX=9999 PRINT=10 METHOD=ZERO POSTHOC NSIG=2 SIGL=6
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME LVL DV MDV IPRE IWRE CWRES RO RTOT
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V1 Q V2 KON KOFF KINT KSYN KDEG BASE ETA1 ETA2 ETA3 ETA4 ETA5
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID BWT LVL
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID SEX
     ONEHEADER NOPRINT NOAPPEND FILE=catab
