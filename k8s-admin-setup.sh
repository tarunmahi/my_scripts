set -e 
sudo apt-get update -y
#install docker 
echo "installing docker"
sudo apt-get install docker.io -y
sudo apt-get install git -y
sudo systemctl start docker 
sudo usermod -aG docker $USER

echo "installing kubernetes"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "all the processess have been done"
kubeadm version 
echo "Do you want to initialize the Kubernetes cluster? (yes/no)"
read init_choice
if [[ "$init_choice" == "yes" ]]; then
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tee kubeadm-init.log

    echo "Setting up kubeconfig for current user..."
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    echo "Installing Calico CNI for networking..."
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
fi

echo "Installation complete. Reboot recommended."
