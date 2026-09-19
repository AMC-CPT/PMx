# NONMEM 실행 자리

이 저장소의 규칙은 하나다.

| | 무엇으로 | 필요한 것 |
|---|---|---|
| **NONMEM 실행** | `Rscript R/runnm.R` | NONMEM 라이선스와 Fortran 컴파일러 |
| **R 실행** | `Rscript R/build.R` | R 만. **NONMEM 이 없어도 돈다** |
| **책 빌드** | `latexmk -xelatex PMx.tex` | LaTeX 만 |

실행 산출물(`.lst` `.ext` `.phi` 와 표 네 개)은 **커밋되어 있다.**
그래서 라이선스가 없는 PC 에서도 R 과 책 빌드가 그대로 돈다.
제어파일이나 자료를 고쳤을 때만 라이선스가 있는 PC 에서 `R/runnm.R` 을 돌린다.

`R/build.R` 은 **NONMEM 을 절대 부르지 않는다.** 커밋된 산출물을 읽을 뿐이고,
그것이 없으면 그 장을 건너뛰며 무엇을 돌려야 하는지 알려 준다.

## 모델 이름

`CTL_Style_Guide.md` 의 규칙을 따른다. 첫 숫자가 parent compartment 수다.

| 이름 | 무엇 | 장 |
|---|---|---|
| `100base` | 1구획 정맥 bolus, 공변량 없음. **기저 모형** | 7 |
| `101diag` | `$OMEGA` 만 대각으로 | 7 |
| `102sig` | 잔차오차를 `$THETA` 대신 `$SIGMA` 에 | 8 |
| `103mats` `104matr` | 공분산 추정량 S, R | 8 |
| `105start` | 초기값만 다르게 | 8 |
| `106wtcl` `107wtv` | 체중을 `CL` 에, `V` 에 | 9 |
| `108wt` | 체중을 둘 다에. **최종 공변량 모형** | 9 |
| `108wts` `108wtx` | 지수를 고정 | 10 |
| `108wtcr` `109sex` | 크레아티닌, 성별 | 9, 10 |
| `108wtsim` | `$SIM ONLYSIMULATION` 200회 (VPC) | 12 |
| `rpt` | 순열 검정용. `R/rpt.R` 이 임시 자료로 돌린다 | 13 |
| `boot` | bootstrap 용. `R/boot.R` 이 임시 자료로 돌린다 | 14 |
| `llp` `sir` | **템플릿이다. 그대로는 돌지 않는다** | 14 |
| `pd100x` | 약력학. 자연 척도에 효과를 더한 첫 시도 | 17 |
| `pd100` | 약력학. 로짓 연결, 위약군 포함, 추정 기저치. **17장의 최종 모형** | 17 |
| `pd101` `pd101b` `pd102` `pd103` | 위약군 제외 / 160 mg 군만 / 관측 기저치 / 복합 오차 | 17 |
| `pd100sim` | `pd100` 의 추정치로 200회 모의 (군별 VPC) | 17 |
| `pd200ord` | NRS 를 세 범주로 접은 비례 오즈 모형. `LAPLACE LIKELIHOOD` | 17 |
| `tg100`--`tg105` | 종양 부피. 지수 / 로지스틱 / Gompertz(대각, `b` 블록) / 멱함수 / von Bertalanffy(ADVAN13) / 축소 Gompertz | 19 |
| `tm100` | 완전 TMDD (2구획 + 표적 합성/분해/결합/해리/내재화, `ADVAN13`), FO. 원숭이 단클론항체 | 18 |
| `tm101` | 같은 구조를 FOCE-I 로 | 18 |
| `tm102` `tm104` | QSS 근사 (`KSS`) / Michaelis-Menten 극한 | 18 |
| `tm103` | 표적 합성의 절편을 뺀 완전 TMDD. **18장 둘째 예제의 최종 모형** | 18 |
| `tg103x` | 멱함수에서 `V0` 를 추정한 것(함정) | 19 |
| `tg102bsim` | `tg102b` 의 추정치로 200회 모의 (VPC) | 19 |
| `tg106` `tg107` | 치료군을 넣은 모의 자료. 효과 없음 / 성장률에 효과 | 19 |
| `110des` | theophylline 을 `ADVAN13` 으로. verbatim 코드로 `DAETA` 와 `G` 를 표에 낸다 | 8 |
| `120base` `120add` `120prop` | 세 회차 경구 자료. IIV 만. 복합 / 가법 / 비례 잔차 | 16 |
| `121iov` | 청소율과 흡수속도에 IOV (`BLOCK SAME`) | 16 |
| `122mix` `123mixiov` | `$MIX` 로 청소율 아집단. IOV 없이 / 함께. **16장의 최종 모형** | 16 |
| `124etaeps` | 잔차 크기에 개체간 변이 | 16 |
| `wf100` | warfarin 형 PK 만 (PCA 레코드 IGNORE) | 18 |
| `wf200` | 간접반응 I 형, IPP (개인 PK 를 자료 열로). `data/warf-ipp.csv` | 18 |
| `wf201` | 간접반응 I 형, PK/PD 동시 (`ADVAN13`, 구획 셋). **18장의 최종 모형** | 18 |
| `wf202` `wf203` | 효과구획 + 직접 Emax / IV 형 (틀린 기전) | 18 |
| `wf201sim` | `wf201` 의 추정치로 200회 모의 (VPC) | 18 |
| `tte100` `tte101` `tte102` | 시간-사건. 상수 위험 / Weibull / Weibull + 노출. `LAPLACE LIKELIHOOD` | 20 |
| `cnt100` `cnt101` `cnt102` | 카운트. Poisson / 음이항 / 음이항 약효 없음. `LAPLACE -2LL` | 20 |
| `ped100` `ped101` `ped102` | 소아 120명. 크기만 / 크기 + 성숙 / 지수 추정 | 21 |
| `ped104` | 신생아 제외 90명 (사전분포의 출처) | 21 |
| `ped103x` `ped103` | 신생아 30명만. 사전분포 없이 / `$PRIOR NWPRI` | 21 |
| `130mult` `130addl` `130ss` | 반복 경구 투여. 투약 전부 / `ADDL II` / `SS=1` (앞의 둘은 같은 답) | 7 |
| `130ssx` | 함정. 정상상태 전의 투약을 `SS=1` 로 | 7 |
| `sse` | 설계 비교의 모의-추정용. `R/sse.R` 이 임시 자료로 돌린다 | 22 |

