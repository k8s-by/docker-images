# README

## GENERAL DOCUMENTATION

All options defined in `/etc/pgbouncer/pgbouncer.ini` can be overridden using environment variables by using the syntax `<SectionName>_<KeyName>`. For example:

```
docker run -d \
    -p 5439:5439 \
    --name=pgbouncer \
    -e "DATABASES_HOST=redshift.server.name" \
    -e "DATABASES_PORT=5439" \
    -e "DATABASES_USER=awsuser" \
    -e "DATABASES_PASSWORD=secret" \
    -e "DATABASES_DBNAME=mydatabase" \
    -e "PGBOUNCER_LISTEN_PORT=5439" \
    pgbouncer/pgbouncer
```

This will output an ini file of:

```
#pgbouncer.ini

[databases]
* = host = redshift.server.name port=5439 user=awsuser password=secret dbname=mydatabase

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 5439
auth_type = any
ignore_startup_parameters = extra_float_digits

# Log settings
admin_users = postgres

# Connection sanity checks, timeouts

# TLS settings

# Dangerous timeouts
```

### Multiple Database connections

Use the `DATABASES` env var to define your database configuration. Each row can
be separated by a comma.

```
docker run -d \
    -p 5439:5439 \
    --name=pgbouncer \
    -e "DATABASES=primary = host = redshift.server.name port=5439 user=awsuser password=secret dbname=db,replica = host = redshift-replica.server.name port=1234 user=replicauser password=replicapassword dbname=db" \
    -e "PGBOUNCER_LISTEN_PORT=5439" \
    pgbouncer/pgbouncer
```

## BUILD INFO

```
docker build --build-arg PGBOUNCER_VERSION=1.16.1 -t <registry>/pgbouncer:1.16.1 .
```

## HUB REPO

Here is the hub.docker.com repo:

https://hub.docker.com/r/alex202/pgbouncer

