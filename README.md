# DevOps Capstone: Flask CI/CD on AWS

## 1. Project Overview

This project demonstrates an end-to-end DevOps workflow for a Flask API using GitHub, Jenkins, Docker, Amazon ECR, AWS EC2, Kubernetes/EKS, Terraform, Ansible, and Prometheus/Grafana monitoring.

The CI/CD pipeline checks out application code, runs automated tests, builds and pushes a Docker image to Amazon ECR, deploys the image to a remote Docker host, verifies application health, preserves the previous production container for recovery, and runs Ansible post-deployment validation.

The EKS deployment and internet-facing AWS Application Load Balancer (ALB) were validated on 2026-10-24 and 2026-10-26. The live Kubernetes deployment was observed with two available application replicas and two healthy ALB targets. The live deployment used ECR image tag `49`; the tracked Kubernetes deployment manifest still references tag `27`, so this difference remains unresolved.

The latest verified Jenkins build reviewed for this README is build `#52`, which completed with `SUCCESS` on 2026-10-27. Its metadata records a GitHub push cause. The deployment log confirms candidate and production health checks, preservation of the previous production container as `flask-api-rollback-52`, and successful Ansible post-deployment validation.

**Cost warning:** EKS, ALB, NAT Gateway, EC2 instances, EBS volumes, Elastic IPs, and monitoring services may incur AWS charges. Review current resources and costs before leaving the lab running.

## 2. Architecture

```text
Developer
   |
   v
GitHub repository (main)
   |
   | GitHub push webhook
   v
Jenkins job: Testing
   |
   +--> Checkout source
   +--> Run pytest
   +--> Build and push Docker image to Amazon ECR
   +--> Deploy to remote Docker application server
   |      +--> Pull candidate image
   |      +--> Start candidate and check /health
   |      +--> Preserve previous production container
   |      +--> Start new production and check /health
   +--> Run Ansible post-deployment validation
          +--> Docker/application health check
          +--> Root filesystem threshold check

Separate Kubernetes path:
Terraform-managed AWS infrastructure
   -> Amazon EKS -> Flask API Deployment (2 replicas)
   -> Kubernetes Service -> AWS Load Balancer Controller -> ALB

Monitoring path:
Prometheus + Alertmanager + Grafana
   -> Metrics, alert rules, and email notification delivery
```

## 3. Application Endpoints

| Endpoint | Purpose | Expected result |
|---|---|---|
| `/` | Welcome response | JSON message and version |
| `/health` | Health check | `{"status":"healthy"}` |
| `/api/users` | Example users API | JSON response containing sample users |

The tests in `tests/test_app.py` cover `test_home`, `test_health`, and `test_users`. A previously verified run reported three passing tests.

## 4. Technology Stack

- Python, Flask, Gunicorn, pytest
- Docker
- Git, GitHub, GitHub webhooks
- Jenkins Pipeline
- Amazon ECR and EC2
- Amazon EKS and Kubernetes
- AWS Application Load Balancer and AWS Load Balancer Controller
- Terraform
- Ansible
- Prometheus, Alertmanager, Grafana

## 5. Repository Structure

Key paths verified during project work:

```text
.
├── tests/
│   └── test_app.py
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── ansible/
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.ini
    └── playbooks/
        ├── system_info.yml
        ├── docker_health.yml
        └── disk_check.yml
```

The Terraform configuration used for the EKS capstone is maintained on the Jenkins host at `/var/lib/jenkins/terraform-eks-capstone`; it is not assumed to be part of the repository tree above.

## 6. Local Development

From the repository root, create a virtual environment, install dependencies, and run tests:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
pytest -v
```

Use the project's configured application startup method for local development. For a containerized run, follow the Docker instructions below.

## 7. Docker

Build a local image:

```bash
docker build -t devops-flask-api:local .
```

Run it, mapping host port 8080 to the container's application port:

```bash
docker run --rm -d --name flask-api-local -p 8080:8080 devops-flask-api:local
```

Check health and stop the local container when finished:

```bash
curl -fsS http://127.0.0.1:8080/health
docker stop flask-api-local
```

The application container uses a non-root user (UID `10001`) according to the project configuration. Confirm the Dockerfile's port and startup command if those settings have changed.

## 8. Jenkins CI/CD

Primary Jenkins job: `Testing`. Supporting jobs include `Ansible-Health-Check` and `Webhook-Test`.

The `Testing` pipeline includes:

1. Checkout source from GitHub.
2. Run automated application tests.
3. Build and push the Docker image to Amazon ECR.
4. Deploy to the remote Docker application server.
5. Run Ansible post-deployment validation.

The deployment workflow checks candidate health before production replacement, preserves the previous production container, and checks the new production container's health. Build `#52` preserved the previous container as `flask-api-rollback-52`.

