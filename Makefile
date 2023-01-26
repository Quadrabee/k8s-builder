default: build push

build:
	docker build -t quadrabee/k8s-builder:4.3 .
	docker build -t quadrabee/k8s-builder-dind:4.3 . -f Dockerfile.dind

push:
	docker push quadrabee/k8s-builder:4.3
	docker push quadrabee/k8s-builder-dind:4.3
