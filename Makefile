.SILENT:

help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-12s\033[0m%s\n", $$1, $$2 }'

dev: # start the site with nodemon and livereload
	./dev.sh

dev-build: # build the development image
	docker image build \
		--file env.dev.dockerfile \
		--tag site \
		.

dev-run: # run the built development image
	docker run \
		--name site \
		--publish 3000:3000 \
		--publish 35729:35729 \
		--volume "$$PWD:/app" \
		site

rm: # remove the running container
	docker container rm --force site || true

prod: # start the site in production environment
	NODE_ENV=production node index.js

prod-build: # build the production image
	./prod-build.sh

prod-run: # run the built production image
	docker run \
		--name site \
		--publish 80:80 \
		jeromedecoster/site

prod-ecr-build: # build the production image for ECR
	./prod-ecr-build.sh

service-up: # create the cluster and start a service
	./service-up.sh

service-down: # terminate the service and the cluster
	./service-down.sh