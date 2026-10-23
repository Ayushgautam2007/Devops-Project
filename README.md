# DevOps Capstone: Flask CI/CD on AWS

## 1. Project Overview

This project demonstrates a CI/CD workflow for a Dockerized Flask API
using Jenkins, GitHub, Amazon ECR, and a remote Docker host.

Terraform configuration and Kubernetes manifests are maintained for
the planned AWS EKS deployment.

## 2. Architecture

Developer
  -> GitHub repository (main)
  -> GitHub push webhook
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

GitHub push webhook delivery and automatic execution of the production
`Testing` pipeline have been verified end to end. Build `44` was triggered
by a GitHub push and completed successfully, including deployment and
post-deployment validation.

Ansible playbooks and the dedicated Jenkins Ansible-Health-Check job have
been validated against the Docker application server. The production pipeline
also runs `docker_health.yml` after deployment. The EKS cluster is currently
absent. Prometheus, Grafana, and Node Exporter are configured on the Jenkins
host; alert-notification delivery still requires validation.

## 5. Repository Structure

- `app/app.py` - Flask application
- `app/requirements.txt` - Python dependencies
- `tests/test_app.py` - Application tests
- `Dockerfile` - Container image definition
- `k8s/deployment.yaml` - Kubernetes Namespace and Deployment
- `k8s/service.yaml` - Kubernetes Service
- `k8s/ingress.yaml` - AWS ALB Ingress configuration

Terraform configuration is maintained locally on the Jenkins controller,
outside this Git repository. See Section 11 for its location.

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

Images use Jenkins build numbers as tags. Build `44` is the latest
verified production deployment and was confirmed healthy after deployment.

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

Terraform configuration is stored locally on the Jenkins controller,
outside this GitHub repository:

    /var/lib/jenkins/terraform-eks-capstone

The directory contains configuration files for the VPC, networking,
EKS cluster, managed node group, and outputs. It also contains local
Terraform working data and saved plan files; do not commit those files
without reviewing their contents for sensitive information.

The EKS cluster is currently absent. Do not apply the configuration
without reviewing the plan and confirming the expected AWS costs.
NAT Gateways, load balancers, EC2 instances, and EKS can incur charges.
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

Latest verified production deployment build: `44`

Build `44` evidence:
- Trigger: GitHub push (`GitHubPushCause`).
- Git branch: `main`.
- Git commit: `3192b99578ca934b57618a304994f871a8fe3788`.
- ECR image: `devops-flask-api:44`.
- Pipeline result: `SUCCESS`.
- Candidate and production `/health` checks returned
  `{"status":"healthy"}`.
- The previous production container was preserved as
  `flask-api-rollback-44`.
- Ansible post-deployment validation passed.

Build `27` is retained below as historical validation evidence.

Webhook validation:
- GitHub `push` delivery returned HTTP `200`.
- `Webhook-Test` started automatically with `Started by GitHub push`.
- Repository checkout succeeded at commit `7192332285ccdef34859ce2fad7704c128b3c369`.
- This records the earlier safe `Webhook-Test` verification, which did
  not build an image, push to ECR, or deploy to production.
- Production webhook verification was subsequently confirmed by Build `44`,
  which was started by a GitHub push and completed successfully.

Application tests:
- `tests/test_app.py`: 3 passed (`test_home`, `test_health`, `test_users`).
- Test command: `.venv/bin/python -m pytest -v tests/test_app.py`.

Evidence from that pipeline run:
- Git branch: `main`
- Git commit: `2ccfeb71d9f77724cddadee0886ebb57a2ab5ba7`
- ECR image: `devops-flask-api:27`
- Pipeline result: `SUCCESS`
- Production `/health`: `{"status":"healthy"}`
- Previous production image `:26` was preserved as a rollback container.

Ansible validation:
- Tracked playbooks: `system_info.yml`, `docker_health.yml`, and `disk_check.yml`.
- Inventory: `ansible/inventory/hosts.ini`; configuration: `ansible/ansible.cfg`.
- All three playbooks passed syntax checks.
- Jenkins job `Ansible-Health-Check` completed with `SUCCESS`.
- Remote Docker service was `active`; Flask `/health` returned
  `{"status":"healthy"}`.
- Health-check recap: `ok=6`, `changed=0`, `unreachable=0`, `failed=0`.
- Disk check passed with root filesystem usage below the 80% threshold.
- Ansible commit: `9d210a0` (`feat(ansible): add server health and disk validation playbooks`).
- The production pipeline runs `docker_health.yml` after deployment.
  `system_info.yml` and `disk_check.yml` have been validated through the
  dedicated Ansible health-check workflow; do not assume they run in every
  production deployment.

Latest previously verified documentation/manifests commit in GitHub: `7192332`
- Added `k8s/deployment.yaml`, `k8s/service.yaml`, and `k8s/ingress.yaml`.
- All three files passed local YAML syntax validation.
- Live Kubernetes API/schema validation and EKS deployment have not
  been verified because the EKS cluster is currently absent.
- Automated rollback testing remains pending.

## 14. Remaining Work

- Recreate and validate EKS when budget permits, then deploy the
  Kubernetes manifests and verify the ALB endpoint.
- Decide whether `system_info.yml` and `disk_check.yml` should also run
  automatically in the production pipeline.
- Validate alert-notification delivery from the monitoring setup.
- Validate automated rollback in a controlled test.
- Capture any remaining architecture, pipeline, and monitoring evidence.

## 15. Cost Management

Stop or destroy lab resources that are not needed.
Review NAT Gateways, load balancers, EKS node groups, EC2 instances,
EBS volumes, Elastic IPs, and CloudWatch log groups before cleanup.

Preserve required Terraform state and project artifacts.


Done
