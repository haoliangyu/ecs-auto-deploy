eval $(aws ecr get-login --region eu-west-1)
docker build .
docker tag haoliangyu/ecs-auto-deploy:latest $ECS_REPO_URI
docker push $ECS_REPO_URI
