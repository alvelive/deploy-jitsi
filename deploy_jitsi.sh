#!/bin/bash

set -e

missing_config=0

if [ -z "$KUBECONFIG" ]; then
  missing_config=1
  echo "KUBECONFIG not set."
fi

if [ -z "$JITSI_COMPONENT" ]; then
  missing_config=1
  echo "JITSI_COMPONENT not set."
fi

if [ "$missing_config" -eq 1 ]; then
  echo "Missing configuration. Exiting..."
  exit 1
fi

echo "KUBECONFIG: $KUBECONFIG"
echo "JITSI_COMPONENT: $JITSI_COMPONENT"

echo

echo "Checking Kubernetes connectivity..."

kubectl cluster-info >/dev/null

echo "Retrieving pods..."
echo

POD_NAMES=$(kubectl get pods --no-headers | awk '{print $1}')

if [ -z "$POD_NAMES" ]; then
  echo "No pods found."
  exit 0
fi

POD_COUNT="$(echo "$POD_NAMES" | wc -l)"

echo "$POD_COUNT pod(s) found"
echo

MATCH="jitsi.*-$JITSI_COMPONENT-"

echo "Matching pod(s) with $MATCH..."
echo

MATCHING_PODS=$(echo "$POD_NAMES" | grep "$MATCH" | tr -s ' ' | xargs)

if [ -z "$MATCHING_PODS" ]; then
  echo "No matching pod(s) to delete."
  exit 0
fi

MATCHING_COUNT="$(echo "$MATCHING_PODS" | wc -l)"

echo "Deleting $MATCHING_COUNT pod(s)"
echo

echo "$MATCHING_PODS" | xargs -P 16 -n 1 kubectl delete pod
