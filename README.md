# telemetry-docker-resources

[![Brought to you by Telemetry Team](https://img.shields.io/badge/MDTP-Telemetry-40D9C0?style=flat&labelColor=000000&logo=gov.uk)](https://confluence.tools.tax.service.gov.uk/display/TEL/Telemetry)

## Table of Contents
* [Overview](#Overview)
* [Initialising a repository](#Initialising-a-repository)
* [Linking an existing repository](#Linking-an-existing-repository)
* [Updating the repository](#Updating-the-repository)
* [Setting Docker Build Parameters](#Setting-Docker-Build-Parameters)
* [References](#References)
* [License](#License)

## Overview
This repository contains [cookiecutter](https://github.com/cookiecutter/cookiecutter) template resources for Telemetry AWS
Docker repositories. Only long-term, common and stable files should be added, e.g. scripts or configurations that, when
the need to be changed, they can be changed in unison. It is worth noting that files in this template repository can be
overridden in the repository using the templates. Simply add the file to a skip list defined in the `pyproject.toml` in
the Docker repo.

```toml
[tool.cruft]
skip = [".bandit"]
```

## Initialising a repository

If you have a new "empty" repository created by the [Jenkins build job](https://build.tax.service.gov.uk/job/PlatOps/job/Tools/job/create-a-repository/)
then it is possible to seed that repo with the contents of a cruft template repository. Follow the instructions in this Confluence article [Using Cruft to initialise a new repository](https://confluence.tools.tax.service.gov.uk/display/TEL/Using+Cruft+to+initialise+a+new+repository) for guidance.

```shell
# Script used in article
git clone git@hmrc:hmrc/aws-docker-telemetry-test
cd aws-docker-telemetry-test
git checkout -b TEL-1866-add-cruft
cd ..
cruft create --overwrite-if-exists https://github.com/hmrc/telemetry-docker-resources
cd aws-docker-telemetry-test
git add .
git status
git commit -a -m "TEL-1866: add cruft" -m "Co-authored-by: Lee Myring <29373851+thinkstack@users.noreply.github.com>"
poetry init
# Team Telemetry <telemetry@digital.hmrc.gov.uk>
git add .
git commit -a -m "TEL-1866: add poetry" -m "Co-authored-by: Lee Myring <29373851+thinkstack@users.noreply.github.com>"
```

In order to publish new releases using the CI tooling provided by this template you will first need to create an initial tag.
```shell
git tag -a release/0.0.0 -m "release/0.0.0" && git push --tags
```

## Linking an existing repository

The repository is meant to be used as a cookiecutter source inside any Docker-based repos. To add the templates
to the consuming repository, follow the procedure below.

```shell
# Update project
git checkout --branch TEL-1866-add-cruft
poetry update
poetry add --group dev cruft cookiecutter
```

For the next step, navigate to the folder above. **Note:** this is important as the cruft create will use the
`cruft_repo_name` property to insert the templated files, overwriting where necessary, into the actual project folder

```shell
# This is an example to demonstrate the commands, your folders will be different
pwd # ~/source/hmrc/aws-docker-telemetry-test
cd ..
pwd # ~/source/hmrc
cruft create --overwrite-if-exists https://github.com/hmrc/telemetry-docker-resources
# At the `docker_name` prompt make sure you enter `aws-docker-telemetry-test` to target the correct project
cd -
pwd # ~/source/hmrc/aws-docker-telemetry-test
git add .
```

```shell
# Link the templates repository
cruft link https://github.com/hmrc/telemetry-docker-resources # Carefully enter the properties into the prompts

# Run update (this doesn't patch up local files with the contents of the templates repository)
cruft update

# Run a diff and apply those changes (this does patch up local files)
cruft diff | git apply
```

## Updating the repository

Follow the instructions in this Confluence article [Using Cruft to update an existing repository](https://confluence.tools.tax.service.gov.uk/display/TEL/Using+Cruft+to+update+an+existing+repository) for guidance.

```shell
cruft check
cruft diff
cruft update --skip-apply-ask

# If the update does not work - an update can be forced
cruft diff | git apply
```

## Setting Docker Build Parameters
You can manage the Docker build commands using two variables `docker_build_info_default` and `docker_build_info_additional`.
The examples below demonstrate the different outcomes based on the contents of the dictionary values specified.

**Note:** The Json blocks below are only snippets of the full Json required for simplicity

### Default build with no build arguments or tag suffixes

#### Input (.cruft.json)
```json
{
  "template": "https://github.com/hmrc/telemetry-docker-resources",
  "context": {
    "cookiecutter": {
      "docker_build_info_additional": {},
      "docker_build_info_default": {}
    }
  }
}
```

#### Output (bin/docker-tools.sh)
```shell
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}" .
```

### Default build only with build arguments

#### Input (.cruft.json)
```json
{
  "template": "https://github.com/hmrc/telemetry-docker-resources",
  "context": {
    "cookiecutter": {
      "docker_build_info_additional": {},
      "docker_build_info_default": {
        "default": {
          "build_args": [
            "MODE_HEARTBEAT=1"
          ],
          "platform": [
            "'linux/amd64'"
          ]
        }
      }
    }
  }
}
```

#### Output (bin/docker-tools.sh)
```shell
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}" --build-arg MODE_HEARTBEAT=1 --platform 'linux/amd64' .
```

### No default build but additional build arguments supplied

**Note:** Even though no default build is supplied, you will always get a vanilla build. This is by design

#### Input (.cruft.json)
```json
{
  "template": "https://github.com/hmrc/telemetry-docker-resources",
  "context": {
    "cookiecutter": {
      "docker_build_info_additional": {
        "-heartbeat": {
          "build_args": [
            "MODE_HEARTBEAT=1"
          ]
        },
        "-webops-heartbeat": {
          "build_args": [
            "MODE_HEARTBEAT=1",
            "IS_WEBOPS_ENV=1"
          ]
        }
      },
      "docker_build_info_default": {}
    }
  }
}
```

#### Output (bin/docker-tools.sh)
```shell
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}-" .
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}-heartbeat" --build-arg MODE_HEARTBEAT=1 .
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}-webops-heartbeat" --build-arg MODE_HEARTBEAT=1 --build-arg IS_WEBOPS_ENV=1 .
```

### Both default and additional build arguments supplied

#### Input (.cruft.json)
```json
{
  "template": "https://github.com/hmrc/telemetry-docker-resources",
  "context": {
    "cookiecutter": {
      "docker_build_info_additional": {
        "-heartbeat": {
          "build_args": [
            "MODE_HEARTBEAT=1"
          ],
          "platform": [
            "'linux/amd64'"
          ]
        },
        "-webops-heartbeat": {
          "build_args": [
            "MODE_HEARTBEAT=1",
            "IS_WEBOPS_ENV=1"
          ]
        }
      },
      "docker_build_info_default": {
        "default": {
          "platform": [
            "'linux/amd64'"
          ]
        }
      }
    }
  }
}
```

#### Output (bin/docker-tools.sh)
```shell
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}" --platform 'linux/amd64' .
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}-heartbeat" --build-arg MODE_HEARTBEAT=1 --platform 'linux/amd64' .
  docker build --tag "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${VERSION}-webops-heartbeat" --build-arg MODE_HEARTBEAT=1 --build-arg IS_WEBOPS_ENV=1 .
```


## References

* [Cruft](https://cruft.github.io/cruft)
* [Cookiecutter](https://cookiecutter.readthedocs.io/en/stable/)

## License

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
