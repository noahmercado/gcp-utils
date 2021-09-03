#!/usr/bin/env bash

# Copyright 2021 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CURRENT_PROJECT=$(gcloud config get-value project)
AVAILABLE_SERVICES=$(gcloud services list --available --format="value(config.name)")
NUMBER_OF_AVAILABLE_SERVICES=$(echo "$AVAILABLE_SERVICES" | wc -l | tr -d '[:space:]')
echo $NUMBER_OF_AVAILABLE_SERVICES

validate_continue() {
    read -p "This script will enable ${NUMBER_OF_AVAILABLE_SERVICES} services for the GCP project ${CURRENT_PROJECT}. Are you sure you want to continue? [y/N]: " user_response 

    if [[ "$user_response" != "y" ]]
    then
        echo "Quitting..."
        exit 0
    fi
}

enable_all_apis() {
    for SERVICE in $AVAILABLE_SERVICES
    do
        echo "enabling $SERVICE for $CURRENT_PROJECT..."
        gcloud services enable --async $SERVICE
    done
}

validate_continue
enable_all_apis
