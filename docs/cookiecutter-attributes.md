# Cookiecutter

This document provides information about this boilerplate's required and optional attributes

## Required attributes

| Attribute                           | Type     | Example                                                             |
|-------------------------------------|----------|---------------------------------------------------------------------|
| **additional_tool_versions**        | json     | {} or {"golang": "1.21.0"}                                          |
| **docker_build_options_additional** | json     | {} or {"_some_tag": "--build-arg foo=bar ."}                        |
| **docker_image_name**               | string   | "project-name"                                                      |
| **docker_image_name_formatted**     | string   | this will be auto-populated based on the provided docker_image_name |

## Optional attributes

| Attribute                           | Type     | default        | Example                     |
|-------------------------------------|----------|----------------|-----------------------------|
| **aws_account_id**                  | string   | "634456480543" | "112233445566"              |
| **aws_region**                      | string   | "eu-west-2"    | "eu-west-1"                 |
| **custom_makefile_name**            | string   | ""             | "ExtraMakefile"             |
| **docker_build_options_default**    | string   | ""             | "--platform 'linux/amd64'"  |
| **docker_include_default_build**    | boolean  | n (for false)  | y (for ture)                |

## Please note:
It is impossible to use empty dictionary as default value for Cookiecutter's attribute. i.e. `additional_tool_versions`
Doing so would not allow the child repository's .cruft.json file to overwrite its value.
Therefore, we had to keep them as required attributes by setting the default value to null.
This means child repositories must at least pass an empty dictionary during initiation. i.e. `{}`
