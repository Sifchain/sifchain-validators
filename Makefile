build-image:
	docker build -t sifchain/$(SERVICE):$(IMAGE_TAG) -f ./docker/$(SERVICE)/$(IMAGE_TAG)/Dockerfile .

bundler:
	@gem install bundler
	@bundler install

lint:
	@bundle exec rubocop rake/lib rake/spec

tests:
	@cd rake && bundle exec rspec
