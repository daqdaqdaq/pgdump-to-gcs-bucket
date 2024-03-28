# pgdump-to-gcs-bucket

A simple Docker container to periodically backup a PostgreSQL database and upload the backup to a Google Cloud Storage bucket.

Features:

* Set the schedule via env variable
* Handles sensitive data through Docker secrets


# Usage

Deploy it into your Docker environment.

# Configuration

## Secrets

* `POSTGRESQL_PASSWORD`: Password of the PostgreSQL user to make the backup.
* `GOOGLE_APPLICATION_CREDENTIALS`: Google Service Account cretentials in json format

## Supported ENV variables
 
|Name                   |Description                                                                                              |Default value       |
|-----------------------|---------------------------------------------------------------------------------------------------------|--------------------|
|`BUCKET`               |Name of the GCS bucket without gs://. You need at least Storage Object User role for your service account|Required            |
|`PGDATABASE`           |Name of the database to backup                                                                           |Required            | 
|`PGUSER`               |Name of the user to use for backup                                                                       |`postgres`          |
|`LOCAL_DIR`            |The path of the local directory to hold the backup files                                                 |`/app/dmp`          |  
|`CRON_SCHEDULE`        |Cron schedule string to schedule the backup                                                              |`0 0 * * *`         |
|`PGHOST`               |Host name of the Postgres instance you want to backup.                                                   |`localhost`         |
|`PGPORT`               |Port of the Postgres instance you want to backup.                                                        |`5432`                |
|`PREFIX`               |Filename prefix for the .dmp file. The files are stored under this directory name in the bucket as well  |`${PGDATABASE}`     |


# Todo

The size of the container is abhorrent thanks to the gcloud SDK, Try to bring it down to a more sensible size.
