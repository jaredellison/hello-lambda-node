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

docker-build-tag-push: docker-build docker-tag docker-push

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
		--profile ${AWS_SSO_PROFILE} \
		--assume-role-policy-document \
		'{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

aws-attach-log-policy:
	aws iam attach-role-policy \
		--role-name lambda-ex \
		--profile ${AWS_SSO_PROFILE} \
		--policy arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws-create-function:
	aws lambda create-function \
		--function-name ${AWS_FUNCTION_NAME} \
		--package-type Image \
		--code ImageUri=${LATEST_IMAGE_URI} \
		--role ${AWS_EXECUTION_ROLE} \
		--profile ${AWS_SSO_PROFILE} \

aws-update-function-code:
	aws lambda update-function-code \
		--function-name ${AWS_FUNCTION_NAME} \
		--image-uri ${LATEST_IMAGE_URI} \
		--profile ${AWS_SSO_PROFILE} \

aws-invoke-function:
	aws lambda invoke \
		--function-name ${AWS_FUNCTION_NAME} \
		--profile ${AWS_SSO_PROFILE} \
		response.json  \
	&& cat response.json | jq \
	&& rm response.json

aws-create-api:
	aws apigatewayv2 create-api --name ${AWS_GATEWAY_NAME} \
		--protocol-type HTTP \
		--profile ${AWS_SSO_PROFILE}

aws-create-stage:
	aws apigatewayv2 create-stage \
		--api-id ${AWS_GATEWAY_ID} \
		--stage-name default \
		--profile ${AWS_SSO_PROFILE}

aws-create-integration:
	aws apigatewayv2 create-integration \
		--api-id ${AWS_GATEWAY_ID} \
		--integration-uri ${AWS_FUNCTION_URI} \
		--integration-type AWS_PROXY \
		--payload-format-version 1.0 \
		--profile ${AWS_SSO_PROFILE}

aws-create-route:
	aws apigatewayv2 create-route \
		--api-id ${AWS_GATEWAY_ID} \
		--route-key 'ANY /hello-world' \
		--authorization-type NONE \
		--target integrations/${AWS_GATEWAY_INTEGRATION_ID} \
		--profile ${AWS_SSO_PROFILE}

aws-lambda-add-permission:
	aws lambda add-permission \
		--function-name ${AWS_FUNCTION_NAME} \
		--statement-id apigateway-invoke-permissions \
		--action lambda:InvokeFunction \
		--principal apigateway.amazonaws.com \
		--source-arn "arn:aws:execute-api:${AWS_REGION}:${AWS_ACCOUNT_NUMBER}:${AWS_GATEWAY_ID}/*/*" \
		--profile ${AWS_SSO_PROFILE}

aws-create-deployment:
	aws apigatewayv2 create-deployment \
		--api-id ${AWS_GATEWAY_ID} \
		--stage-name default \
		--profile ${AWS_SSO_PROFILE}