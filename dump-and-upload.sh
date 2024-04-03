#!/bin/bash

SECTION=$1
#f"{params['pghost']} {params['pgport']} {params['pguser']} {params['pgpassword_secret']} {params['pgdatabase']} {params['prefix']}

read PGHOST PGPORT PGUSER SECRET_NAME PGDATABASE PREFIX MAXFILES <<< "$(python3 /app/extract-params.py "$SECTION")"
LOCAL_DIR=${LOCAL_DIR:-"/app/dmp"}
GCS_BUCKET="gs://$BUCKET"


export PGPASSWORD=$(cat /run/secrets/"$SECRET_NAME")
export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/GOOGLE_APPLICATION_CREDENTIALS

mkdir -p $LOCAL_DIR
current_time=$(date +"%Y%m%d%H%M")
filename="${PREFIX}_${current_time}.dmp"
filepath="${LOCAL_DIR}/${PREFIX}_${current_time}.dmp"
pg_dump -Fc -h$PGHOST -p$PGPORT -U$PGUSER $PGDATABASE > $filepath

bucket_path="$GCS_BUCKET/$PREFIX/$filename"
if ! gsutil -q stat "$bucket_path"; then
    gsutil cp "$filepath" "$GCS_BUCKET/$PREFIX/"
fi

# Remove the local dump file
rm -f $filepath

if [ ${MAXFILES} -eq 0 ]; then
  exit 0
fi

# List files in the directory sorted by date in ascending order
FILES=$(gsutil ls -l gs://${BUCKET}/${PREFIX} | sort -k2,2)
# Count the number of files
FILE_COUNT=$(echo "${FILES}" | wc -l)

# If there are more than 5 files, delete the oldest ones
if [ ${FILE_COUNT} -gt ${MAXFILES} ]; then
  DELETE_COUNT=$((FILE_COUNT-MAXFILES))
  echo "${FILES}" | head -n ${DELETE_COUNT} | awk '{print $3}' | xargs gsutil rm
fi
