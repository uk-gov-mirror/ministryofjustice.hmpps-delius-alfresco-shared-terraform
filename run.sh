#!/bin/sh

set -e

#Usage
# Scripts takes 2 arguments: environment_type and action
# environment_type: target environment example dev prod
# ACTION_TYPE: task to complete example plan apply test clean 
# AWS_TOKEN: token to use when running locally eg hmpps-token

# Error handler function
exit_on_error() {
  exit_code=$1
  last_command=${@:2}
  if [ $exit_code -ne 0 ]; then
      >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
      exit ${exit_code}
  fi
}

cleanUp() {
  #rm -rf .terraform
  rm -rf ${HOME}/data/env_configs/inspec.properties
}

env_config_dir="${HOME}/data/env_configs"

TG_ENVIRONMENT_TYPE=$1
ACTION_TYPE=$2
AWS_TOKEN=$3
COMPONENT=${4}


if [ -z "${TG_ENVIRONMENT_TYPE}" ]
then
    echo "environment_type argument not supplied, please provide an argument!"
    exit 1 
fi

echo "Output -> environment_type set to: ${TG_ENVIRONMENT_TYPE}"

if [ -z "${ACTION_TYPE}" ]
then
    echo "ACTION_TYPE argument not supplied."
    echo "--> Defaulting to plan ACTION_TYPE"
    ACTION_TYPE="plan"
fi

echo "Output -> ACTION_TYPE set to: ${ACTION_TYPE}"


if [ ! -z "${AWS_TOKEN}" ]
then
    AWS_TOKEN="${AWS_TOKEN}"
    TOKEN_ARGS="-e AWS_PROFILE=${AWS_TOKEN}"
    echo "Output -> AWS_TOKEN set to: ${AWS_TOKEN}"
    echo "Output ---> input stage complete"
fi

if [ -z "${COMPONENT}" ]
then
    echo "COMPONENT argument not supplied."
    echo "--> Defaulting to common component"
    COMPONENT="common"
fi

# Commands
tg_planCmd="terragrunt plan -detailed-exitcode --out ${TG_ENVIRONMENT_TYPE}.plan"
tg_applyCmd="terragrunt apply ${TG_ENVIRONMENT_TYPE}.plan"
workDir=$(pwd)
runCmd="docker run -it --rm -v ${workDir}:/home/tools/data \
    -v ${HOME}/.aws:/home/tools/.aws \
    ${TOKEN_ARGS} -e RUNNING_IN_CONTAINER=True hmpps/terraform-builder:latest sh run.sh ${TG_ENVIRONMENT_TYPE} ${ACTION_TYPE} ${COMPONENT}"

#check env vars for RUNNING_IN_CONTAINER switch
if [[ ${RUNNING_IN_CONTAINER} == True ]]
then
    workDirContainer=${3}
    echo "Output -> environment stage"
    source ${env_config_dir}/${TG_ENVIRONMENT_TYPE}.properties
    exit_on_error $? !!
    echo "Output ---> set environment stage complete"
    # set runCmd
    ACTION_TYPE="docker-${ACTION_TYPE}"
    cd ${workDirContainer}
    echo "Output -> Container workDir: $(pwd)"
fi

case ${ACTION_TYPE} in
  plan)
    echo "Running plan action"
    cleanUp
    echo "Docker command: ${runCmd}"
    ${runCmd} plan
    exit_on_error $? !!
    ;;
  docker-plan)
    echo "Running docker plan action"
    terragrunt init
    exit_on_error $? !!
    terragrunt plan -detailed-exitcode --out ${TG_ENVIRONMENT_TYPE}.plan
    exit_on_error $? !!
    ;;
  apply)
    echo "Running apply action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} apply
    exit_on_error $? !!
    ;;
  docker-apply)
    echo "Running docker apply action"
    terragrunt apply ${TG_ENVIRONMENT_TYPE}.plan
    exit_on_error $? !!
    ;;
  destroy)
    echo "Running destroy action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} destroy
    exit_on_error $? !!
    ;;
  docker-destroy)
    echo "Running docker destroy action"
    terragrunt destroy -force
    exit_on_error $? !!
    ;;
  test)
    echo "Running test action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} test
    exit_on_error $? !!
    ;;
  docker-test)
    echo "Running docker apply action"
    sh scripts/generate-terraform-outputs.sh
    exit_on_error $? !!
    sh scripts/aws-get-temp-creds.sh
    exit_on_error $? !!
    source env_configs/inspec-creds.properties
    exit_on_error $? !!
    inspec exec ${inspec_profile} -t aws://${TG_REGION}
    exit_on_error $? !!
    ;;
  output)
    echo "Running output action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} output
    exit_on_error $? !!
    ;;
  docker-output)
    echo "Running docker apply action"
    terragrunt output
    exit_on_error $? !!
    ;;
  *)
    echo "${ACTION_TYPE} is not a valid argument. init - apply - test - output - destroy"
  ;;
esac