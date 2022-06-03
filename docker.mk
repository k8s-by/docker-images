include build.properties

build:
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION) --build-arg VERSION=$(VERSION) .

build-all:
	$(foreach version, $(VERSIONS), make build VERSION=$(version);)

push:
	docker push $(DOCKER_REGISTRY)/$(DOCKER_NAME):$(VERSION)

push-all:
	$(foreach version, $(VERSIONS), make push VERSION=$(version);)

release: build push

release-all: build-all push-all