### GitHub webhook

GitHub push delivery and automatic Jenkins triggering have been verified. Build `#52` metadata contains `com.cloudbees.jenkins.GitHubPushCause` and the build completed successfully.

### Rollback limitation

Preserving a previous container is a recovery prerequisite, but it does not by itself prove failure-triggered rollback restores service. A controlled rollback/recovery test and a post-recovery health check have not yet been demonstrated in the evidence reviewed here.

## 9. Amazon ECR

Image repository:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api
```

AWS region: `ap-south-1` (Asia Pacific—Mumbai).

The pipeline publishes build-number tags. Use the tag shown in the relevant successful build log rather than assuming every build number exists or is deployable.

Docker hosts must authenticate to ECR before pulling images. ECR authorization tokens expire; an expired token caused a deployment-stage failure in build `#33`. Ensure deployment logic refreshes authentication before pulling an image.

## 10. Kubernetes

Manifests are stored in `k8s/`:

- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`

The Deployment specifies two replicas, non-root execution, resource requests and limits, and readiness/liveness probes.

### EKS validation

EKS and ALB validation succeeded on 2026-10-24 and 2026-10-26. Evidence from 2026-10-26 showed:

- Cluster and managed node group were active.
- Deployment `devops-flask-api` had 2/2 replicas available.
- Both application pods were running and ready with zero restarts.
- Both ALB target group targets were healthy.
- ALB `/health` and `/api/users` endpoints returned HTTP 200.
- Twenty repeated ALB `/health` requests returned HTTP 200.
- Direct `/health` requests to both pods returned HTTP 200.

Verify current cluster status before relying on this as live operational status.

### Known manifest drift

The tracked `k8s/deployment.yaml` references image tag `27`, while the live EKS deployment validated on 2026-10-26 used tag `49`, applied from a temporary manifest. The tracked manifest was not changed during that validation.

This is an unresolved source-of-truth decision. Review the intended deployment version before updating the tracked manifest.

## 11. Terraform

The EKS capstone Terraform configuration is on the Jenkins host at:

```text
/var/lib/jenkins/terraform-eks-capstone
```

It manages infrastructure used by the EKS environment, including VPC networking, subnets, routes, internet/NAT connectivity, IAM roles, the EKS cluster, and the managed node group.

A prior read-only refresh plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

That result applies only to the configuration and state at the time of the check. Run a fresh plan before making changes.

### Safe operating procedure

- Inspect the current workspace and state before planning changes.
- Run `terraform plan -refresh=true` and review the full plan.
- Do not run `terraform apply` or `terraform destroy` until the plan, impact, and cost implications have been reviewed and explicitly approved.
- Protect Terraform state and credentials; never commit secrets or state files containing sensitive values.
- Verify the backend configuration before claiming remote S3 state and locking are enabled.

## 12. Security Notes

- The Flask container runs as a non-root user (UID `10001`).
- Keep AWS credentials, SSH private keys, Jenkins secrets, and monitoring credentials out of Git.
- Prefer IAM roles for AWS access on EC2 rather than long-lived access keys.
- Restrict Jenkins, SSH, Grafana, Prometheus, and Alertmanager access to trusted networks and authorized users.
- Do not expose monitoring endpoints publicly without appropriate authentication and network controls.
- Refresh ECR authentication before image pulls; tokens expire.
- Preserve backups and recovery artifacts until their purpose and retention have been reviewed.
- Review security groups, IAM permissions, and stored secrets periodically.

## 13. Validation Evidence

### Docker CI/CD and application

- Latest verified pipeline build reviewed here: Jenkins build `#52`, completed with `SUCCESS` on 2026-10-27.
- Build `#52` metadata records a GitHub push cause.
- Candidate health check passed before production replacement.
- Previous production container was preserved as `flask-api-rollback-52`.
- Production health check passed.
- `Ansible Post-Deployment Validation` completed successfully.
- Earlier verified application test output reported three passing tests: `test_home`, `test_health`, and `test_users`.
- Failure-triggered rollback and recovery health-check execution have not yet been demonstrated.

