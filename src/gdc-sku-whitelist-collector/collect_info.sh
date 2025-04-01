#!/usr/bin/env bash

set-vars() {
    PROJECT_ID=$(gcloud config get-value project)
    PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
    ORGANIZATION_ID=$(gcloud projects get-ancestors ${PROJECT_ID} --format=json | jq -r '.[] | select(.type == "organization") | .id')
}

print-output() {
    echo "-------------------------------"
    echo "projectId: ${PROJECT_ID}"
    echo "projectNumber: ${PROJECT_NUMBER}"
    echo "organizationId: ${ORGANIZATION_ID}"
    echo "-------------------------------"
}

set-vars
print-output