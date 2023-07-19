# hello-lambda-node

Code based on AWS developer guide: https://docs.aws.amazon.com/lambda/latest/dg/typescript-image.html

# Local environment set up

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
