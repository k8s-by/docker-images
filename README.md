# Docker Image Rebuilder

## TL;DR

Add new tag to `<project folder>/build.properties` `VERSIONS` variable and commit changes.


## Github Action


Github Action will be triggered on each commit to `master` branch. It will rebuild all images with tags that missed in docker registry.


Secrets for github action to work:

 - DOCKERHUB_USERNAME
 - DOCKERHUB_PASSWORD (better use Personal Token)
 - DOCKER_REGISTRY (use DOCKERHUB_USERNAME for docker.io)


## Local Build

```
export DOCKER_REGISTRY=<DOCKERHUB_USERNAME>
cd <project folder>
make build VERSION=<image tag>   # to build image with specific version
make release VERSION=<image tag> # to build and push image with specific version
make build-all                   # to build images with all versions from $(VERSIONS) var. See build.properties
make release-all                 # to build and push images with all versions from $(VERSIONS) variable
```

Please make sure, `make` ignores build and push process if image with the specific tag is already exists in registry.


## Build All

From the root folder:

```
export DOCKER_REGISTRY=<DOCKERHUB_USERNAME>
make build-all
make release-all
```
