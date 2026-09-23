# 계량약리학 with NONMEM and R: 예제 저장소

*An English description is in [README.md](README.md).*

배균섭, 『계량약리학 with NONMEM and R』(Pharmacometrics with NONMEM and R)의
companion 저장소다. 책에 실린 **모든 숫자와 그림을 독자가 다시 만들 수 있게** 하는
것이 목적이며, 책 본문은 여기 없다.

이 책에는 국문판과 영문판이 있고 이 저장소 하나가 둘을 함께 받는다. 국문판 본문에
실리는 R 코드는 `R/snippets/` 에 한글 주석으로 있고, 영문판의 같은 코드는
`En/R/snippets/` 에 있다. 둘이 내놓는 숫자는 같다.

> **이 책으로 공부하려면 NONMEM 라이선스가 있어야 한다.** 제어파일을 고쳐 다시 돌리고
> 결과가 어떻게 달라지는지 보는 것이 연습이고, 그것은 라이선스가 있는 PC 에서만 된다.
> 다만 NONMEM 실행 산출물을 함께 두었으므로 라이선스가 없어도 R 코드는 그대로 돌아
> 본문의 숫자를 확인할 수 있다.

## 규칙은 하나다

| | 무엇으로 | 필요한 것 |
|---|---|---|
| **NONMEM 실행** | `Rscript R/runnm.R [모형 ...]` | NONMEM 7.6 라이선스와 gfortran |
| **R 실행 (국문판)** | `Rscript R/build.R` | R 만. NONMEM 이 없어도 돈다 |
| **R 실행 (영문판)** | `Rscript En/build.R` | R 만. NONMEM 이 없어도 돈다 |

`R/build.R` 은 NONMEM 을 절대 부르지 않는다. `nm/<모형>.R76/` 에 커밋된 실행 산출물을 읽어
`output/`(콘솔 출력)과 `figures/`(그림)를 다시 만든다. 제어파일이나 자료를 고쳤을 때만
`R/runnm.R` 로 다시 돌린다.

## 구조

```
R/snippets/chNN-*.R   본문에 실리는 R 코드의 원본 (장 번호 = 책의 장)
R/build.R             snippets 를 돌려 output/ 과 figures/ 를 만든다
R/_freeze.R           그 도우미
R/runnm.R             NONMEM 을 돌린다 (라이선스가 있는 PC 에서만)
R/rpt.R boot.R llp.R sir.R sse.R   수백 번 돌리는 것들 (13, 14, 22장)
R/mkdata/             모의 자료를 만드는 스크립트 (seed 가 박혀 있다)
data/                 예제 자료. README.md 에 출처가 있다
nm/<모형>.ctl         제어파일. README.md 에 모형 이름표가 있다
nm/<모형>.R76/        그 실행 산출물 (.lst .ext .phi 와 표 넷). 라이선스 문자열은 지웠다
nm/boot/ rpt/ llp/ sir/ sse/   수백 번 돌린 결과의 요약 csv
output/               얼린 콘솔 출력 (책에 실린 그대로)
figures/              얼린 그림
En/                   영문판의 같은 것 (아래)
docker/               15장의 Dockerfile 과 명령 모음
Ref/growth/dataset/   Benzekry 등이 공개한 종양 부피 자료 (19장)
```

### `En/`: 영문판

```
En/R/snippets/chNN-*.R   같은 코드의 주석·이름표·메시지를 영어로 옮긴 것
En/build.R               그것을 돌려 En/output/ 과 En/figures/ 를 만든다
En/output/               영문판의 얼린 콘솔 출력
En/figures/              영문판의 얼린 그림 (라틴 글꼴)
```

`En/build.R` 은 `R/_freeze.R` 을 그대로 쓰고 경로 셋만 갈아 끼우므로 두 판이 한
파이프라인을 공유한다. `En/output/` 의 얼린 숫자는 `output/` 의 짝과 모두 같고,
다른 것은 이름표뿐이다.

## 시작하기

