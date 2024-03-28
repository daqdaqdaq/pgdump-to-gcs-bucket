#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/GOOGLE_APPLICATION_CREDENTIALS
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

CRON_SCHEDULE=${CRON_SCHEDULE:-"0 0 * * *"}
echo "${CRON_SCHEDULE} /app/dump-and-upload.sh >> /var/log/cron.log 2>&1" > /tmp/run-dmp
crontab /tmp/run-dmp
crond
tail -f /var/log/cron.log
