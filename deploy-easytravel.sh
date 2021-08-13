#!/bin/bash

export DEPLOY_LOADGEN=${DEPLOY_LOADGEN:-true}

kubectl apply -f manifests/namespace.yaml

kubectl apply -f manifests/backend/

kubectl apply -f manifests/frontend/

kubectl -n easytravel create rolebinding default-view --clusterrole=view --serviceaccount=dev:default

if [[ "$DEPLOY_LOADGEN" == "true" ]]; then
    kubectl apply -f manifests/loadgen/
fi