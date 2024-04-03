# pgdump-to-gcs-bucket

A simple Docker container to periodically backup PostgreSQL databases and upload the backup to a Google Cloud Storage bucket.

Features:

* Can back up multiple databases with different schedules
* Handles sensitive data through Docker secrets

# Usage

Deploy it into your Docker environment.

# Configuration

## Secrets

* `GOOGLE_APPLICATION_CREDENTIALS`: Google Service Account cretentials in json format

## General settings as ENV variables
 
* `BUCKET`: Name of the GCS bucket without gs://. You need at least Storage Object User role for your service account

## Task specific settings in toml file

The file should be mounted into the container at `/app/config.toml`. The file should contain a table for each backup task.

```toml
[databaseone]
schedule = '*/30 * * * *'
pghost = "host1"
pgport = 5432
pguser = "user"
pgpassword_secret = "PGPASSWORD" # Name of the secret containing the password
pgdatabase = "database"
prefix = "databaseone"
maxfiles = 4
```

If there is no prefix defined the name of the table will be used as prefix for the backup file and as directory name to store the files in the bucket as well.

|Name                   | Description                                          | Default value       |
|-----------------------|------------------------------------------------------|---------------------|
|`schedule`             | Cron schedule for the backup job                     | `0 0 * * *`         |
|`pghost`               | Hostname of the PostgreSQL server                    | Required            |
|`pgport`               | Port of the PostgreSQL server                        | `5432`              |
|`pguser`               | Username to connect to the PostgreSQL server         | `postgres`          |
|`pgpassword_secret`    | Name of the secret containing the password           | Required            |
|`pgdatabase`           | Name of the database to backup                       | Required            |
|`prefix`               | Prefix for the backup file name                      | `Name of the table` |
|`maxfiles`             | Number of backup files to keep. 0: keep all files    | `5`                 |

# Todo

The size of the container is abhorrent thanks to the gcloud SDK, try to bring it down to a more sensible size.
