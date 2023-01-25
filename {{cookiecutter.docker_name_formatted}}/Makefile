SHELL := /usr/bin/env bash
POETRY_OK := $(shell type -P poetry)
POETRY_PATH := $(shell poetry env info --path)
POETRY_REQUIRED := $(shell cat .poetry-version)
POETRY_VIRTUALENVS_IN_PROJECT ?= true
PYTHON_OK := $(shell type -P python)
PYTHON_REQUIRED := $(shell cat .python-version)
PYTHON_VERSION ?= $(shell python -V | cut -d' ' -f2)

DOCKER_NAME := {{ cookiecutter.docker_name_formatted }}
TELEMETRY_INTERNAL_BASE_ACCOUNT_ID := 634456480543

help: ## The help text you're reading
	@grep --no-filename -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

{% if cookiecutter.custom_makefile_name is defined and cookiecutter.custom_makefile_name|length -%}
include {{ cookiecutter.custom_makefile_name }}
{%- endif %}

bandit: ## Run bandit against python code
	@poetry run bandit -r ./src -c .bandit
.PHONY: bandit

black: ## Run black against python code
	@poetry run black ./src ./tests
.PHONY: black

black_check: ## Show changes black would make
	@poetry run black --check --diff ./src ./tests
.PHONY: black_check

check_poetry: check_python ## Check Poetry installation
    ifeq ('$(POETRY_OK)','')
	    $(error package 'poetry' not found!)
    else
	    @echo Found Poetry ${POETRY_REQUIRED}
    endif
.PHONY: check_poetry

check_python: ## Check Python installation
    ifeq ('$(PYTHON_OK)','')
	    $(error python interpreter: 'python' not found!)
    else
	    @echo Found Python
    endif
    ifneq ('$(PYTHON_REQUIRED)','$(PYTHON_VERSION)')
	    $(error incorrect version of python found: '${PYTHON_VERSION}'. Expected '${PYTHON_REQUIRED}'!)
    else
	    @echo Found Python ${PYTHON_REQUIRED}
    endif
.PHONY: check_python

clean: ## Teardown build artefacts
	@sudo rm -rf ./build ./venv ./venv_package
.PHONY: clean

cut_release: ## Cut release
	@./bin/docker-tools.sh cut_release
.PHONY: cut_release

debug_env: ## Print out variables used by docker-tools.sh
	@./bin/docker-tools.sh debug_env
.PHONY: debug_env

prepare_release: ## Runs prepare release
	@./bin/docker-tools.sh prepare_release
.PHONY: prepare_release

setup: check_poetry ## Setup virtualenv & dependencies using poetry and set-up the git hook scripts
	@export POETRY_VIRTUALENVS_IN_PROJECT=$(POETRY_VIRTUALENVS_IN_PROJECT) && poetry run pip install --upgrade pip
	@poetry config experimental.new-installer false
	@poetry config --list
	@poetry install --no-root
	@poetry run pre-commit install
.PHONY: setup

test: setup ## Run unit tests
	@./bin/docker-tools.sh unittest
.PHONY: test

verify: test bandit black ## Run all the checks and tests
.PHONY: verify

verify_publish_release: verify prepare_release cut_release ## Run all the checks and tests, package, publish and release the Docker image
.PHONY: verify_publish_release
