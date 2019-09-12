######################### Containers and Pods ########################

#Create a simple pod running an nginx container

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
EOF



# Get a list of pods and verify that your new nginx pod is in the Running state:

kubectl get pods

#Get more information about your nginx pod
kubectl describe pod nginx

#Delete the pod:
kubectl delete pod nginx


########################  Clustering and Nodes #########################
# Get a list of nodes:
kubectl get nodes

#Get more information about a specific node:
kubectl describe node $node_name


########################  Networking in Kubernetes ########################

#Create a deployment with two nginx pods:

cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.4
        ports:
        - containerPort: 80
EOF

# Create a busybox pod to use for testing:
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    args:
    - sleep
    - "1000"
EOF
# Get the IP addresses of your pods:
kubectl get pods -o wide

# Get the IP address of one of the nginx pods, then contact that nginx pod from the busybox pod using the nginx pod's IP address:
kubectl exec busybox -- curl $nginx_pod_ip



#################### Kubernetes Deployments #########################
# Create a deployment
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.4
        ports:
        - containerPort: 80
EOF

# Get a list of deployments:
kubectl get deployments

# Get more information about a deployment:
kubectl describe deployment nginx-deployment

# Get a list of pods:
kubectl get pods


####################  Kubernetes Services ####################
#While deployments provide a great way to automate the management of your pods, you need a way to easily communicate with the dynamic set of replicas managed by a deployment. This is where services come in.

# Create a NodePort service on top of your nginx pods:
cat << EOF | kubectl create -f -
kind: Service
apiVersion: v1
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

# Get a list of services in the cluster.
kubectl get svc

#Since this is a NodePort service, you should be able to access it using port 30080 on any of your cluster's servers. You can test this with the command:
curl localhost:30080

