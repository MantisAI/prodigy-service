
.envrc: .env
	direnv dotenv > .envrc
	-direnv allow

# In case you need to go from .envrc to .env

#.env: 
#	sed -e "/export/!d" -e "s/export //g" $< > $@ 

prodigy_wheel := ${PRODIGY_WHEEL}
prodigy_home := ${PRODIGY_HOME}

prodigy/$(prodigy_wheel): .envrc
	aws s3 cp ${S3_PATH} $@

.PHONY: $(prodigy_home)/prodigy.json
$(prodigy_home)/prodigy.json: .envrc
	mkdir -p $(@D)
	cat prodigy.json.template | envsubst > $@

.PHONY: build
build: prodigy/$(prodigy_wheel) .envrc
	docker-compose build

.PHONY: pull
pull: .envrc login
	sudo docker-compose pull

.PHONY: up
up: .envrc ${prodigy_home}/prodigy.json
	sudo docker-compose up -d db

.PHONY: down
down:
	docker-compose down

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
