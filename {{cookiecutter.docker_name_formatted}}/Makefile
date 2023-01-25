SHELL := /usr/bin/env bash

DOCKER_NAME := {{ cookiecutter.docker_name_formatted }}
TELEMETRY_INTERNAL_BASE_ACCOUNT_ID := 634456480543

help: ## The help text you're reading
	@grep --no-filename -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

{% if cookiecutter.custom_makefile_name is defined and cookiecutter.custom_makefile_name|length -%}
include {{ cookiecutter.custom_makefile_name }}
{%- endif %}
