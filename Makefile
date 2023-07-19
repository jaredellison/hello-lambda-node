
CONTAINER_IMAGE_NAME := docker-image:test

# ---------------------------------------- #
# Docker Commands
# ---------------------------------------- #
docker-build:
	docker build -t ${CONTAINER_IMAGE_NAME} .

docker-run:
	docker run -p 9000:8080 ${CONTAINER_IMAGE_NAME}