#!/usr/bin/env bash

set -ex

image_name=$1
snapshot_image_name=$2

docker rm -f emulator || true

docker run -d -t --name emulator --rm --privileged -v /dev/kvm:/dev/kvm -e ANDROID_ARCH="x86" $image_name bash

docker cp snapshot.sh emulator:/snapshot.sh
docker cp snapshot.expect emulator:/snapshot.expect
docker exec -t emulator bash -c "bash /snapshot.sh; exit"
echo "Creating new image"
docker commit -m "Snapshot!" --change "CMD [\"/start.sh\"]" emulator $snapshot_image_name
docker rm -f emulator
