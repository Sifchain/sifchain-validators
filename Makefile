build-image:
	docker build -t sifchain/$(BINARY):$(IMAGE_TAG) -f ./docker/$(BINARY)/Dockerfile .
