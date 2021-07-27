build-image:
	docker build -t sifchain/$(SERVICE):$(IMAGE_TAG) -f ./docker/$(SERVICE)/$(IMAGE_TAG)/Dockerfile .
