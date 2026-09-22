# The commands of Chapter 15

The structure of the distribution folder (15.2)

```
nm760CD/
  Dockerfile           the instructions for building the image
  .dockerignore        what not to put in the image (*.tar.gz, .git, *.md)
  SETUP76              the distribution's install script
  install_Linux*       distribution
  nonmem76e.zip        distribution (encrypted source)
  nonmem76r.zip
  mpilinux8.pnm        a parallel-configuration template
  util/  ...
```

Building the image

```sh
cd nm760CD
docker build -t nm760 .
docker images nm760
```

Running it (the licence is attached with -v)

```sh
docker run --rm \
  -v /path/to/nonmem.lic:/opt/nm760/license/nonmem.lic:ro \
  -v $PWD:/data nm760 nmfe76 100base.ctl 100base.lst
```

```sh
docker run --rm -it \
  -v /path/to/nonmem.lic:/opt/nm760/license/nonmem.lic:ro \
  -v $PWD/example:/data nm760
# inside the container
nmfe76 CONTROL5 CONTROL5.res
nmfe76 CONTROL5 CONTROL5.par -parafile=/opt/nm760/run/mpilinux8.pnm '[nodes]=4'
```

Comparing the host's result with the container's (15.6)

```sh
docker build --platform linux/amd64 -t nm760 .
docker run  --platform linux/amd64 --rm -it ...
```

Parallel running, and tmpfs (15.7-15.8)

```sh
# run on the host (Windows)
Rscript R/runnm.R 108wt
# run in the container (same control file, same data)
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

Google Cloud (15.9). Put your own values in `<PROJECT_ID>`, `<BUCKET>` and `<REGION>`.

```sh
docker exec <container> tar cf - -C /work . | tar xf - -C ./run2_with_tmpfs/
```

```sh
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud config set compute/region <REGION>          # e.g. asia-northeast3 (Seoul)

gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable storage.googleapis.com

# image registry
gcloud artifacts repositories create nonmem-repo \
  --repository-format=docker --location=<REGION>
gcloud auth configure-docker <REGION>-docker.pkg.dev

# file store (bucket)
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
