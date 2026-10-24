# DevOps Capstone: Flask CI/CD on AWS

## 1. Project Overview

This project demonstrates a Flask API CI/CD workflow using Jenkins,
GitHub, Amazon ECR, Docker, and a remote Docker host. It also includes
Terraform configuration, Kubernetes manifests, Ansible validation, and
Prometheus/Grafana monitoring work.

The EKS deployment and internet-facing AWS Application Load Balancer
were provisioned and tested successfully on 2026-10-24. The public API
endpoints and both ALB targets returned healthy results. The ALB and
application namespace were subsequently removed to reduce lab costs;
Terraform-managed EKS infrastructure cleanup remains to be completed.

## 2. Architecture

Validated Docker CI/CD flow:

Developer
  -> GitHub repository (main)
  -> GitHub push webhook
  -> Jenkins pipeline
  -> Automated pytest tests
  -> Docker image build
  -> Amazon ECR image push
  -> Remote Docker deployment
  -> Candidate and production health checks
  -> Deployment audit log
  -> Ansible post-deployment validation

Validated Kubernetes deployment flow (2026-10-24):

Terraform VPC/EKS
  -> Kubernetes Deployment (2 replicas) and Service
  -> AWS Load Balancer Controller
  -> Internet-facing ALB
  -> Public Flask API endpoints

The ALB returned HTTP 200 for `/health`, `/`, and `/api/users`.
Both registered pod IP targets reported `healthy`. The ALB and
application namespace were deleted after validation. Prometheus/Grafana
monitoring and alerting are documented separately from this EKS test.

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

GitHub push webhook delivery and automatic execution of the safe
Webhook-Test job have been verified. The production `Testing` job's webhook
trigger is configured, but automatic production execution has not yet been
verified end to end.

Ansible playbooks and the dedicated Jenkins Ansible-Health-Check job have
been validated against the Docker application server. Live EKS deployment,
Prometheus/Grafana, and notifications remain pending validation in the
current environment.

## 5. Repository Structure

- `app/app.py` - Flask application
- `app/requirements.txt` - Python dependencies
- `tests/test_app.py` - Application tests
- `Dockerfile` - Container image definition
- `k8s/deployment.yaml` - Kubernetes Namespace and Deployment
- `k8s/service.yaml` - Kubernetes Service
- `k8s/ingress.yaml` - AWS ALB Ingress configuration
Terraform configuration is currently maintained outside this Git
repository on the Jenkins controller. See Section 11 for its location.
The Terraform files are not included in the tracked GitHub repository.

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
The manifest references ECR image tag `27`.

EKS validation completed on 2026-10-24:
- Cluster `devops-capstone-eks` reached `ACTIVE`.
- Managed node group `devops-capstone-nodes` reached `ACTIVE`.
- Both application replicas were available on separate worker nodes.
- Internal service requests succeeded for `/health`, `/`, and `/api/users`.
- Public ALB requests for all three endpoints returned HTTP `200 OK`.
- Both ALB target group targets reported `healthy`.

After validation, the Ingress and `devops-capstone` application namespace
were deleted, and the ALB Controller Helm release was uninstalled.
The ALB and its associated target group were confirmed absent. The
Terraform-managed EKS/VPC/NAT infrastructure cleanup is still pending.

## 11. Terraform

Terraform configuration is stored locally on the Jenkins controller,
outside this GitHub repository:

    /var/lib/jenkins/terraform-eks-capstone

The configuration manages the VPC, networking, EKS cluster, managed
node group, IAM roles, and outputs. Terraform working data and saved
plans are local; do not commit them without reviewing for sensitive data.

The EKS lab was provisioned and validated on 2026-10-24. A reviewed
destroy plan proposed destroying 24 Terraform-managed resources, with
zero additions and zero changes. That plan has not yet been applied.

Review the plan and confirm before destroying infrastructure. Preserve
the remote Terraform state bucket and unrelated resources. NAT Gateways,
EKS worker nodes, and other AWS resources can incur charges.

## 12. Security Notes

- The application container runs as a non-root user.
- Kubernetes configuration disables privilege escalation and drops
  Linux capabilities.
- Do not commit AWS credentials, SSH private keys, or secrets.
- Restrict Jenkins and SSH access using security groups and approved
  source IP ranges.
- Review IAM permissions using least privilege.

## 13. Validation Evidence

### Docker CI/CD and application
- Latest previously documented production deployment image: ECR tag `27`.
- `tests/test_app.py`: 3 tests passed (`test_home`, `test_health`, `test_users`).
- The production Docker deployment health check returned
  `{"status":"healthy"}`.
- The previous image was preserved as a rollback container during
  deployment validation.

### Webhook and Jenkins
- GitHub push delivery returned HTTP `200`.
- `Webhook-Test` ran automatically following a GitHub push.
- The production `Testing` job webhook trigger was configured, but
  fully automatic production execution still needs explicit verification.

### Ansible
- Tracked playbooks: `ansible/playbooks/system_info.yml`,
  `ansible/playbooks/docker_health.yml`, and `ansible/playbooks/disk_check.yml`.
- Jenkins job `Ansible-Health-Check` completed with `SUCCESS`.
- Docker service was active and the remote Flask health endpoint was healthy.
- Disk validation passed below the configured 80% root filesystem threshold.
- Jenkins `Testing` build `#45` completed with `SUCCESS` on 2026-10-23.
- The `Ansible Post-Deployment Validation` stage ran
  `docker_health.yml` and `disk_check.yml`.
- The build log confirmed `ANSIBLE POST-DEPLOYMENT VALIDATION PASSED`.

### EKS, Kubernetes, and ALB — 2026-10-24
- EKS cluster and managed node group reached `ACTIVE`.
- Two worker nodes were `Ready`.
- Kubernetes Deployment had 2 available application replicas.
- Internal `/health`, `/`, and `/api/users` requests succeeded.
- Public ALB requests for `/health`, `/`, and `/api/users` all returned
  `HTTP/1.1 200 OK`.
- ALB target group reported both pod IP targets as `healthy`.
- ALB and its target group were subsequently confirmed absent after cleanup.
- Application namespace and ALB Controller Helm release were removed.
- Terraform destroy plan: `0 to add, 0 to change, 24 to destroy`.
  The plan was reviewed but not applied at the time of this update.

### Monitoring
Prometheus/Grafana and alerting were previously configured and tested.
Recheck the monitoring hosts and current alert evidence before claiming
they remain active in the current environment.

## 14. Remaining Work

- Apply the reviewed Terraform destroy plan after explicit confirmation,
  if the EKS lab is no longer needed for a live demonstration.
- Verify remaining AWS billable resources after cleanup, including NAT
  Gateways, Elastic IPs, EKS resources, and unattached storage.
- Verify automatic production `Testing` job execution from a GitHub push.
- Perform and document a controlled automated rollback test.
- Review the latest Jenkins build log to confirm Ansible post-deployment
  validation ran successfully in the production pipeline.
- Capture and retain final CI/CD, EKS/ALB, and monitoring evidence.
- Reconcile monitoring documentation with the current running state.

## 15. Cost Management

Stop or destroy lab resources that are not needed.
Review NAT Gateways, load balancers, EKS node groups, EC2 instances,
EBS volumes, Elastic IPs, and CloudWatch log groups before cleanup.

Preserve required Terraform state and project artifacts.


Done
