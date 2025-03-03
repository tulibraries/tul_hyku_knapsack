#Defaults
include .env
export #exports the .env variables

IMAGE ?= tulibraries/tul-hyku
VERSION ?= 1.2.4
HARBOR ?= harbor.k8s.temple.edu
HYKU ?= ghcr.io/samvera/hyku

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
	trivy image "$(HARBOR)/$(IMAGE)/web:$(VERSION)" --scanners vuln;

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
