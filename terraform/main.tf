resource "aws_security_group" "devops_sg" {
  name = "devops-project-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_server" {

  ami           = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.small"

  key_name = "devops-k3s-key"

  security_groups = [
    aws_security_group.devops_sg.name
  ]

user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y curl

# install k3s
curl -sfL https://get.k3s.io | sh -

sleep 30

# configure kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo 'export KUBECONFIG=$HOME/.kube/config' >> /home/ubuntu/.bashrc

# install ArgoCD
kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# wait for kubernetes API
until kubectl get nodes >/dev/null 2>&1; do
  echo "Waiting for Kubernetes..."
  sleep 5
done

# install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# clone project repo
git clone https://github.com/Sumeet0P/devops-project.git /home/ubuntu/devops-project

cd /home/ubuntu/devops-project

# deploy backend
helm install backend ./helm/backend

# deploy frontend
helm install frontend ./helm/frontend

EOF

  tags = {
    Name = "devops-k3s-server"
  }
}