접미사는 `s`(simplified 또는 `$COV MAT=S`), `i`(iteration), `x`(experimental).
`pd` 는 약력학, `tg` 는 종양성장, `wf` 는 warfarin 형 PK/PD, `tte` 와 `cnt` 는 시간-사건과 카운트, `ped` 는 소아 모형이다. 구획 수로 이름 짓는 규칙은 PK 모형에만 쓴다.

### 이름 없이 `R/runnm.R` 을 부를 때 빠지는 것

| | 왜 | 전체를 돌리는 법 | 결과 | 시간 |
|---|---|---|---|---|
| `rpt` | `data/_perm.csv`(임시)를 읽는다 | `Rscript R/rpt.R 200` | `nm/rpt/rpt.csv` | 약 37분 |
| `boot` | `data/_boot.csv`(임시)를 읽는다 | `Rscript R/boot.R 200` | `nm/boot/boot.csv` | 약 30분 |
| `sse` | `data/_sse.csv`(임시)를 읽는다 | `Rscript R/sse.R 100` | `nm/sse/sse.csv` | 약 45분 |
| `_` 로 시작하는 것 | 스크립트가 만들어 낸 것이다 | `Rscript R/llp.R`, `R/sir.R` | `nm/llp/llp.csv`, `nm/sir/sir.csv` | |

`llp.ctl` 과 `sir.ctl` 은 표시(`<T3>`, `<THETA>` 같은 것)가 박힌 **템플릿**이다.
`R/llp.R` 과 `R/sir.R` 이 그 줄만 바꿔 `nm/_llp.ctl`, `nm/_sir.ctl` 로 쓰고
돌린 뒤 지운다. `_` 로 시작하는 제어파일은 `runnm.R` 이 목록에서 뺀다.

