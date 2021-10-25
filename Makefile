default: build push

build:
	docker build -t quadrabee/k8s-builder:19.03.12 .

push:
	docker push quadrabee/k8s-builder:19.03.12
