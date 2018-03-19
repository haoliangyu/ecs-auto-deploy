# ecs-auto-deploy

[![Build Status](https://travis-ci.org/haoliangyu/ecs-auto-deploy.svg?branch=master)](https://travis-ci.org/haoliangyu/ecs-auto-deploy)

This is an example project to show **how to use Travis CI for AWS ECS auto-deployment**.

## how-to

This repository utilizes the [script deployment](https://docs.travis-ci.com/user/deployment/script/) of Travis CI and the  [ecs-deploy](https://github.com/silinternational/ecs-deploy) library.

The purpose of the CI pipeline is that at each PR merged into the master branch, it will

* build the new docker image

* push to an image repository with the `latest` tag

* update the AWS ECS service with the new image.

The following bash script is to finish these tasks. It uses three environment variables to determine which and where the service should be updated:

* `IMAGE_REPO_URL`

  the destination image repository url

* `CLUSTER_NAME`

  AWS ECS cluster name

* `SERVICE_NAME`

  AWS ECS cluster service name

Additionally, it reads the AWS credential either from the environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) or the aws config file. For the full example of the needed environment variables, see [.env.example](./.env.example).

Note that the [ecs-deploy](https://github.com/silinternational/ecs-deploy) library assumes that the target cluster and service are running and it is going to updat the task definition then deploy. If the service doesn't exist, the library will throw an error.

``` bash
# install aws-sdk
pip install --user awscli
export PATH=$PATH:$HOME/.local/bin

# install ecs-deploy
add-apt-repository ppa:eugenesan/ppa
apt-get update
apt-get install jq -y

curl https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy | sudo tee -a /usr/bin/ecs-deploy
sudo chmod +x /usr/bin/ecs-deploy

# build the new image and push to the destination repository
eval $(aws ecr get-login --region us-east-1)
docker build -t haoliangyu/ecs-auto-deploy .
docker tag haoliangyu/ecs-auto-deploy:latest $IMAGE_REPO_URL:latest
docker push $IMAGE_REPO_URL:latest

# deploy the new image to the aws ecs
ecs-deploy -c $CLUSTER_NAME -n $SERVICE_NAME -i $IMAGE_REPO_URL:latest
```

In the Travice CI configuration, the `docker` service is required for the deployment bash script. In the `deploy` section, it use the script deployment and execut the `deploy.sh` script when the master branch is updated. In such setting, every time a PR to master is merged, the AWS ECS deployment will be automatically triggered.

``` yaml
sudo: required
language: node_js
node_js:
  - "node"
services:
  - docker
deploy:
  provider: script
  script: bash deploy.sh
  on:
    branch: master
```
