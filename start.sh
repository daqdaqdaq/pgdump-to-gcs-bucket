#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/GOOGLE_APPLICATION_CREDENTIALS
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
# use python to build the cron file
python3 /app/build-cron.py
crontab /tmp/run-dmp

