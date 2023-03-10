echo "\n\n===============================\n"
echo "=== INSTALL DIFFERENT TOOLS ===\n"
echo "===============================\n\n"

echo "\n>> UPDATE / UPGRADE\n"
sudo apt update
sudo apt upgrade -y

echo "\n>> INSTALL MAKE\n"
sudo apt install make -y

echo "\n>> INSTALL CURL\n"
sudo apt install curl -y

echo "\n>> INSTALL VIM\n"
sudo apt install vim -y

echo "\n>> INSTALL XSEL\n"
sudo apt install xsel -y

echo "\n>> INSTALL GH\n"
sudo apt install gh -y

echo "\n>> INSTALL VIRTUALBOX\n"
sudo apt install virtualbox -y
sudo virtualbox --version

echo "\n>> INSTALL VAGRANT\n"
sudo wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo chmod +x vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb
sudo rm vagrant_2.2.19_x86_64.deb
sudo vagrant --version

echo "\n>> INSTALL DOCKER\n"
sudo apt install docker.io -y
sudo docker --version

echo "\n>> INSTALL KUBECTL\n"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "\n>> INSTALL K3D\n"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "\n>> INSTALL ARGO-CD\n"
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
argocd version

echo "\n>> INSTALL HELM\n"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo rm get_helm.sh

echo "\n>> ADD HOST IN /ETC/HOSTS\n"
echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts
echo "192.168.56.112 gitlab.local" | sudo tee -a /etc/hosts
