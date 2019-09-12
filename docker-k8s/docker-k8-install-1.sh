

############################ Step-1 installing Docker on Ubuntu (On Master and Nodes) ###########################

# Add docker repository GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


# Add the docker repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Reload the apt resources list
sudo apt-get update

# Install packages
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

# Prevent auto updates for docker packages
sudo apt-mark hold docker-ce
sudo docker version


########################### Step-2 Installing Kubeadm, Kubelet, and Kubectl (On Master and Nodes) ###########################

# Add kubernetes repository GPG Key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add the kubernetes repository
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

#Reload the apt resources list
sudo apt-get update

# Install packages
sudo apt-get install -y kubelet=1.12.7-00 kubeadm=1.12.7-00 kubectl=1.12.7-00

# Prevent auto updates for kube packages
sudo apt-mark hold kubelet kubeadm kubectl

#NOTE: There are some issues being reported when installing version 1.12.2-00 from the Kubernetes ubuntu repositories. 
# You can work around this by using version 1.12.7-00 for kubelet, kubeadm, and kubectl.

kubeadm version

############################ Step -3 bootstrap the cluster ###########################
#we will bootstrap the cluster on the Kube master node.
# Then, we will join each of the two worker nodes to the cluster, forming an actual multi-node Kubernetes cluster.

#initialize the cluster (on master)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16


#set up the local kubeconfig (on master)

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#Verify that the cluster is responsive and that Kubectl is working
kubectl version


############################ Step-4 Cluster joining (on nodes)###########################

sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


############################ Step-5 Install Flannel in the cluster (only on the Master node) ############################
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

######################## Verify that all the nodes now have a STATUS of Ready (on the Master node) #######################
kubectl get nodes

#######################  verify that the Flannel pods are up and running (on the Master node)######################
kubectl get pods -n kube-system

kubeadm join 192.168.1.9:6443 --token qnyyj0.jk1pg11tgt0xnak3 --discovery-token-ca-cert-hash sha256:a1834b756e98b3ee6d5c1d60c2a4803783f5cf203d7f9a3800c62f306804e694
