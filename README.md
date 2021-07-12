# Prodigy Service

A docker-compose file for launching a prodi.gy and connected postgres containers.

## Getting started

### Prerequisites

* Docker
* docker-compose
* direnv (optional, but helpful)
* envsubst
* A valid prodigy subscription and access to the prodigy linux wheel

### Environment variables

A `.env` needs to be set to provide environment variables to docker compose. This should be based on `.env.template`

If you use direnv, you can create a `.envrc` from the `.env` file with `make .envrc`. Note that docker-compose will only read the `.env`, so this should be the canonical store of env vars, with `.envrc` just created for the convenience of using direnv.


An .env file should look like:

```
# REMOTE tool (optional)
# See https://github.com/wellcometrust/remote

INSTANCE_NAME=XXXXXXXXXXXXXXXXXXXXXXXXX
FILTER_PREFIX=*

# AWS

NAME=XXXXXXXXXXXXXXXXX
AWS_PROFILE=default
AWS_REGION=eu-west-1
AWS_ACCOUNT_ID=XXXXXXXXXXXX
S3_BUCKET=s3://XXXXXXXXXXXXXXXXXX
S3_PATH=${S3_BUCKET}/prodigy/${PRODIGY_WHEEL}
REPO=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Docker / docker-compose envs

BASE_TAG=3.8.11-slim-buster

# Note that to use spaCy 3 you must use prodigy nightly version

SPACY_VERSION=3.0.0
SPACY_MODEL_URL=https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-${SPACY_VERSION}/en_core_web_sm-${SPACY_VERSION}.tar.gz

# Prodigy

VERSION=1.11.0a8
PRODIGY_WHEEL=prodigy-${VERSION}-cp36.cp37.cp38.cp39-cp36m.cp37m.cp38.cp39-linux_x86_64.whl
PRODIGY_HOME=/opt/prodigy
LOCAL_PORT=1337

# Postgres env vars

POSTGRES_DATA=/data/pg
POSTGRES_PASSWORD=password
POSTGRES_USER=prodigy
PGURL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432
```

### Prodigy config

Set the username and password values in `.env` file. These will get automatically propagated into the `prodigy.json` file to the folder matching the env var `PRODIGY_HOME`. 

### Running the containers

To launch the containers you can run:

```
make up

# which is equivalent to 

docker-compose up -d db
```

To run a prodigy commands just prefix the usual prodigy command with `docker-compose run --rm`, e.g.:

```
docker-compose run --rm --service-ports prodigy stats -ls
```

If you wish to set an alias on your system to avoid having to call `docker-compose` you can add the following to your `.bashrc` or equivalent.

```
prodigy () {
    docker-compose run --rm --service-ports prodigy $@
}
```

### Building the containers

To update the prodigy container, for example with a new version of prodigy, add the appropriate prodigy wheel to `./prodigy` and update the `PRODIGY_WHEEL` env var in `.env`. You should also increment the `VERSION` env var. It probably makes sense for this to follow the version of prodigy.

NOTE: you must have a prodigy license in order to get access to a prodigy wheel. See https://prodi.gy.

Build the containers with:

```
make build

# equiavent to

docker-compose build
```

### Pushing the containers

To push the container to a docker repo (for example docker hub or AWS ECR) you must first run `docker login`. If you are using ECR, you can do this automatically with the following command (you will need to set `AWS_PROFILE` or `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID`):

```
make push
```

This will run the following commands:

```
# Update the .envrc file from .env

direnv dotenv > .envrc

# Authorise the .envrc in this folder

direnv allow

# Log in to ECR repository. Env vars will be read from local env via .envrc file

aws ecr get-login-password --region=${AWS_REGION} | sudo docker login \
		--username AWS --password-stdin ${REPO}

# Push the docker image to the repo

sudo docker-compose push
