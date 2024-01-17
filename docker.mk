ALPINE_VERSION?=3.19

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

TAG="$(VERSION)$(TAG_SUFFIX)"

build:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(TAG) \
		--build-arg VERSION=$(VERSION) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		$(EXTRA_ARGS) .

build-all:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	$(call check_defined, VERSIONS)
	$(foreach version, $(VERSIONS), make build VERSION=$(version);)

release:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	docker manifest inspect $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) || ( \
		make build VERSION=$(VERSION) && \
		docker push $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(TAG) \
	)

release-all:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	$(call check_defined, VERSIONS)
	$(foreach version, $(VERSIONS), make release VERSION=$(version);)

