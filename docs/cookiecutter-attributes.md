# Cookiecutter

This document provides information about this boilerplate's required and optional attributes  

## Required attributes

| Attribute                       | Type    | Example                                                             |
|---------------------------------|---------|---------------------------------------------------------------------|
| **docker_image_name**           | string  | "project-name"                                                      | 
| **docker_image_name_formatted** | string  | this will be auto-populated based on the provided docker_image_name |

## Optional attributes

| Attribute                           | Type     | Example                                         |
|-------------------------------------|----------|-------------------------------------------------|
| **additional_tool_versions**        | json     | {"golang": "1.21."}                             |
| **aws_account_id**                  | string   | "634456480543"                                  |
| **aws_region**                      | string   | "eu-west-2"                                     | 
| **custom_makefile_name**            | string   | "eu-west-2"                                     |
| **docker_build_options_additional** | json     | {"--build-arg foo=bar", "--build-arg foo=bar"}  |
| **docker_build_options_default**    | string   | "--build-arg foo=bar"                           |
| **docker_include_default_build**    | boolean  | y                                               |
