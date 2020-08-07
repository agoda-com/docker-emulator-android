OWNER=fahrudina
IMAGE_NAME=docker-emulator-{{ platform }}
VCS_REF=`git rev-parse --short HEAD`
IMAGE_VERSION ?= 1.0.0
PROXY ?=
QNAME=$(PROXY)$(OWNER)/$(IMAGE_NAME)

GIT_TAG=$(QNAME):$(VCS_REF)
BUILD_TAG=$(QNAME):$(IMAGE_VERSION)
LATEST_TAG=$(QNAME):latest

SNAPSHOT_IMAGE_NAME=docker-emulator-snapshot-{{ platform }}
SNAPSHOT_QNAME=$(PROXY)$(OWNER)/$(SNAPSHOT_IMAGE_NAME)
SNAPSHOT_GIT_TAG=$(SNAPSHOT_QNAME):$(VCS_REF)
SNAPSHOT_BUILD_TAG=$(SNAPSHOT_QNAME):$(IMAGE_VERSION)
SNAPSHOT_LATEST_TAG=$(SNAPSHOT_QNAME):latest

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	docker build \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg IMAGE_VERSION=$(IMAGE_VERSION) \
		-t $(LATEST_TAG) $(ROOT_DIR)

snapshot:
	bash $(ROOT_DIR)/take_snapshot.sh $(LATEST_TAG) $(SNAPSHOT_LATEST_TAG)

lint:
	docker run -it --rm -v "$(ROOT_DIR)/Dockerfile:/Dockerfile:ro" redcoolbeans/dockerlint

tag:
	docker tag $(LATEST_TAG) $(BUILD_TAG)
	docker tag $(LATEST_TAG) $(GIT_TAG)
	docker tag $(SNAPSHOT_LATEST_TAG) $(SNAPSHOT_BUILD_TAG)
	docker tag $(SNAPSHOT_LATEST_TAG) $(SNAPSHOT_GIT_TAG)

push:
	docker push $(GIT_TAG)
	docker push $(BUILD_TAG)
	docker push $(LATEST_TAG)
	docker push $(SNAPSHOT_GIT_TAG)
	docker push $(SNAPSHOT_BUILD_TAG)
	docker push $(SNAPSHOT_LATEST_TAG)
