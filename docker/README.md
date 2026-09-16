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
# 호스트(Windows)에서 돌린 것
Rscript R/runnm.R 108wt
# 컨테이너에서 돌린 것 (같은 제어파일, 같은 자료)
docker run --rm -v ...:/opt/nm760/license/nonmem.lic:ro -v $PWD:/work -w /work/nm \
  nm760 nmfe76 108wt.ctl 108wt.lst -rundir=108wt.docker
```

병렬 실행과 tmpfs (15.7-15.8절)

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

```sh
docker exec <container> tar cf - -C /work . | tar xf - -C ./run2_with_tmpfs/
```

Google Cloud (15.9절). `<PROJECT_ID>`, `<BUCKET>`, `<REGION>` 을 자기 것으로 바꾼다.

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
# 1. 입력을 올린다
gcloud storage cp ./run003/CONTROL5 ./run003/THEOPP gs://<BUCKET>/run003/

# 2. 작업을 만든다. 버킷을 /gcs 에 붙여 파일처럼 쓴다
gcloud run jobs create nonmem-run003 \
  --image=<REGION>-docker.pkg.dev/<PROJECT_ID>/nonmem-repo/nm760:latest \
  --region=<REGION> \
  --cpu=4 --memory=4Gi \
  --max-retries=0 \
  --task-timeout=3600s \
  --add-volume=name=gcs-vol,type=cloud-storage,bucket=<BUCKET> \
  --add-volume-mount=volume=gcs-vol,mount-path=/gcs \
  --command=bash \
  --args="-c,cp /gcs/run003/* /data/ && cd /data && \
    nmfe76 CONTROL5 CONTROL5.res \
      -parafile=/opt/nm760/run/mpilinux_onecomputer.pnm '[nodes]=4' && \
    mkdir -p /gcs/run003/results && \
    cp /data/*.res /data/*.ext /data/*.xml /data/*.phi /gcs/run003/results/"

# 3. 실행한다
gcloud run jobs execute nonmem-run003 --region=<REGION>

# 4. 상태를 보고, 끝나면 내려받는다
gcloud run jobs executions list --job=nonmem-run003 --region=<REGION>
gcloud storage cp -r gs://<BUCKET>/run003/results/ ./run003/
```

```sh
gcloud run jobs executions describe nonmem-run003-8krcv --region=<REGION>
gcloud run jobs executions cancel   nonmem-run003-8krcv --region=<REGION>
gcloud run jobs delete nonmem-run003 --region=<REGION> --quiet
```

```sh
# 재표집 200벌을 미리 만들어 올려 둔다: gs://<BUCKET>/boot/001.csv ... 200.csv
gcloud run jobs create nonmem-boot \
  --image=... --region=<REGION> --cpu=2 --memory=2Gi \
  --tasks=200 --parallelism=50 --max-retries=1 --task-timeout=7200s \
  --add-volume=name=gcs-vol,type=cloud-storage,bucket=<BUCKET> \
  --add-volume-mount=volume=gcs-vol,mount-path=/gcs \
  --command=bash \
  --args="-c,I=\$(printf %03d \$((CLOUD_RUN_TASK_INDEX+1))) && \
    mkdir -p /data/\$I && cp /gcs/boot/boot.ctl /gcs/boot/\$I.csv /data/\$I/ && \
    cd /data/\$I && sed -i s/_boot.csv/\$I.csv/ boot.ctl && \
    nmfe76 boot.ctl boot.lst && cp boot.ext boot.lst /gcs/boot/out/\$I/"
```
