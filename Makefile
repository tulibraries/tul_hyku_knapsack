#Defaults
include .env
export #exports the .env variables

IMAGE ?= tulibraries/tul-hyku
VERSION ?= 1.0.0
HARBOR ?= harbor.k8s.temple.edu
HYKU ?= ghcr.io/samvera/hyku

build-hyku-base:
	@docker tag harbor.k8s.temple.edu/tulibraries/hyrax-base:latest ghcr.io/samvera/hyrax/hyrax-base:latest
	@pushd hyrax-webapp; docker build \
		--build-arg HYRAX_IMAGE_VERSION=latest \
		--target hyku-base \
		--tag $(HARBOR)/$(IMAGE)/hyku-base:$(VERSION) \
		--tag $(HARBOR)/$(IMAGE)/hyku-base:latest \
		--platform $(PLATFORM) \
		--progress plain \
		--no-cache .; popd

build: build-web build-worker

build-web:
	@docker build \
    --build-arg APP_PATH=./hyrax-webapp \
		--target hyku-web \
		--tag $(HARBOR)/$(IMAGE)/web:$(VERSION) \
		--tag $(HARBOR)/$(IMAGE)/web:latest \
		--file Dockerfile \
		--progress plain \
		--no-cache .

build-worker:
	@docker build --build-arg BUILDKIT_INLINE_CACHE=1 \
    --build-arg APP_PATH=./hyrax-webapp \
		--target hyku-worker \
		--tag $(HARBOR)/$(IMAGE)/worker:$(VERSION) \
		--tag $(HARBOR)/$(IMAGE)/worker:latest \
		--file Dockerfile \
		--progress plain \
		--no-cache .

scan:
	trivy image "$(HARBOR)/$(IMAGE)/hyku-base:$(VERSION)" --scanners vuln;

shell-web:
	@docker run --rm -it \
		--entrypoint=sh --user=root \
		$(HARBOR)/$(IMAGE)/hyku-base:$(VERSION)

deploy-hyku-base:
	@docker push $(HARBOR)/$(IMAGE)/hyku-base:$(VERSION) \
		# This "if" statement needs to be a one liner or it will fail.
		# Do not edit indentation
		@if [ $(VERSION) != latest ]; \
			then \
				docker push $(HARBOR)/$(IMAGE)/hyku-base:latest; \
			fi

deploy: deploy-web deploy-worker

deploy-web:
	@docker push $(HARBOR)/$(IMAGE)/web:$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE)/web:latest; \
		fi

deploy-worker:
	@docker push $(HARBOR)/$(IMAGE)/worker:$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE)/worker:latest; \
		fi
