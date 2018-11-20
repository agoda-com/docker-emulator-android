#!/usr/bin/env bash

set -ex

docker rm -f emulator || true

docker run -d -t --name emulator --rm --privileged -v /dev/kvm:/dev/kvm -e ANDROID_ARCH="x86" agoda/docker-emulator-{{ platform }} bash

docker cp snapshot.sh emulator:/snapshot.sh
docker cp snapshot.expect emulator:/snapshot.expect
docker exec -t emulator bash -c "bash /snapshot.sh; exit"
echo "Creating new image"
docker commit -m "Snapshot!" --change "CMD [\"/start.sh\"]" emulator agoda/docker-emulator-{{ platform }}-snapshot
docker rm -f emulator
