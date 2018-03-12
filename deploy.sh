eval $(aws ecr get-login --region us-east-1)
docker build -t $ECS_REPO_URI .
docker push $ECS_REPO_URI
