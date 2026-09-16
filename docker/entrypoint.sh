#!/bin/bash
set -e
mkdir -p /tmp/nm_run && cd /tmp/nm_run
gcloud storage cp "$INPUT_GCS_PATH" ./input.ctl
[ -n "$DATA_GCS_PATH" ] && gcloud storage cp "$DATA_GCS_PATH" ./data.csv
nmfe76 input.ctl output.lst
gcloud storage cp -r ./* "$OUTPUT_GCS_PATH"
