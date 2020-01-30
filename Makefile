SHELL:=bash
NAME := jupyterhub
HASH := $(shell git rev-parse --short=8 HEAD)
ECR_URL := 00000000.dkr.ecr.eu-west-2.amazonaws.com/${NAME}
ROLE := administrator
REGION := eu-west-2
JUPYTERHUB_PORT := 8000

default: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Bootstrap local environment for first use
	make git-hooks

.PHONY: git-hooks
git-hooks: ## Set up hooks in .git/hooks
	@{ \
		HOOK_DIR=.git/hooks; \
		for hook in $(shell ls .githooks); do \
			if [ ! -h $${HOOK_DIR}/$${hook} -a -x $${HOOK_DIR}/$${hook} ]; then \
				mv $${HOOK_DIR}/$${hook} $${HOOK_DIR}/$${hook}.local; \
				echo "moved existing $${hook} to $${hook}.local"; \
			fi; \
			ln -s -f ../../.githooks/$${hook} $${HOOK_DIR}/$${hook}; \
		done \
	}

.PHONY: build
build:
	docker build -t ${NAME}:${HASH} .

.PHONY: tag
tag: build
	docker tag ${NAME}:${HASH} ${ECR_URL}/${NAME}:${HASH}

.PHONY: push
push: tag
	docker push ${ECR_URL}/${NAME}:${HASH}

.PHONY: run
run:
	docker run --rm -it --name ${NAME} -p ${JUPYTERHUB_PORT}:${JUPYTERHUB_PORT} ${NAME}:${HASH}

.PHONY: ecr-login-awsv
ecr-login-awsv:
	aws-vault exec ${ROLE} -- aws ecr get-login --no-include-email --region ${REGION} | bash
