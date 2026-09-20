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
