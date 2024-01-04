#!/bin/bash

# Install docker 
sudo apt update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker > docker_status.log 2>&1
# sudo usermod -aG docker ${USER}

#Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

#run airflow image in docker
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.8.0/docker-compose.yaml'
mkdir -p workflow/dags workflow/logs workflow/plugins workflow/config
echo -e "AIRFLOW_UID=$(id -u)" > .env
sudo docker compose up airflow-init
sudo docker compose up
sudo docker compose -f docker_compose_pg.yml up
