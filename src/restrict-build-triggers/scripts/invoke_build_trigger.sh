#!/usr/bin/env bash

# Copyright 2022 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CURRENT_USER=$(gcloud config get-value account)
CURRENT_PROJECT=$(gcloud config get-value project)
CURRENT_ORG_ID=$(gcloud projects get-ancestors ${CURRENT_PROJECT} | grep organization | cut -d ' ' -f1)
CURRENT_ORG_NAME=$(gcloud organizations describe ${CURRENT_ORG_ID} --format="value(displayName)")
CURRENT_GIT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

function usage() {
    cat <<EOT
$(basename "$0") usage:

Options:

    --trigger, -t [Required] The name of the Cloud Build Trigger to invoke
    --region, -r [Required] The region of the Cloud Builder Trigger 

EOT
}

function get_args() {
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
        REGION="$2"
        shift
        shift
        ;;
        -t|--trigger)
        TRIGGER="$2"
        shift
        shift
        ;;
        -h|--help)
        usage
        exit 0
        ;;
        -*|--*)
        echo "Unknown option $1"
        echo ""
        usage
        exit 1
        ;;
        *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
    done
}

function user_is_in_group() {
    local __group=$1
    local __resultvar=$2
    local membership=$(gcloud identity groups memberships check-transitive-membership --group-email="${__group}@${CURRENT_ORG_NAME}" --member-email="${CURRENT_USER}" 2> /dev/null || echo "hasMembership: false")
    local result=$(echo $membership | yq .hasMembership )
    eval $__resultvar="'${result}'"
}

function verify_args() {
    if [[ -z $TRIGGER || -z $REGION ]]
    then
        echo "Required arguments are missing!"
        usage
        exit 1
    fi
}

function verify_access() {
    local __trigger=$1
    local __region=$2

    TRIGGER_TAGS=( $(gcloud beta builds triggers describe ${__trigger} --region ${__region} | yq e -o=j -I=0  '.tags[]' | yq '.. style="literal"') )
    for tag in "${TRIGGER_TAGS[@]}"
    do
        user_is_in_group $tag is_in_group_result

        if [[ "${is_in_group_result}" == "true" ]]
        then

            return 0
        fi
    done

    return 1
}

function invoke_trigger() {
    local __trigger=$1
    local __region=$2
    local __branch=$3

    gcloud beta builds triggers run ${__trigger} --region ${__region} --branch=${__branch}
}

get_args $@
verify_args
verify_access $TRIGGER $REGION || echo "${CURRENT_USER} is not authorized to invoke Cloud Build Trigger ${trigger}!" && exit 1
invoke_trigger $TRIGGER $REGION $CURRENT_GIT_BRANCH