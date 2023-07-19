# hello-lambda-node

Code based on AWS developer guide: https://docs.aws.amazon.com/lambda/latest/dg/typescript-image.html

## Local environment set up

- Create an account with Amazon Web Services

- Install local development tools:

  - Node.js
  - Docker
  - [AWS CLI (v2)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - Make

- Set up a minimally privileged account to use with the `aws` CLI. [See documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html). Current best practice is to follow [these instructions](https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html) creating an AWS organization, a minimally privileged account and logging into the account using `aws configure sso` which writes short-lived credentials to your development machine. To upload docker images to an AWS container registry and deploy a lambda service the following permissions are required:

  - `AmazonEC2ContainerRegistryFullAccess`
  - `AWSLambda_FullAccess`

- Authenticate the AWS CLI using `aws configure sso`.

- Authenticate the Docker CLI. Create a `.env` file based on `.env-example` and run `make docker-auth`.

## Building and pushing an image

- Add a docker image name to your `.env` file and create a docker image using by running `make docker-build`.

- Test that the image runs locally by running `make docker-run` and calling it with:

```bash
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
{"statusCode":200,"body":"{\"message\":\"hello world\"}"} | jq
```

- Create a repository for storing docker images by adding a repository name to `.env`, using `make aws-create-repository` and adding the resulting repository uri to `.env`.

- Upload your image to the repository by running `make docker-tag` and `make docker-push`.

- Create an execution role for the function using `make aws-create-role` adding the resulting Amazon Resource Name (ARN) to your `.env` file.

- Create the function by running `make aws-create-function`

- Test the function by running `make aws-invoke-function`

- To redeploy the function with changes run `make docker-build-tag-push` and `make aws-update-function-code`. Note that updating the code happens asynchronously and it may take a nearly a minute for the changes to be visible.
