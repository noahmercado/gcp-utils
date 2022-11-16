# GCP Utils

This repository contains scripts and utilities for automating common tasks in GCP  
  
# Google Disclaimer
This is not an officially supported Google product

## Enable All APIs in a GCP Project
``` shell
git clone git@github.com:noahmercado/gcp-utils.git
cd gcp-utils
gcloud auth login
gcloud config set project <PROJECT_ID>
./src/enable_all_apis.sh
```