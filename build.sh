#!/bin/bash

BUILD_TOOL="$1"
IMAGE="$(cat VERSION)"

echo "Build $IMAGE docker image..."

if [ "$BUILD_TOOL" = "docker" ]; then
  docker build -t ${IMAGE} .
elif [ "$BUILD_TOOL" = "gcloud" ]; then
  gcloud builds submit --timeout="1h" -t ${IMAGE} .
else
  >&2 echo "Error: Unrecognized build tool: $BUILD_TOOL"
fi
