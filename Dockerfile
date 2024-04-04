FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    python3 \
	py3-crcmod \
	libc6-compat \
    py3-pip \
    postgresql16-client \
    busybox-suid \
    curl \
    bash \
    py3-toml

ENV PATH /google-cloud-sdk/bin:$PATH

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-470.0.0-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-470.0.0-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-470.0.0-linux-x86_64.tar.gz && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
	gcloud config set metrics/environment github_docker_image && \
    gcloud components remove  bq && \
    rm -rf $(find google-cloud-sdk/ -regex ".*/__pycache__") && \
    rm -rf /google-cloud-sdk/bin/anthoscli && \
    rm -rf google-cloud-sdk/.install/.backup
# Add the Cloud SDK to the PATH


# Initialize the SDK


# Copy the current directory contents into the container at /app
COPY dump-and-upload.sh start.sh build-cron.py extract-params.py /app/
RUN chmod +x /app/*

WORKDIR /app

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD ["bash", "-c", "/app/start.sh; crond -f -l 2 -L /dev/stdout"]