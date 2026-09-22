# 1. upload the input
gcloud storage cp ./run003/CONTROL5 ./run003/THEOPP gs://<BUCKET>/run003/

# 2. create the job. Mount the bucket at /gcs and use it like files
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

# 3. execute
gcloud run jobs execute nonmem-run003 --region=<REGION>

# 4. check the status and download when it finishes
gcloud run jobs executions list --job=nonmem-run003 --region=<REGION>
gcloud storage cp -r gs://<BUCKET>/run003/results/ ./run003/
