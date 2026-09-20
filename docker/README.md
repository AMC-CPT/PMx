# 15장의 명령 모음

배포본 폴더의 구조 (15.2절)

```
nm760CD/
  Dockerfile           이미지를 만드는 지시서
  .dockerignore        이미지에 넣지 않을 것 (*.tar.gz, .git, *.md)
  SETUP76              배포본의 설치 스크립트
  install_Linux*       배포본
  nonmem76e.zip        배포본 (암호화된 소스)
  nonmem76r.zip
  mpilinux8.pnm        병렬 설정 본보기
  util/  ...
```

이미지 만들기

```sh
cd nm760CD
docker build -t nm760 .
docker images nm760
```

실행 (라이선스는 -v 로 붙인다)

```sh
docker run --rm \
  -v /path/to/nonmem.lic:/opt/nm760/license/nonmem.lic:ro \
  -v $PWD:/data nm760 nmfe76 100base.ctl 100base.lst
```

```sh
docker run --rm -it \
  -v /path/to/nonmem.lic:/opt/nm760/license/nonmem.lic:ro \
  -v $PWD/example:/data nm760
# 컨테이너 안에서
nmfe76 CONTROL5 CONTROL5.res
nmfe76 CONTROL5 CONTROL5.par -parafile=/opt/nm760/run/mpilinux8.pnm '[nodes]=4'
```

호스트와 컨테이너의 결과 대조 (15.6절)

```sh
docker build --platform linux/amd64 -t nm760 .
docker run  --platform linux/amd64 --rm -it ...
```

병렬 실행과 tmpfs (15.7-15.8절)

```sh
# 호스트(Windows)에서 돌린 것
Rscript R/runnm.R 108wt
# 컨테이너에서 돌린 것 (같은 제어파일, 같은 자료)
docker run --rm -v ...:/opt/nm760/license/nonmem.lic:ro -v $PWD:/work -w /work/nm \
  nm760 nmfe76 108wt.ctl 108wt.lst -rundir=108wt.docker
```

```sh
nmfe76 206.CTL 206.OUT -parafile=/opt/nm760/run/mpilinux8.pnm '[nodes]=4'
```

```sh
docker run --rm --tmpfs /work:rw,size=4g,exec \
  -v /path/to/nonmem.lic:/opt/nm760/license/nonmem.lic:ro \
  -v $PWD/example:/data:ro nm760 \
  /bin/bash -c "cp /data/* /work/ && cd /work && \
                nmfe76 206.CTL 206.OUT -parafile=/opt/nm760/run/mpilinux8.pnm"
```

Google Cloud (15.9절). `<PROJECT_ID>`, `<BUCKET>`, `<REGION>` 을 자기 것으로 바꾼다.

```sh
docker exec <container> tar cf - -C /work . | tar xf - -C ./run2_with_tmpfs/
```

```sh
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud config set compute/region <REGION>          # 예: asia-northeast3 (서울)

gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable storage.googleapis.com

# 이미지 저장소
gcloud artifacts repositories create nonmem-repo \
  --repository-format=docker --location=<REGION>
gcloud auth configure-docker <REGION>-docker.pkg.dev

# 파일 저장소 (버킷)
gcloud storage buckets create gs://<BUCKET> --location=<REGION>
```

```sh
docker tag nm760:latest <REGION>-docker.pkg.dev/<PROJECT_ID>/nonmem-repo/nm760:latest
docker push <REGION>-docker.pkg.dev/<PROJECT_ID>/nonmem-repo/nm760:latest
```

```sh
#!/bin/bash
set -e
mkdir -p /tmp/nm_run && cd /tmp/nm_run
gcloud storage cp "$INPUT_GCS_PATH" ./input.ctl
[ -n "$DATA_GCS_PATH" ] && gcloud storage cp "$DATA_GCS_PATH" ./data.csv
nmfe76 input.ctl output.lst
gcloud storage cp -r ./* "$OUTPUT_GCS_PATH"
```

```sh
gcloud run jobs executions describe nonmem-run003-8krcv --region=<REGION>
gcloud run jobs executions cancel   nonmem-run003-8krcv --region=<REGION>
gcloud run jobs delete nonmem-run003 --region=<REGION> --quiet
```
