# GCP Utils

This repository contains scripts and utilities for automating common tasks in GCP  
  
## Enable All APIs in a GCP Project
``` shell
git clone git@github.com:noahmercado/gcp-utils.git
cd gcp-utils
gcloud auth login
gcloud config set project <PROJECT_ID>
./enable_all_apis.sh
```