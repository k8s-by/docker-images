check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

DOCKERFILE?=Dockerfile
KANIKO_CONTEXT?=dir:///workspace/
KANIKO_LOGLEVEL?=info
KANIKO_CACHE?="false"
KANIKO_CACHE_REPO?=


build:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	$(call check_defined, VERSIONS)
	@docker run -v $$(pwd):/workspace \
           -v ~/.docker/config.json:/kaniko/.docker/config.json:ro \
           gcr.io/kaniko-project/executor:latest \
             --cleanup \
             --verbosity=$(KANIKO_LOGLEVEL) \
             --dockerfile=$(DOCKERFILE) \
             --context=$(KANIKO_CONTEXT) \
             --cache=$(KANIKO_CACHE) $(KANIKO_CACHE_REPO) \
             --destination=$(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) \
             --build-arg=VERSION=$(VERSION)

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
		#docker push $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) \
	)

release-all:
	$(call check_defined, DOCKER_REGISTRY)
	$(call check_defined, DOCKER_NAME)
	$(call check_defined, VERSIONS)
	$(foreach version, $(VERSIONS), make release VERSION=$(version);)
