# DevOps Capstone: Flask CI/CD on AWS

## 1. Project Overview

This project demonstrates a Flask API CI/CD workflow using Jenkins,
GitHub, Amazon ECR, Docker, and a remote Docker host. It also includes
Terraform configuration, Kubernetes manifests, Ansible validation, and
Prometheus/Grafana monitoring work.

The EKS deployment and internet-facing AWS Application Load Balancer
were first validated on 2026-10-24. The environment was redeployed and
validated again on 2026-10-26. The current deployment uses ECR image tag
`49`, with two available application replicas and two healthy ALB targets.
The `/health` and `/api/users` endpoints returned HTTP 200. The EKS
environment and ALB are currently active and may incur AWS charges.

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

The 2026-10-24 ALB validation returned HTTP 200 for `/health`, `/`,
and `/api/users`; that test environment was subsequently cleaned up.
On 2026-10-26, the environment was redeployed and validated again.
Current deployment evidence is recorded in Section 13. Prometheus/Grafana
monitoring and alerting are documented separately.

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

GitHub push webhook delivery and automatic execution of both
`Webhook-Test` and the production `Testing` job have been verified.
Jenkins build #48 was triggered by a GitHub push and completed successfully.

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
The tracked `k8s/deployment.yaml` manifest references ECR image tag
`27`. The live deployment validated on 2026-10-26 uses image tag `49`,
applied from a temporary manifest; the tracked manifest was not changed.

EKS validation on 2026-10-24:
- Cluster and managed node group reached `ACTIVE`.
- Both application replicas were available on separate worker nodes.
- Public ALB endpoints returned HTTP `200 OK`.
- Both ALB target group targets reported `healthy`.
- That test environment was subsequently cleaned up.

EKS redeployment validation on 2026-10-26:
- Cluster `devops-capstone-eks` and two worker nodes were active/ready.
- Deployment `devops-flask-api` had 2/2 available replicas using image `:49`.
- Both pods were `Running`, ready, and had zero restarts.
- Both ALB targets (`10.20.11.133:8080` and `10.20.12.19:8080`)
  reported `Healthy`.
- ALB `/health` and `/api/users` requests returned HTTP `200 OK`.
- Twenty repeated ALB `/health` requests returned HTTP `200`.
- Direct `/health` checks to each pod returned HTTP `200`.
- The current Ingress uses the internet-facing ALB on HTTP port 80.

The EKS environment and ALB are currently active. Review AWS costs
before leaving the lab running. Terraform-managed resources have not
been destroyed as part of this validation.

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
- Latest verified production deployment: Jenkins build `#48` on 2026-10-24.
- Build `#48` checked out commit `e2a435f` and completed with `SUCCESS`.
- Candidate and production health checks passed; previous production
  container was preserved as `flask-api-rollback-48`.
- `tests/test_app.py`: 3 tests passed (`test_home`, `test_health`, `test_users`).
- The production Docker deployment health check returned
  `{"status":"healthy"}`.
- The previous image was preserved as a rollback container during
  deployment validation.

### Webhook and Jenkins
- GitHub push delivery returned HTTP `200`.
- `Webhook-Test` ran automatically following a GitHub push.
- Jenkins service logs confirmed a GitHub push event and automatic
  triggering of `Testing #48`.
- Build `#48` XML recorded `GitHubPushCause`; the build completed with
  `SUCCESS`.

### Ansible
- Tracked playbooks: `ansible/playbooks/system_info.yml`,
  `ansible/playbooks/docker_health.yml`, and `ansible/playbooks/disk_check.yml`.
- Jenkins job `Ansible-Health-Check` completed with `SUCCESS`.
- Docker service was active and the remote Flask health endpoint was healthy.
- Disk validation passed below the configured 80% root filesystem threshold.
- Jenkins `Testing` build `#48` completed with `SUCCESS` on 2026-10-24.
- The `Ansible Post-Deployment Validation` stage ran
  `docker_health.yml` and `disk_check.yml`.
- The build log confirmed `ANSIBLE POST-DEPLOYMENT VALIDATION PASSED`.

### EKS, Kubernetes, and ALB — 2026-10-24
- Initial EKS deployment and ALB endpoint validation succeeded.
- That test environment was subsequently cleaned up.

### EKS, Kubernetes, and ALB — 2026-10-26
- Deployment `devops-flask-api`: 2/2 replicas available, image tag `49`.
- Both application pods were `Running`, ready, and had zero restarts.
- Both ALB target group targets reported `Healthy`.
- `/health` and `/api/users` through the ALB returned `HTTP/1.1 200 OK`.
- Twenty repeated ALB `/health` requests returned HTTP 200.
- Direct `/health` requests to both pods returned HTTP 200.
- The current ALB and EKS application environment are active.
- Tracked `k8s/deployment.yaml` still references image tag `27`.
- No Terraform apply or destroy was performed for this validation.

### Monitoring — 2026-10-26
- The four configured Prometheus production rules were present with
  `health: ok`: `NodeExporterDown`, `HighCPUUsage`, `HighMemoryUsage`,
  and `LowDiskSpace`.
- The temporary `PrometheusGmailFiringTest` rule using `vector(1)` passed
  `promtool` validation, and Prometheus reloaded the configuration.
- Alertmanager received the test alert and routed it to
  `gmail-notifications`.
- Gmail delivery was verified for both `[FIRING:1] PrometheusGmailFiringTest
  (warning)` and `[RESOLVED] PrometheusGmailFiringTest (warning)`.
- The temporary test rule was removed, Prometheus was reloaded, and the
  rules API subsequently showed only the four production rules.
- This verifies the Prometheus-to-Alertmanager-to-Gmail notification path.
  Individual real CPU, memory, disk, and Node Exporter failure scenarios
  have not been demonstrated by this temporary test.
- Recheck current monitoring host availability and Grafana dashboard
  functionality before claiming they are currently operational.

## 14. Remaining Work

- Apply the reviewed Terraform destroy plan after explicit confirmation,
  if the EKS lab is no longer needed for a live demonstration.
- Verify remaining AWS billable resources after cleanup, including NAT
  Gateways, Elastic IPs, EKS resources, and unattached storage.
- Perform and document a controlled automated rollback test; rollback
  logic is implemented, but failure-triggered recovery has not yet been
  demonstrated by build `#48`.
- Recheck current Prometheus, Alertmanager, and Grafana availability;
  validate individual production alert scenarios when practical.
- Decide whether to retain or clean up the provisioned EKS/VPC/NAT
  infrastructure after reviewing cost and demo requirements.
- Retain final CI/CD, EKS/ALB, Terraform validation, and monitoring evidence.
- Reconcile monitoring documentation with the current running state.

## 15. Cost Management

Stop or destroy lab resources that are not needed.
Review NAT Gateways, load balancers, EKS node groups, EC2 instances,
EBS volumes, Elastic IPs, and CloudWatch log groups before cleanup.

Preserve required Terraform state and project artifacts.


Done
