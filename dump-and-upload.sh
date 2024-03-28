#!/bin/bash
PGHOST=${PGHOST:-localhost}
PGUSER=${PGUSER:-postgres}
PGPORT=${PGPORT:-5432}
PREFIX=${PREFIX:-$PGDATABASE}
MAXFILES=${KEEPFILES:-5}
LOCAL_DIR=${LOCAL_DIR:-"/app/dmp"}
GCS_BUCKET="gs://$BUCKET"


export PGPASSWORD=$(cat /run/secrets/POSTGRESQL_PASSWORD)
export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/GOOGLE_APPLICATION_CREDENTIALS

mkdir -p $LOCAL_DIR
current_time=$(date +"%Y%m%d%H%M")
filename="${LOCAL_DIR}/${PREFIX}_${current_time}.dmp"
pg_dump -Fc -h$PGHOST -p$PGPORT -U$PGUSER $PGDATABASE > $filename

for file in "$LOCAL_DIR"/*; do
    filename=$(basename "$file")
	file_path="$GCS_BUCKET/$PREFIX/$filename"
    if ! gsutil -q stat $file_path; then
        gsutil cp "$file" "$GCS_BUCKET/$PREFIX/"
    fi
done

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