#!/usr/bin/env bash

# A helper tool to assist us maintaining docker functions
# Intention here is to keep this files and all its functions reusable for all Telemetry repositories

set -o errexit
set -o nounset

#####################################################################
## Beginning of the configurations ##################################

BASE_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATH_BUILD="${BASE_LOCATION}/build"
PROJECT_FULL_NAME="{{ cookiecutter.docker_name_formatted }}"

## End of the configurations ########################################
#####################################################################

debug_env(){
  echo BASE_LOCATION="${BASE_LOCATION}"
  echo PROJECT_FULL_NAME="${PROJECT_FULL_NAME}"
  echo PATH_BUILD="${PATH_BUILD}"
}

open_shell() {
    print_begins

    poetry export --without-hashes --format requirements.txt --with dev --output "requirements-tests.txt"
    docker run -it \
               --rm \
               --volume "${BASE_LOCATION}":/data \
               --workdir /data \
               --env REQUIREMENTS_FILE="requirements-tests.txt" \
               --env VENV_NAME="venv" \
               python:$(cat "${BASE_LOCATION}/.python-version")-slim-buster /data/bin/entrypoint.sh /bin/bash

    print_completed
}

# Creates a release tag in the repository
cut_release() {
  print_begins

  poetry run cut-release

  print_completed
}

# Bump the function's version when appropriate
prepare_release() {
  print_begins

  poetry run prepare-release
  export_version

  print_completed
}

#####################################################################
## Beginning of the helper methods ##################################

export_version() {

  if [ ! -f ".version" ]; then
    echo ".version file not found! Have you run prepare_release command?"
    exit 1
  fi

  VERSION=$(cat .version)
  export VERSION=${VERSION}
}

help() {
  echo "$0 Provides set of commands to assist you with day-to-day tasks when working in this project"
  echo
  echo "Available commands:"
  echo -e " - prepare_release\t\t Bump the function's version when appropriate"
  echo -e " - cut_release\t\t Creates a release tag in the repository"
  echo
}

print_begins() {
  echo -e "\n-------------------------------------------------"
  echo -e ">>> ${FUNCNAME[1]} Begins\n"
}

print_completed() {
  echo -e "\n### ${FUNCNAME[1]} Completed!"
  echo -e "-------------------------------------------------"
}

print_configs() {
  echo -e "BASE_LOCATION:\t\t\t${BASE_LOCATION}"
  echo -e "PATH_BUILD:\t\t\t${PATH_BUILD}"
  echo -e "PROJECT_FULL_NAME:\t\t${PROJECT_FULL_NAME}"
}

## End of the helper methods ########################################
#####################################################################

#####################################################################
## Beginning of the Entry point #####################################
main() {
  # Validate command arguments
  [ "$#" -ne 1 ] && help && exit 1
  function="$1"
  functions="help debug_env open_shell prepare_release print_configs cut_release"
  [[ $functions =~ (^|[[:space:]])"$function"($|[[:space:]]) ]] || (echo -e "\n\"$function\" is not a valid command. Try \"$0 help\" for more details" && exit 2)

  # Ensure build folder is available
  mkdir -p "${PATH_BUILD}"

  $function
}

main "$@"
## End of the Entry point ###########################################
#####################################################################
