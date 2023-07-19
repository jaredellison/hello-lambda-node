include .env
export

LATEST_IMAGE_URI := ${AWS_REPOSITORY_URI}:latest

# ---------------------------------------- #
# Docker Commands
# ---------------------------------------- #
docker-auth:
	aws ecr get-login-password --region ${AWS_REGION} --profile ${AWS_SSO_PROFILE} \
	| docker login --username AWS --password-stdin ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker-build:
	docker build . -t ${DOCKER_IMAGE_NAME} --platform linux/amd64

docker-run:
	docker run -p 9000:8080 ${DOCKER_IMAGE_NAME}

docker-tag:
	docker tag ${DOCKER_IMAGE_NAME} ${LATEST_IMAGE_URI}

docker-push:
	docker push ${LATEST_IMAGE_URI}

# ---------------------------------------- #
# AWS Commands
# ---------------------------------------- #
aws-create-repository:
	aws ecr create-repository --repository-name ${AWS_REPOSITORY_NAME} \
		--image-scanning-configuration scanOnPush=true \
		--image-tag-mutability MUTABLE \
		--profile ${AWS_SSO_PROFILE}

aws-create-role:
	aws iam create-role \
		--role-name lambda-ex \
		--assume-role-policy-document \
		--profile ${AWS_SSO_PROFILE} \
		'{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

aws-create-function:
	aws lambda create-function \
		--function-name ${AWS_FUNCTION_NAME} \
		--package-type Image \
		--code ImageUri=${LATEST_IMAGE_URI} \
		--role ${AWS_EXECUTION_ROLE} \
		--profile ${AWS_SSO_PROFILE} \

aws-invoke-function:
	aws lambda invoke \
		--function-name ${AWS_FUNCTION_NAME} \
		--profile ${AWS_SSO_PROFILE} \
		response.json  \
	&& cat response.json | jq \
	&& rm response.json
