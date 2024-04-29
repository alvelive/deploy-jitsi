#!/bin/bash

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

POD_NAMES=$(kubectl get pods --no-headers | awk '{print $1}' || -1)

if [ $POD_NAMES -eq -1 ]; then
  echo "Failed to retrieve pods."
  exit 1
fi

if [ -z $POD_NAMES ]; then
  echo "No pods found."
  exit 0
fi

POD_COUNT="$(echo $POD_NAMES | wc -l)"
MATCH="jitsi.*-$JITSI_COMPONENT-"

echo "$POD_COUNT pods found"
echo 'Matching pods with $MATCH...'

MATCHING_PODS=$(echo "$POD_NAMES" | grep "$MATCH" || -1)

if [ $MATCHING_PODS -eq -1 ]; then
  echo "Failed to match pods with $MATCH"
  exit 1
fi

if [ -z "$MATCHING_PODS" ]; then
  echo "No matching pods to delete."
  exit 0
fi

echo "Deleting pods..."
echo "$MATCHING_PODS" | xargs -P 16 -n 1 kubectl delete pod