```sh
git clone https://github.com/AMC-CPT/PMx
cd PMx
Rscript R/build.R          # NONMEM 없이. output/ 과 figures/ 가 다시 만들어진다
Rscript En/build.R         # 영문판의 것
```

NONMEM 이 있으면 (`C:/nm76g64/run/nmfe76.bat` 또는 환경변수 `NMFE`):

```sh
Rscript R/runnm.R 100base      # 한 모형
Rscript R/runnm.R              # 전부 (rpt, boot, sse 는 각각의 스크립트로)
Rscript R/boot.R 200           # 14장의 bootstrap
```

필요한 R 패키지: `nmw`(CRAN), `deSolve`, `survival`, 그리고 12장 NPDE 에 쓰는 `npde`
(없으면 `R/build.R` 이 그 스니펫 하나만 건너뛴다). 나머지는 base R 이다.

## 자료의 출처

- `data/pheno.csv`, `data/theo-raw.txt`: NONMEM 배포본의 예제(PHENO, THEO). Beal & Sheiner.
- `data/sdtm/`, `data/*-sim.csv`: 이 책이 만든 모의 자료. 생성 스크립트와 seed 가 `R/mkdata/` 에 있다.
- `Ref/growth/dataset/`: Benzekry S, et al. PLoS Comput Biol 2014;10:e1003800 및
  Vaghi C, et al. PLoS Comput Biol 2020;16:e1007178 이 공개한 자료.

- `data/tmdd-mab.csv`: 18장 둘째 예제(TMDD)의 **모의 대역**. 책은 저자가 실무에서 분석한 원숭이
  자료(개발 코드를 지운 것)를 썼고 그 자료는 공개하지 않는다. 여기 있는 파일은 책의 최종 모형
  `tm103` 의 추정치로 같은 설계(용량 여섯, 마리 수, 채혈 시각, 정량한계)를 모의한 것이다
  (`R/mkdata/sim_tmdd.R`, seed 2026). `nm/tm10?.ctl` 은 그대로 돌지만 숫자는 책과 비슷하되
  같지 않고, 그래서 `nm/tm10?.R76/` 실행 산출물도 여기 없다. `output/ch18-tmdd-*` 와
  `figures/ch18-tmdd-*` 는 책에 실린 그대로(원자료의 결과)다. 다만 **`R/build.R` 을
돌리면 NONMEM 이 필요 없는 것들(`ch18-tmdd-data`, `ch18-tmdd-fig`)이 대역의 숫자로
덮인다.** `git checkout -- output figures` 로 책의 것을 되돌린다.

실제 과제의 자료는 위의 한 예외를 빼면 없다. 책의 실패 사례는 재구성한 것이고, 여기 있는 것은
전부 공개 자료이거나 모의 자료다.

## 저작권과 라이선스

책 본문의 저작권은 저자와 출판사에 있고 여기에는 본문이 없다. 이 저장소의 코드, 제어파일,
모의 자료, 얼린 출력과 그림은 **GNU General Public License v3.0 또는 그 이후 판**으로
공개한다(`LICENSE`). 돌려 보고 고쳐 쓰는 것은 자유이며, 고친 것을 배포할 때는 같은
조건으로 소스를 함께 내놓는다. NONMEM 은 ICON 의 상용 소프트웨어이며 여기에는 그 어떤
부분도 포함되어 있지 않다.

Copyright (C) 2026 Kyun-Seop Bae. This program is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your option) any later
version. It is distributed WITHOUT ANY WARRANTY; see `LICENSE` for details.

## 다른 권의 companion

| | |
|---|---|
| 1권 과학 계산 with R | <https://github.com/AMC-CPT/SciCompR> |
| 2권 임상시험에서의 과학적 추론 with R | <https://github.com/AMC-CPT/CTDA> |
| 3권 약동학 with R | <https://github.com/AMC-CPT/PKwR> |
| 5권 신약임상개발 자료실 | <https://github.com/AMC-CPT/CDD> |
