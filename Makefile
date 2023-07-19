include .env
export

# ---------------------------------------- #
# Docker Commands
# ---------------------------------------- #
docker-auth:
	aws ecr get-login-password --region ${AWS_REGION} --profile ${AWS_SSO_PROFILE} \
	| docker login --username AWS --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker-build:
	docker build -t ${DOCKER_IMAGE_NAME} .

docker-run:
	docker run -p 9000:8080 ${DOCKER_IMAGE_NAME}

# ---------------------------------------- #
# AWS Commands
# ---------------------------------------- #
aws-create-repository:
	aws ecr create-repository --repository-name ${AWS_REPOSITORY_NAME} \
	--image-scanning-configuration scanOnPush=true \
	--image-tag-mutability MUTABLE \
	--profile ${AWS_SSO_PROFILE}
