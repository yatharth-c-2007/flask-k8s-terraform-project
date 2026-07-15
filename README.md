# Flask App on Local Kubernetes via Terraform

A beginner DevOps project demonstrating a full containerized deployment
pipeline: a Python Flask app, containerized with Docker, deployed to a
local Kubernetes cluster (Minikube), with the deployment itself managed
declaratively using Terraform.

## Architecture

Flask App (Python) 
    → Dockerfile (containerization)
    → Docker Image
    → Minikube (local Kubernetes cluster)
    → Terraform (Kubernetes provider)
        → Deployment (2 replicas, self-healing)
        → Service (NodePort, stable network access)
    → GitHub Actions (self-hosted runner)
        → Automated build, deploy, and rollout on every push
    → Prometheus + Grafana (via Helm, kube-prometheus-stack)
        → Cluster and application metrics, visualized in dashboards

## What this demonstrates

- Writing a simple Python web app with health-check endpoints
- Containerizing an application with Docker
- Running a local Kubernetes cluster with Minikube
- Managing Kubernetes resources (Deployments, Services) as code using
  Terraform instead of manual kubectl commands
- Debugging real infrastructure issues (image caching, cluster
  connectivity, resource scheduling)

## Stack

- **Python 3** / **Flask** — application layer
- **Docker** — containerization
- **Kubernetes (Minikube)** — container orchestration
- **Terraform** — infrastructure as code
- **GitHub Actions** (self-hosted runner) — CI/CD automation
- **Helm** — package manager for Kubernetes
- **Prometheus** — metrics collection
- **Grafana** — metrics visualization / dashboards

## Project Structure

.
├── app.py                          # Flask application
├── requirements.txt                 # Python dependencies
├── Dockerfile                       # Container build instructions
├── terraform/
│   ├── main.tf                      # Kubernetes provider, Deployment, Service
│   └── .terraform.lock.hcl          # Provider version lock
└── README.md

## How to run this yourself

### Prerequisites
- Docker
- kubectl
- Minikube
- Terraform

### Steps

1. Start the local cluster
   minikube start

2. Build the Docker image
   docker build -t flask-k8s-app:v1 .

3. Load the image into Minikube
   (Minikube runs its own internal Docker environment, separate from
   the host machine, so images must be explicitly loaded)
   minikube image load flask-k8s-app:v1

4. Deploy with Terraform
   cd terraform
   terraform init
   terraform apply

5. Access the app
   curl $(minikube service flask-app-service --url)
   curl $(minikube service flask-app-service --url)/health

## Endpoints

| Route     | Description                          |
|-----------|---------------------------------------|
| /         | Returns a hello-world style message   |
| /health   | Returns {"status": "healthy"}, used as a health check for orchestration |

## Notes / Lessons Learned

- image_pull_policy: Never requires the image to be manually reloaded
  into Minikube (minikube image load) after every Minikube restart —
  otherwise pods fail with ErrImageNeverPull.
- Terraform's .terraform.lock.hcl should be committed to version
  control (it pins exact provider versions); the .terraform/ plugin
  folder itself should not be.

## Status

Core pipeline complete and verified working end-to-end. CI/CD implemented
via GitHub Actions with a self-hosted runner — every push to `main`
automatically rebuilds the image, reloads it into Minikube, re-applies
Terraform, and restarts the deployment. Monitoring added via Prometheus
and Grafana (installed with Helm's kube-prometheus-stack chart),
providing live cluster and application metrics dashboards.

## Monitoring

Prometheus and Grafana are installed via Helm into a dedicated `monitoring`
namespace.

Access Grafana locally:
\`\`\`bash
export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" -o name)
kubectl --namespace monitoring port-forward $POD_NAME 3000:3000
\`\`\`
Then visit http://localhost:3000 (default login: admin / admin123).

Pre-built dashboards under "Dashboards" show live cluster and namespace-level
CPU/memory usage, including the Flask app's pods.
