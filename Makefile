# ----------------------------------------------------------------------------------------------------------------------
#  Variables and arguments required
SHELL := '/bin/bash'
.DEFAULT_GOAL := help
GIT_LAST_COMMIT_HASH := $(shell git rev-parse --short HEAD)
CURRENT_DATE_GMT := $(shell date +"%Y-%m-%dT%H:%M:%S_GMT%Z")
VERSION := $(shell git describe --tags --always)
APP_CONFIG_FILE := $(CURDIR)/config.json
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
build: ## Build local environment (without cache), and create the required environment files.
	docker compose build --no-cache
	make create-env-files
# ----------------------------------------------------------------------------------------------------------------------
up: ## Start the local environment.
ifneq ("$(wildcard $(APP_CONFIG_FILE))","")
	docker compose up
else
	@printf "\033[0;31mError: File 'config.json' not found. Please run 'make create-env-files' before proceed.\033[0m\n"
endif
# ----------------------------------------------------------------------------------------------------------------------
down: ## Stop the local environment.
	docker compose down
# ----------------------------------------------------------------------------------------------------------------------
create-env-files: ## Create ./config.json and ./env/.env files (only if they don't exist).
	cp -u ./config.json.example ./config.json
	cp -u ./env/.env.example ./env/.env
# ----------------------------------------------------------------------------------------------------------------------
help: ## Print information of each Make task.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
.PHONY: build up down help
