SHELL := /usr/bin/env bash
VERSIONS ?= android-16 android-17 android-18 android-19 android-21 android-22 android-23 android-24 android-25 android-26 android-27 android-28
ABI ?= x86 x86_64

generate:
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			mkdir -p ./build/$$version/$$abi ; \
			sed -e "s/{{ abi }}/$$abi/g" -e "s/{{ platform }}/$$version/g" templates/Dockerfile > build/$$version/$$abi/Dockerfile ; \
			sed -e "s/{{ abi }}/$$abi/g" -e "s/{{ platform }}/$$version/g" templates/config.ini > build/$$version/$$abi/config.ini ; \
			sed "s/{{ platform }}/$$version/g" templates/start.sh > build/$$version/$$abi/start.sh ; \
			sed "s/{{ platform }}/$$version/g" templates/Makefile > build/$$version/$$abi/Makefile ; \
			sed "s/{{ platform }}/$$version/g" templates/snapshot.sh > build/$$version/$$abi/snapshot.sh ; \
			sed "s/{{ platform }}/$$version/g" templates/snapshot.expect > build/$$version/$$abi/snapshot.expect ; \
			sed -e "s/{{ abi }}/$$abi/g" -e "s/{{ platform }}/$$version/g" templates/take_snapshot.sh > build/$$version/$$abi/take_snapshot.sh ; \
			cp base/* ./build/$$version/$$abi ; \
		done \
	done

clean:
	rm -rf ./build

build: generate
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			$(MAKE) -C build/$$version/$$abi build; \
		done \
	done

lint: generate
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			$(MAKE) -C build/$$version/$$abi lint; \
		done \
	done

snapshot: generate build
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			$(MAKE) -C build/$$version/$$abi snapshot; \
		done \
	done

tag: generate
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			$(MAKE) -C build/$$version/$$abi tag; \
		done \
	done

login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)" "$(PROXY)"

push: login
	for version in $(VERSIONS); do \
		for abi in $(ABI); do \
			$(MAKE) -C build/$$version/$$abi push; \
		done \
	done
