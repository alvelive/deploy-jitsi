#!/bin/bash

set -e

if [ -z "$KUBECONFIG" ]; then
  echo "KUBECONFIG not set."
  exit 1
fi

if [ -z "$JITSI_COMPONENT" ]; then
  echo "Component not provided."
  exit 1
fi

echo "Component: $JITSI_COMPONENT"
echo "KUBECONFIG: $KUBECONFIG"

echo "Checking Kubernetes connectivity..."

kubectl cluster-info

echo "Retrieving pods..."

POD_NAMES=$(kubectl get pods --no-headers | awk '{print $1}')

if [ -z "$POD_NAMES" ]; then
  echo "No pods found."
  exit 0
fi

POD_COUNT="$(echo "$POD_NAMES" | wc -l)"

echo "$POD_COUNT pod(s) found"

MATCH="jitsi.*-$JITSI_COMPONENT-"

echo "Matching pod(s) with $MATCH..."

MATCHING_PODS=$(echo "$POD_NAMES" | grep "$MATCH")

if [ -z "$MATCHING_PODS" ]; then
  echo "No matching pod(s) to delete."
  exit 0
fi

MATCHING_COUNT="$(echo "$MATCHING_PODS" | wc -l)"

echo "Deleting $MATCHING_COUNT pod(s)"
echo "$MATCHING_PODS" | xargs -P 16 -n 1 kubectl delete pod
