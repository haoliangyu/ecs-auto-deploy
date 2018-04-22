# ecs-auto-deploy

[![Build Status](https://travis-ci.org/haoliangyu/ecs-auto-deploy.svg?branch=master)](https://travis-ci.org/haoliangyu/ecs-auto-deploy)

This is an example project to show **how to use Travis CI for AWS ECS auto-deployment**.

## how-to

This repository utilizes the [script deployment](https://docs.travis-ci.com/user/deployment/script/) of Travis CI and the [ecs-deploy](https://github.com/silinternational/ecs-deploy) library.

It establishes a continuous deployment pipeline to the [AWS ECS](https://aws.amazon.com/ecs/), which is triggered by every update on the `master` branch (like a PR).

### Deployment Script

A deployment script ([deploy.sh](./deploy.sh)) is used to build, push, and deploy the container image:

* build the new docker image

* push to an image repository with the `latest` tag

* update the AWS ECS service with the new image.

``` bash
# install aws-sdk
pip install --user awscli
export PATH=$PATH:$HOME/.local/bin

# install ecs-deploy
add-apt-repository ppa:eugenesan/ppa
apt-get update
apt-get install jq -y

curl https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy | \
  sudo tee -a /usr/bin/ecs-deploy
sudo chmod +x /usr/bin/ecs-deploy

# Use this for AWS ECR
# eval $(aws ecr get-login --region us-east-1)

# Use this for Docker Hub
docker login --username $DOCKER_HUB_USER --password $DOCKER_HUB_PSW

# Build and push the image to the repository
docker build -t haoliangyu/ecs-auto-deploy .
docker tag haoliangyu/ecs-auto-deploy:latest $IMAGE_REPO_URL:latest
docker push $IMAGE_REPO_URL:latest

# deploy the new image to the aws ecs
ecs-deploy -c $CLUSTER_NAME -n $SERVICE_NAME -i $IMAGE_REPO_URL:latest
```

This script uses several environment variables to provide secrets:

* `IMAGE_REPO_URL`: the url or name of container image repository
* `CLUSTER_NAME`: AWS ECS cluster name
* `SERVICE_NAME`: AWS ECS cluster service name

To login AWS, it reads the AWS credential either from the environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) or the aws config file. If [Docker Hub](https://hub.docker.com) is used to host the image, the script uses the `DOCKER_HUB_USER` and `DOCKER_HUB_PSW` for `docker login`.

A full example of needed environment variables is at [.env.example](./.env.example).

Note that the [ecs-deploy](https://github.com/silinternational/ecs-deploy) library assumes that the target cluster and service are running and it is going to updat the task definition then deploy. If the service doesn't exist, the library will throw an error.

### Travis CI Configuration

The following configuration ([.travis.yml](./.travis.yml)) is used to set up the deployment pipeline for every update on the `master` branch.

``` yaml
# We are using a nodejs application as an example
language: node_js
node_js:
  - "node"

# Install docker
services:
  - docker

# Use script deployment and specify the script path
deploy:
  provider: script
  script: bash deploy.sh
  # Only deploy when the master branch is updated
  on:
    branch: master
```

To enable it, you need to add all required environment variables to the Travis CI project setting.

## blog post

For more details, please take a look at this blog post [AWS ECS continuous deployment with Travis CI](https://haoliangyu.github.io/blog/2018/03/19/AWS-ECS-auto-deployment-with-Travis-CI/).
