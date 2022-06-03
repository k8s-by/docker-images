include build.properties

check:
	ifndef DOCKER_REGISTRY
	$(error "DOCKER_REGISTRY is not defined")
	endif

build: check
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) --build-arg VERSION=$(VERSION) .

build-all: check
	$(foreach version, $(VERSIONS), make build VERSION=$(version);)

release: check
	docker manifest inspect $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) || ( \
		make build VERSION=$(VERSION) && \
		docker push $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) \
	)

release-all: check
	$(foreach version, $(VERSIONS), make release VERSION=$(version);)
