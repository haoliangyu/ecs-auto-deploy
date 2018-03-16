pip install --user awscli
export PATH=$PATH:$HOME/.local/bin

add-apt-repository ppa:eugenesan/ppa
apt-get update
apt-get install jq -y

curl https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy | sudo tee -a /usr/bin/ecs-deploy
sudo chmod +x /usr/bin/ecs-deploy

eval $(aws ecr get-login --region us-east-1)
docker build -t haoliangyu/ecs-auto-deploy .
docker tag haoliangyu/ecs-auto-deploy:latest $ECS_REPO_URI:latest
docker push $ECS_REPO_URI:latest

ecs-deploy -c $CLUSTER_NAME -n $SERVICE_NAME -i $ECS_REPO_URI:latest
