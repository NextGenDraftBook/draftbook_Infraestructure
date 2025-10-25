#!/bin/bash
 
echo '========================================================'
echo '=== PASO 1: INSTALACIÓN DE PREREQUISITOS PARA DOCKER ==='
echo '========================================================'
sudo apt-get update
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
unzip \
gnupg-agent \
software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
 
echo '=============================================================='
echo '=== PASO 2: AGREGAR REPOSITORIO PARA LA INSTALACIÓN DOCKER ==='
echo '=============================================================='
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
 
echo '====================================='
echo '=== PASO 3: INSTALACIÓN DE DOCKER ==='
echo '====================================='
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# Iniciar Docker junto con el Arranque del Sistema Operativo
sudo systemctl enable docker
# Agregar Usuario Actual al Grupo de Docker
sudo usermod -aG docker ubuntu
 
echo '============================================='
echo '=== PASO 4: INSTALACIÓN DE DOCKER-COMPOSE ==='
echo '============================================='
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
 
echo '==============================================================='
echo '=== PASO 5: INICIAR DOCKER AL ARRANCAR EL SISTEMA OPERATIVO ==='
echo '==============================================================='
sudo systemctl enable docker
 
echo'========================================================='
echo'=== PASO 6: AGREGAR USUARIO ACTUAL AL GRUPO DE DOCKER ==='
echo'========================================================='
sudo usermod -aG docker ubuntu
 
echo '========================================='
echo '=== PASO 7: INSTALAR HERRAMIENTA CTOP ==='
echo '========================================='
echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
sudo apt update
sudo apt install docker-ctop

echo '========================================='
echo '=== PASO 8: INSTALAR CLI AWS ==='
echo '========================================='
if ! command -v aws >/dev/null 2>&1; then 
    sudo apt-get update -y && sudo apt-get install -y unzip curl jq 
    curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip 
    unzip -q awscliv2.zip 
    sudo ./aws/install 
    rm -rf awscliv2.zip aws
fi
aws --version

echo '========================================='
echo '=== PASO 9: CREAR DIRECTORIOS ==='
echo '========================================='
sudo mkdir -p /containers
sudo mkdir -p /home/ubuntu/.aws
touch /containers/.env
sudo chmod 777 /containers
sudo chmod 777 /containers/.env

echo '========================================='
echo '=== PASO 10: CONFIGURAR AWS CLI ==='
echo '========================================='
sudo echo "[default]
region=us-east-2
output=json" | sudo tee /home/ubuntu/.aws/config >/dev/null
sudo chown -R ubuntu:ubuntu /home/ubuntu/.aws
sudo chmod 700 /home/ubuntu/.aws
sudo chmod 600 /home/ubuntu/.aws/config

echo '========================================='
echo '=== SETUP COMPLETADO ==='
echo '========================================='
echo "Instalación finalizada en: $(date)"