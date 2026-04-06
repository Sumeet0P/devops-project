# 🚀 Cloud-Native GitOps Deployment Platform

<div align="center">

![CI/CD](https://github.com/Sumeet0P/devops-project/actions/workflows/ci.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Terraform](https://img.shields.io/badge/Terraform-v1.0+-7B42BC?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-k3s-326CE5?logo=kubernetes)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)

**A production-grade GitOps pipeline for deploying a full-stack application on AWS using Terraform, Kubernetes, Helm, and ArgoCD.**

</div>

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [CI/CD Pipeline](#-cicd-pipeline)
- [GitOps Workflow](#-gitops-workflow)
- [Application Endpoints](#-application-endpoints)
- [Monitoring & Troubleshooting](#-monitoring--troubleshooting)
- [Key Learnings](#-key-learnings)
- [Cleanup](#-cleanup)

---

## 🌐 Overview

This project demonstrates a **complete, end-to-end DevOps workflow** — from provisioning cloud infrastructure to automated application deployment using GitOps principles.

A full-stack application (Python FastAPI backend + Node.js Express frontend) is automatically deployed to a Kubernetes cluster on AWS whenever code is pushed to the main branch. No manual deployment steps required.

**What makes this production-realistic:**
- Infrastructure is fully codified with Terraform (no clicking in AWS console)
- Kubernetes manages containers with auto-scaling and self-healing
- ArgoCD continuously reconciles cluster state with Git — Git is the single source of truth
- GitHub Actions handles CI: builds, tests, and pushes images automatically
- Traefik handles ingress and public routing
- HPA (Horizontal Pod Autoscaler) scales frontend based on CPU load

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Developer                            │
│                    git push → main                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   GitHub Actions (CI)                       │
│  1. Checkout code                                           │
│  2. Build Docker images (backend + frontend)                │
│  3. Push to Docker Hub with SHA tag                         │
│  4. Update image tags in Helm values.yaml                   │
└─────────────────────┬───────────────────────────────────────┘
                      │  (Git commit: updated image tags)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD (GitOps CD)                       │
│  Watches repo → detects change → syncs Helm charts         │
│  to k3s cluster automatically                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              AWS EC2 — k3s Kubernetes Cluster               │
│                                                             │
│   ┌─────────────────┐      ┌──────────────────────────┐    │
│   │  Backend Pods   │      │     Frontend Pods (HPA)  │    │
│   │  FastAPI :8000  │◄─────│  Express.js :3000        │    │
│   └─────────────────┘      └──────────────┬───────────┘    │
│                                           │                 │
│                              ┌────────────▼──────────┐      │
│                              │  Traefik Ingress      │      │
│                              │  (Public HTTP :80)    │      │
│                              └───────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                      ▲
                      │  Provisioned by
┌─────────────────────────────────────────────────────────────┐
│                   Terraform (IaC)                           │
│  - EC2 instance (t2.micro)                                  │
│  - Security groups (ports 22, 80, 443, 6443)                │
│  - k3s install + ArgoCD setup via user_data script          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Category | Tool | Purpose |
|---|---|---|
| Cloud | AWS EC2 | Compute infrastructure |
| IaC | Terraform | Provision AWS resources |
| Containers | Docker | Package applications |
| Orchestration | Kubernetes (k3s) | Container management |
| Packaging | Helm | Kubernetes app templating |
| GitOps | ArgoCD | Continuous deployment |
| CI | GitHub Actions | Build & push images |
| Ingress | Traefik | HTTP routing |
| Backend | Python FastAPI | REST API |
| Frontend | Node.js + Express | Web frontend |

---

## 📁 Project Structure

```
devops-project/
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI pipeline
├── argocd/
│   ├── backend-app.yaml        # ArgoCD Application for backend
│   └── frontend-app.yaml       # ArgoCD Application for frontend
├── backend/
│   ├── app/
│   │   └── main.py             # FastAPI application
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── Dockerfile
│   ├── server.js               # Express.js server
│   └── package.json
├── helm/
│   ├── backend/                # Helm chart for backend
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   └── frontend/               # Helm chart for frontend
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── hpa.yaml        # Horizontal Pod Autoscaler
│           └── pdb.yaml        # Pod Disruption Budget
└── terraform/
    ├── main.tf                 # EC2 instance + security group
    ├── provider.tf             # AWS provider config
    ├── variables.tf
    └── outputs.tf
```

---

## 🚀 Getting Started

### Prerequisites

- AWS account with CLI configured (`aws configure`)
- Terraform v1.0+ installed
- Docker installed and running
- Docker Hub account
- SSH key pair named `devops-k3s-key` in your AWS account

### Step 1 — Build & Push Docker Images

```bash
# Backend
cd backend
docker build -t <your-dockerhub>/py-backend:latest .
docker push <your-dockerhub>/py-backend:latest

# Frontend
cd ../frontend
docker build -t <your-dockerhub>/py-frontend:latest .
docker push <your-dockerhub>/py-frontend:latest
```

> Update image repos in `helm/backend/values.yaml` and `helm/frontend/values.yaml`

### Step 2 — Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform will:
- Create an EC2 instance with the correct security groups
- Install k3s (lightweight Kubernetes)
- Install and configure ArgoCD
- Clone this repo and register ArgoCD applications

### Step 3 — Access the Application

```bash
# Get the server IP
terraform output server_ip

# Visit in browser
http://<server-ip>
```

---

## ⚙️ CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push to `main`:

```
Push to main
    │
    ▼
Build backend image → Push to Docker Hub (tagged with git SHA)
    │
    ▼
Build frontend image → Push to Docker Hub (tagged with git SHA)
    │
    ▼
Update image tags in helm/*/values.yaml
    │
    ▼
Commit updated values → triggers ArgoCD sync
```

This ensures every deployment is traceable to an exact Git commit.

---

## 🔄 GitOps Workflow

ArgoCD continuously monitors this repository. When a change is detected in the Helm charts:

1. ArgoCD compares desired state (Git) with actual state (cluster)
2. Detects drift → automatically applies the new manifests
3. Rollout happens with zero downtime (rolling update strategy)

To manually trigger a sync:
```bash
argocd app sync backend
argocd app sync frontend
```

To check sync status:
```bash
argocd app list
argocd app get backend
```

---

## 🌐 Application Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | Frontend home page |
| `/api/message` | GET | Returns configurable message from backend |
| `/health` | GET | Backend health check |
| `/ready` | GET | Backend readiness check |

---

## 📊 Monitoring & Troubleshooting

### Check ArgoCD Dashboard
```bash
# Get admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d

# Port-forward dashboard
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
```

### Check Cluster Status
```bash
kubectl get pods                        # All pods
kubectl get pods -n argocd              # ArgoCD pods
kubectl get hpa                         # Autoscaler status
kubectl logs -l app=backend --tail=50   # Backend logs
kubectl logs -l app=frontend --tail=50  # Frontend logs
kubectl describe pod <pod-name>         # Detailed pod info
```

### Common Issues

| Issue | Likely Cause | Fix |
|---|---|---|
| Pods in `ImagePullBackOff` | Image not found in registry | Check image tag in `values.yaml` |
| ArgoCD out of sync | Git changes not detected | Run `argocd app sync <app>` |
| Application unreachable | Ingress misconfigured | Check `kubectl get ingress` |
| EC2 unreachable | Security group rules | Verify ports 80, 443 are open |

---

## 💡 Key Learnings

Building this project taught me:

- **IaC discipline** — never touching the AWS console for infra changes; everything reproducible
- **GitOps mindset** — Git as the single source of truth; the cluster always reflects what's in the repo
- **Kubernetes primitives** — how Deployments, Services, Ingress, ConfigMaps, HPA, and PDB work together
- **Helm templating** — writing reusable charts vs hardcoding manifests
- **CI/CD image tagging strategy** — using git SHA tags for full deployment traceability
- **Debugging production** — reading logs, describing pods, understanding Kubernetes events

---

## 🧹 Cleanup

To destroy all AWS resources and avoid charges:

```bash
cd terraform
terraform destroy
```

---

## 📄 License

MIT — see [LICENSE](LICENSE)

---

<div align="center">
Made by <a href="https://github.com/Sumeet0P">Sumeet Chauhan</a> · 
<a href="https://linkedin.com/in/sumeetchauhan37">LinkedIn</a>
</div>