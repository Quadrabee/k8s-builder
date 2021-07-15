default: build push

build:
	docker build -t quadrabee/k8s-builder:3.1 .
	docker build -t quadrabee/k8s-builder-dind:3.1 . -f Dockerfile.dind

push:
	docker push quadrabee/k8s-builder:3.1
	docker push quadrabee/k8s-builder-dind:3.1