수백 번 돌리는 것들의 결과는 전부 **작은 csv 한 장**으로 남는다. 그 파일만
있으면 13, 14장의 R 코드가 NONMEM 없이 돈다.

모의 전용 실행(`$SIM` 만 있고 `$EST` 가 없는 것)은 `runnm.R` 이 따로 다룬다.
수렴이라는 것이 없으므로 그것으로 판정하지 않고, 원본 `simtab`(8 MB)을
관측 레코드만 남긴 `simtab.csv`(0.6 MB)로 정리한다.

## 실행 방식

NONMEM 은 **작업 폴더에서** 돌린다(Analects 3). `R/runnm.R` 이
`nm/<모델>.R76/` 을 만들고 제어파일을 복사해 넣은 뒤 `-rundir` 로 실행한다.
끝나면 중간 파일만 지우고 **폴더는 그대로 남긴다.**

폴더를 남기는 것이 중요하다. `nmw` 의 후처리가 그 구조를 전제하기 때문이다.

| nmw 가 찾는 것 | 어디서 |
|---|---|
| 모형 이름 | 폴더 이름의 첫 마디 (`108wt.R76` -> `108wt`) |
| 표 | `sdtab` `patab` `cotab` `catab` (**번호를 붙이지 않는다**) |
| 종료 상태 | `PRINT.OUT` (`runnm.R` 이 `TrimOut` 으로 만든다) |
| 모형 계보 | `FCON` 의 `$PROB` 에 적은 `P:` 와 `F:` |
| 그 밖 | `.xml` `.ext` `.phi` `.grd` `.cov` `.cor` `.coi`, `FDATA.csv` |

보고 8종(`S1-OFV.PDF` 등)은 `Rscript R/build.R` 이 만들고 `.gitignore` 대상이다.
커밋된 산출물만 읽으므로 **NONMEM 이 없어도 만들어진다.**

제어파일은 순수 ASCII 로 쓴다. 한글 주석을 넣으면 보고서를 만들 때 글꼴이
없어 경고가 쏟아진다(CTL_Style_Guide 20.2).

그래서 제어파일의 `$DATA` 는 **작업 폴더 기준**으로 두 단계 위를 가리킨다.

```
$DATA ../../data/pheno-nm.csv IGNORE=@
```

## 라이선스 등록자 문자열

NONMEM 출력 머리에 라이선스 등록자와 날짜가 박힌다. 이 저장소는 공개
companion 으로 나갈 수 있으므로(`PUBLIC.md`), `R/runnm.R` 이 **거두는
자리에서** 그 줄을 `<LICENSEE>` 로 바꾼다. git 이력에 한 번도 들어가지 않는다.

공개 전에 raw byte 로 한 번 더 확인한다.

## `nmfe76.bat` 을 고치지 않는다

배포본의 `nmfe76.bat`(469줄)을 고쳐서 쓰면 편하지만, NONMEM 이 7.7 로 올라가면
그 수정을 **처음부터 다시** 해야 한다. 그래서 이 저장소는 원본을 그대로 부르고
필요한 것을 앞뒤에 붙인다. `R/runnm.R` 이 그 껍데기다.

```
[앞]   작업 폴더를 만들고 제어파일을 복사한다
[호출] 배포본 nmfe76.bat 을 손대지 않고 그대로 부른다
[뒤]   PRINT.OUT 을 만들고, 라이선스 문자열을 치환하고, 중간 파일을 지운다
```

저자가 오래 써 온 개인 수정본 `nmfe76.bat`(559줄)과 대조하면 수정이 다섯
갈래인데, **네 갈래는 nmfe 안에 있을 이유가 없다.**

| 갈래 | 저자 수정본 | 껍데기로 옮기면 |
|---|---|---|
| 환경 | `chcp 437`, `Editor`, `NMaDir` | 껍데기의 변수 |
| **앞** | `MD %rundir%`, `COPY %1`, 묵은 `PRINT.OUT` 삭제 | 껍데기의 앞 단계 |
| **뒤** | `PP1--PP5`, `PPa--PPc` 여덟 R 스크립트 | **`nmw::nmw_run()` 한 줄.** 그 여덟은 2022년판이고 지금은 저자의 `nmw` 패키지가 같은 일을 한다 |
| **뒤** | 중간 파일 20여 개 삭제, `worker1--23` 삭제 | 남길 목록만 정해 두고 나머지를 지운다 |
| 마무리 | `SumOut.R`, `PAUSE`, 편집기로 열기 | 사람이 쓰는 편의. 껍데기의 선택 인자로 둔다 |

