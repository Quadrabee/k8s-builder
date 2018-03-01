default: build push

build:
	docker build -t quadrabee/k8s-builder .
	docker build -t quadrabee/k8s-builder:dind . -f Dockerfile.dind

push:
	docker push quadrabee/k8s-builder
	docker push quadrabee/k8s-builder:dind