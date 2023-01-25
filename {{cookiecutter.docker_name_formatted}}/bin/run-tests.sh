#!/bin/bash

set -eu

export LOG_LEVEL="DEBUG"
export PYTHONPATH='src'
{% if cookiecutter.unit_test_style is defined -%}
  {%- if cookiecutter.unit_test_style == 'pytest' -%}
pytest tests/unit --cov=src -vv
  {%- elif cookiecutter.unit_test_style == 'coverage' -%}
coverage run --module unittest tests/unit/*test.py
coverage report --show-missing --skip-empty
  {%- else -%}
echo "No tests run, please specify 'pytest' or 'coverage' in cookiecutter.unit_test_style"
  {%- endif -%}
{%- else -%}
echo "cookiecutter.unit_test_style is undefined, no tests run"
{%- endif %}
flake8 src
