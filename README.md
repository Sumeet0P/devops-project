# DevOps Project

A complete DevOps pipeline for deploying a full-stack web application using Infrastructure as Code (Terraform), containerization (Docker), Kubernetes (k3s), and GitOps (ArgoCD).

## Project Overview

This project demonstrates a modern DevOps workflow by deploying a simple full-stack application consisting of:

- **Backend**: Python FastAPI application serving API endpoints
- **Frontend**: Node.js Express application that consumes the backend API
- **Infrastructure**: AWS EC2 instance with k3s (lightweight Kubernetes)
- **Deployment**: Helm charts for application packaging
- **GitOps**: ArgoCD for continuous deployment from GitHub

## Architecture

```
GitHub Repository
    ↓ (ArgoCD syncs)
Helm Charts (backend/frontend)
    ↓ (deployed to)
k3s Cluster on EC2
    ├── Backend Service (FastAPI)
    └── Frontend Service (Express.js) → Ingress (Traefik)
```

## Prerequisites

Before deploying this project, ensure you have:

- **AWS Account** with appropriate permissions to create EC2 instances and security groups
- **AWS CLI** configured with your credentials
- **Terraform** (v1.0+) installed
- **Docker** installed and running
- **Docker Hub** account (or another container registry)
- **Git** for cloning repositories
- **kubectl** (optional, for manual cluster access)

## Quick Start

### 1. Build and Push Docker Images

First, build the backend and frontend Docker images and push them to your container registry.

#### Backend Image
```bash
cd backend
docker build -t your-registry/py-backend:latest .
docker push your-registry/py-backend:latest
```

#### Frontend Image
```bash
cd frontend
docker build -t your-registry/py-frontend:latest .
docker push your-registry/py-frontend:latest
```

**Note**: Update the image repositories in `helm/backend/values.yaml` and `helm/frontend/values.yaml` to match your registry.

### 2. Configure Terraform

Update the Terraform configuration if needed:

- In `terraform/provider.tf`, change the AWS region if desired
- Ensure you have an SSH key pair named `devops-k3s-key` in your AWS account (or update the key_name in `main.tf`)

### 3. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will:
- Create an EC2 instance with security group
- Install k3s (Kubernetes)
- Install ArgoCD
- Clone your repository
- Register ArgoCD applications

### 4. Access Your Application

After Terraform completes, get the public IP of your server:

```bash
terraform output server_ip
```

Visit `http://<server-ip>` in your browser to access the frontend application.

## Application Details

### Backend API

The backend provides the following endpoints:

- `GET /` - Status check
- `GET /health` - Health check
- `GET /ready` - Readiness check
- `GET /api/message` - Returns a configurable message

### Frontend

The frontend displays a simple web page that fetches and displays the message from the backend API.

## Configuration

### Environment Variables

#### Backend
- `APP_MESSAGE` - Custom message returned by the API (default: "Hi Sumeet This Side!! 🚀")

#### Frontend
- `BACKEND_URL` - URL of the backend service (default: "http://localhost:8000")

### Scaling

The frontend deployment includes:
- **Horizontal Pod Autoscaler (HPA)**: Scales between 2-6 replicas based on CPU utilization (50%)
- **Pod Disruption Budget (PDB)**: Ensures at least 1 pod remains available during disruptions

## Development

### Local Development

To run the application locally:

#### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

#### Frontend
```bash
cd frontend
npm install
node server.js
```

Visit `http://localhost:3000` for the frontend (backend should be running on port 8000).

### Making Changes

1. Modify the application code
2. Build and push new Docker images with updated tags
3. Update the image tags in the respective `values.yaml` files
4. Commit and push changes to GitHub
5. ArgoCD will automatically sync the changes to the cluster

## Monitoring and Troubleshooting

### Access ArgoCD

To access the ArgoCD dashboard:

```bash
# Get ArgoCD admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

Port forward ArgoCD server:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Visit `https://localhost:8080` and login with username `admin` and the password above.

### Check Application Status

```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# View logs
kubectl logs -l app=backend
kubectl logs -l app=frontend
```

### Common Issues

1. **Images not pulling**: Ensure your container registry is accessible and credentials are configured
2. **Application not accessible**: Check ingress configuration and security group rules
3. **ArgoCD sync failures**: Verify GitHub repository access and Helm chart validity

## Cleanup

To destroy the infrastructure:

```bash
cd terraform
terraform destroy
```

This will terminate the EC2 instance and remove all associated resources.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).
