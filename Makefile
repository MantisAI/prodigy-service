
.PHONY: .envrc
.envrc: .env
	direnv dotenv > .envrc
	-direnv allow

# In case you need to go from .envrc to .env

#.env: 
#	sed -e "/export/!d" -e "s/export //g" $< > $@ 

prodigy_wheel := ${PRODIGY_WHEEL}

prodigy/$(prodigy_wheel):
	aws s3 cp ${S3_PATH} $@

.PHONY: build
build: prodigy/$(prodigy_wheel)
	docker-compose build

.PHONY: up
up:
	docker-compose up -d up db

#
# Log in to access ECR repositories
#
# Note that old versions of awscli may experience issues with command.
#

.PHONY: login
login: .envrc
	aws ecr get-login-password --region=${AWS_REGION} | sudo docker login \
		--username AWS --password-stdin ${REPO}

.PHONY: push
push: login
	sudo docker-compose push
