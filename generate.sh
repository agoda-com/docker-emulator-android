#!/usr/bin/env bash

function createDockerfile() {
  platform=$1
  mkdir -p ./build/$platform
  docker run -e PLATFORM="$platform" -v $(pwd):/src hairyhenderson/gomplate --input-dir=/src/templates --output-dir=/src/build/$platform
  cp base/* ./build/$platform
}

rm -rf ./build

createDockerfile android-16
createDockerfile android-17
createDockerfile android-18
createDockerfile android-19
createDockerfile android-21
createDockerfile android-22
createDockerfile android-23
createDockerfile android-24
createDockerfile android-25
createDockerfile android-26