### Webhook and Jenkins

- GitHub push delivery returned HTTP 200 in a previously verified webhook test.
- `Webhook-Test` ran automatically after a GitHub push.
- Jenkins logs and build metadata confirmed GitHub push triggering.
- Build `#52` metadata contains `com.cloudbees.jenkins.GitHubPushCause` and the build completed with `SUCCESS`.

### Ansible

- Tracked playbooks include `system_info.yml`, `docker_health.yml`, and `disk_check.yml`.
- The dedicated `Ansible-Health-Check` job completed successfully in earlier validation.
- Build `#52` reported `ANSIBLE POST-DEPLOYMENT VALIDATION PASSED`.
- Build `#40`'s disk check reported root filesystem usage of 16%, below the configured 80% threshold, with zero failed or unreachable hosts.
- Ansible validation checks application health and disk usage; it does not replace a full recovery test.

### EKS, Kubernetes, and ALB — 2026-10-24 and 2026-10-26

- Initial EKS deployment and ALB endpoint validation succeeded.
- The 2026-10-26 check showed 2/2 application replicas available.
- Both ALB target group targets reported healthy.
- ALB `/health` and `/api/users` endpoints returned HTTP 200.
- Twenty repeated ALB `/health` requests returned HTTP 200.
- The live deployment used image tag `49`; the tracked manifest still referenced `27`.
- No Terraform apply or destroy was performed for the 2026-10-26 validation.
- Recheck the live cluster and ALB before using this as current status.

### Terraform

- A prior refresh plan reported no changes between Terraform configuration and infrastructure state at that time.
- No Terraform apply or destroy was performed during the 2026-10-26 EKS validation.
- Run a fresh plan before future infrastructure changes.

### Monitoring and notifications

- Prometheus, Alertmanager, and Grafana health endpoints previously returned successful responses.
- Prometheus targets and alert rules were checked.
- A synthetic alert was submitted to Alertmanager, and Gmail notification delivery was confirmed.
- Current service health and alert auto-clear behavior must be rechecked before claiming monitoring remains active and fully validated.

## 14. Remaining Work

- Perform and document a controlled automated rollback/recovery test during an approved maintenance window, including a successful health check after recovery.
- Recheck Prometheus, Alertmanager, and Grafana health and verify alert auto-clear behavior.
- Reconcile the tracked Kubernetes manifest image tag (`27`) with the intended deployment version; the live deployment previously used tag `49`.
- Review remaining AWS billable resources and current costs, including EKS, EC2, ALB, NAT Gateways, Elastic IPs, EBS volumes, and monitoring resources.
- Decide whether to retain the EKS/VPC/NAT environment for demonstration or clean it up after reviewing the plan and cost impact.
- Retain final CI/CD, webhook, Ansible, EKS/ALB, Terraform, and monitoring evidence.
- Confirm the Terraform backend configuration before claiming remote S3 state and locking.
- Recheck live resource status before describing the environment as currently active.

## 15. Cost Management

AWS lab resources can incur charges even when idle. Pay particular attention to:

- EKS cluster and worker-node compute
- EC2 instances
- NAT Gateway hourly and data-processing charges
- Application Load Balancers
- EBS volumes and snapshots
- Elastic IPs and other networking resources
- CloudWatch logs and metrics
- Monitoring hosts or storage, if hosted on AWS

Before cleanup:

1. Inspect the current AWS resource inventory in `ap-south-1`.
2. Identify each resource's owner and purpose; do not assume all resources belong to this capstone.
3. Review a Terraform destroy plan and resources managed outside Terraform.
4. Preserve Jenkins and the Docker application server unless there is explicit approval to remove them.
5. Obtain explicit approval before executing destructive cleanup commands.
6. Recheck the resource inventory after any approved cleanup.

Do not infer that a resource has been deleted simply because it is absent from Terraform state; manually created or separately managed resources may remain.

---

**Status note:** This README records evidence reviewed through 2026-10-27. Historical validation is not a guarantee of current service health. Re-run relevant checks before a live demonstration or final submission.
