import toml

DEFAULT_SCHEDULE = "0 0 * * *"

try:
    config = toml.load("/app/config.toml")
except FileNotFoundError:
    raise SystemExit("Config file not found. Mount a config.toml file to /app/config.toml")


with open("/tmp/run-dmp", "w") as f:
    for section in config:
        schedule = config[section].get("schedule", DEFAULT_SCHEDULE)
        f.write(f"{schedule} /app/dump-and-upload.sh {section}\n")

