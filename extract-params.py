"""Extracts the parameters from a toml file's table given as command line argument and outputs them as a list"""
import sys
import toml

DEFAULT_PORT = 5432
DEFAULT_USER = 'postgres'
DEFAULT_MAXFILES = 5

section = sys.argv[1]
config = toml.load("/app/config.toml")
params = config[section]

pghost = params['pghost']
pgport = params.get('pgport', DEFAULT_PORT)
pguser = params.get('pguser', DEFAULT_USER)
pgdatabase = params['pgdatabase']
prefix = params.get('prefix', section)
maxfiles = params.get('maxfiles', DEFAULT_MAXFILES)

print(f"{pghost} {pgport} {pguser} {params['pgpassword_secret']} {pgdatabase} {prefix} {maxfiles}")