**나머지 한 갈래만 진짜 수정이다.** 배포본의 버그 둘이다.

- `pushdon=1` 에 `set` 이 빠져 있다(469줄판 118행). 콘솔에 오류 한 줄이
  찍힐 뿐 결과에는 영향이 없다
- `call gfcompile.bat` 이 현재 폴더를 찾지 못할 수 있다.
  `call .\gfcompile.bat` 이면 언제나 찾는다

둘째는 `NoDefaultCurrentDirectoryInExePath` 가 켜진 환경에서만 드러나고,
그때는 **밖에서 그 변수를 해제하면 원본 그대로 돈다.** `R/runnm.R` 이 그렇게 한다.
그래서 이 저장소는 `nmfe76.bat` 사본을 두지 않는다.

껍데기를 배치파일로 쓰고 싶다면 같은 구조를 그대로 옮기면 된다.

```bat
@echo off
set NM=C:\nm76g64\run\nmfe76.bat
set MODEL=%1
md "%MODEL%.R76" 2>nul
copy "%MODEL%.ctl" "%MODEL%.R76" >nul
set NoDefaultCurrentDirectoryInExePath=
call "%NM%" %MODEL%.ctl %MODEL%.lst -rundir=%MODEL%.R76
Rscript -e "nmw::nmw_run('%MODEL%.R76')"
```

R 쪽을 권한다. 후처리가 이미 R 이고, 한 곳에 두면 nm75/nm76 양쪽을 같은
코드로 다룰 수 있으며, 버전이 올라가도 고칠 것이 없다.

## 커밋하지 않는 것

`nonmem.exe`, `temp_dir/`, `FSUBS*`, `*.o` 같은 중간 파일은 `R/runnm.R` 이
실행 직후 지운다. 보고 8종 PDF 는 `.gitignore` 대상이다.
**실행 폴더 자체는 커밋한다.**

## 2026-09-19 에 더한 모형 (증보 4건. 같은 날 실행 완료)

WORKLOG 의 "NONMEM 실행이 필요한 증보" 네 건의 제어파일이다. 자료는 `R/mkdata/make_blq.R`,
`R/mkdata/make_iv2.R` 이 만들었고, 실행 산출물도 커밋되어 있다(아홉 개 모두 MINIMIZATION SUCCESSFUL).

```sh
Rscript R/runnm.R 120m1 120m3 120m5 140iv2 200iv2 300iv2 108full 108wtbwt oq1
```

| 이름 | 무엇 | 장 |
|---|---|---|
| `120m1` `120m5` `120m3` | 16장 자료를 LLOQ 0.5 mg/L 에서 자른 `data/iov-blq.csv`(BLQ 13 %)를 M1(버림) / M5(LLOQ/2) / M3(F_FLAG, LAPLACE)로. 자르지 않은 적합은 `120base`, 참값은 `iov-sim-truth.csv` | 6 |
| `140iv2` `200iv2` `300iv2` | 2구획 정맥 모의 자료 `data/iv2-sim.csv`(40명, 참값 CL 5, V1 20, Q 8, V2 60)를 1·2·3구획으로. 1구획은 잔차가 굽고, 3구획은 자료가 지지하지 않는다(조건수·SE) | 7 |
| `108full` | 완전 모형 접근. `108wt` 에 CREA·APGR·SEX 를 한꺼번에(효과크기와 구간으로 판단). SEX 는 가짜 공변량이라 0 이 정답 | 9-10 |
| `108wtbwt` | 다중공선성. WT 와 BWT(이 자료에서는 값이 같다)를 청소율에 함께 넣는다. 지수 둘의 합만 식별되므로 SE·조건수·R 행렬이 무너진다 | 9-10 |
| `oq1` | OQ 실례. 벤더 예제 `examples/setest.ctl` 원문(2구획, FOCE-I). 기준 출력은 `Ref/oq/` | 3 |
