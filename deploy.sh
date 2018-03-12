eval $(aws ecr get-login --region us-east-1)
docker build -t haoliangyu/ecs-auto-deploy .
docker tag haoliangyu/ecs-auto-deploy:latest $ECS_REPO_URI:latest
docker push $ECS_REPO_URI:latest
