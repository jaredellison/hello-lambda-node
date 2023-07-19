include .env
export

CONTAINER_IMAGE_NAME := docker-image:test

# ---------------------------------------- #
# Docker Commands
# ---------------------------------------- #
docker-auth:
	aws ecr get-login-password --region ${AWS_REGION} --profile ${AWS_SSO_PROFILE} \
	| docker login --username AWS --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker-build:
	docker build -t ${CONTAINER_IMAGE_NAME} .

docker-run:
	docker run -p 9000:8080 ${CONTAINER_IMAGE_NAME}