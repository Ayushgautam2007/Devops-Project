# DevOps Capstone: Flask CI/CD on AWS

## 1. Project Overview

This project demonstrates a CI/CD workflow for a Dockerized Flask API
using Jenkins, GitHub, Amazon ECR, and a remote Docker host.

Terraform configuration and Kubernetes manifests are maintained for
the planned AWS EKS deployment.

## 2. Architecture

Developer
  -> GitHub repository (main)
  -> Jenkins pipeline
  -> Automated pytest tests
  -> Docker image build
  -> Amazon ECR image push
  -> Remote Docker deployment
  -> Candidate health check
  -> Production health check
  -> Deployment audit log

Planned extension:
Terraform VPC/EKS -> Kubernetes Deployment and Service
-> AWS Load Balancer Controller / ALB
-> Prometheus/Grafana monitoring and notifications

## 3. Application Endpoints

- `/` - Application welcome message
- `/health` - Application health check
- `/api/users` - User API

## 4. Technology Stack

- Python and Flask
- Gunicorn
- pytest
- Docker
- Git and GitHub
- Jenkins
- Amazon ECR
- AWS EC2
- Terraform
- Kubernetes YAML manifests

Ansible, EKS deployment, Prometheus/Grafana, and notifications remain
pending validation in the current environment.

## 5. Repository Structure

- `app/app.py` - Flask application
- `app/requirements.txt` - Python dependencies
- `tests/test_app.py` - Application tests
- `Dockerfile` - Container image definition
- `k8s/deployment.yaml` - Kubernetes Namespace and Deployment
- `k8s/service.yaml` - Kubernetes Service
- `k8s/ingress.yaml` - AWS ALB Ingress configuration
- `provider.tf`, `versions.tf`, `variables.tf` - Terraform setup
- `network.tf` - VPC and networking resources
- `eks.tf` - EKS cluster and node group resources
- `outputs.tf` - Terraform outputs

## 6. Local Development

Install dependencies:

    python -m pip install -r app/requirements.txt

Run tests from the repository root:

    python -m pytest -v tests/

## 7. Docker

Build the image:

    docker build -t flask-api:v1 .

Run the container locally:

    docker run -d --name flask-api \
      -p 127.0.0.1:9090:8080 flask-api:v1

Check application health:

    curl -fsS http://127.0.0.1:9090/health

## 8. Jenkins CI/CD

Jenkins job: `Testing`

Current pipeline stages:

1. Checkout the GitHub `main` branch
2. Install test dependencies
3. Run pytest
4. Build a Docker image
5. Push the image to Amazon ECR
6. Start a candidate container on the remote Docker host
7. Check candidate health
8. Swap the production container
9. Verify production health
10. Print deployment audit information

The pipeline records the build number, Git branch, commit SHA,
image tag, and build result.

The production swap can cause brief downtime; it is not true
zero-downtime deployment.

## 9. Amazon ECR

AWS region: `ap-south-1`

ECR repository:

    351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api

Images use Jenkins build numbers as tags. Build `27` was verified
as deployed and healthy during project validation.

## 10. Kubernetes

Manifest directory:

    k8s/

Files:

- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`

The Deployment specifies two replicas, non-root execution,
resource requests and limits, and readiness/liveness probes.

The deployment manifest currently references image tag `27`.
For future deployments, update the image tag from the pipeline or
use a deployment step that injects the current immutable build tag.

The EKS cluster is currently absent to avoid ongoing AWS costs.
These manifests have not been verified against a currently running
cluster in the present environment.

## 11. Terraform

Terraform files define the project VPC, subnets, EKS cluster,
managed node group, and outputs.

Working directory on the Jenkins controller:

    /var/lib/jenkins/terraform-eks-capstone

Review and validate the Terraform plan before applying any changes.
Creating EKS, NAT Gateway, load balancers, and EC2 resources can incur
AWS charges.

Do not apply or destroy infrastructure without reviewing the plan.

## 12. Security Notes

- The application container runs as a non-root user.
- Kubernetes configuration disables privilege escalation and drops
  Linux capabilities.
- Do not commit AWS credentials, SSH private keys, or secrets.
- Restrict Jenkins and SSH access using security groups and approved
  source IP ranges.
- Review IAM permissions using least privilege.

## 13. Validation Evidence

Latest verified Jenkins build: `27`

- Git branch: `main`
- Git commit: `2ccfeb71d9f77724cddadee0886ebb57a2ab5ba7`
- ECR image: `devops-flask-api:27`
- Pipeline result: `SUCCESS`
- Production `/health`: `{"status":"healthy"}`
- Previous production image `:26` was preserved as a rollback container.

## 14. Remaining Work

- Recreate and validate EKS when budget permits.
- Deploy Kubernetes manifests and verify the ALB endpoint.
- Integrate Ansible into configuration management.
- Configure Prometheus/Grafana and alert notifications.
- Validate automated rollback in a controlled test.
- Add CI/CD trigger on GitHub changes.
- Capture final architecture, pipeline, and monitoring evidence.

## 15. Cost Management

Stop or destroy lab resources that are not needed.
Review NAT Gateways, load balancers, EKS node groups, EC2 instances,
EBS volumes, Elastic IPs, and CloudWatch log groups before cleanup.

Preserve required Terraform state and project artifacts.
