# DevOps CI/CD Capstone Project

A Flask-based DevOps capstone demonstrating automated testing, Docker image creation, Amazon ECR publishing, Jenkins-driven deployment, Ansible validation, Kubernetes deployment on Amazon EKS, AWS Application Load Balancer integration, monitoring, alert testing, and deployment recovery analysis.

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Objectives](#2-project-objectives)
3. [Architecture](#3-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Application Overview](#5-application-overview)
6. [Repository Structure](#6-repository-structure)
7. [CI/CD Pipeline](#7-cicd-pipeline)
8. [Docker and Amazon ECR](#8-docker-and-amazon-ecr)
9. [Ansible Validation](#9-ansible-validation)
10. [Kubernetes and Amazon EKS](#10-kubernetes-and-amazon-eks)
11. [Terraform Infrastructure](#11-terraform-infrastructure)
12. [Prometheus, Alertmanager and Gmail](#12-prometheus-alertmanager-and-gmail)
13. [Deployment Recovery and Rollback Testing](#13-deployment-recovery-and-rollback-testing)
14. [Validation Evidence](#14-validation-evidence)
15. [Security Practices](#15-security-practices)
16. [Cost Management](#16-cost-management)
17. [Current Project Status](#17-current-project-status)
18. [Remaining Work](#18-remaining-work)
19. [Troubleshooting](#19-troubleshooting)

---

## 1. Project Overview

This project implements a practical DevOps workflow for a Python Flask application using Jenkins, GitHub, Docker, Amazon Elastic Container Registry (ECR), and AWS infrastructure.

The project also includes Kubernetes manifests, Terraform configuration, Ansible playbooks, and monitoring and alerting validation.

The primary workflow automates application testing, image building, image publishing, deployment to a remote Docker server, and post-deployment health checks.

Additional work demonstrates deployment to Amazon EKS behind an AWS Application Load Balancer (ALB), Prometheus alert-rule testing, Gmail notifications, and isolated deployment failure-path tests.

### Key capabilities

- GitHub push webhook integration with Jenkins.
- Automated Python unit tests using pytest.
- Docker image build and publishing to Amazon ECR.
- Remote application deployment over SSH.
- Application health checks and deployment audit logging.
- Preservation of the previous container image for rollback.
- Ansible-based Docker and disk validation.
- Kubernetes deployment and service configuration.
- Amazon EKS and ALB application validation.
- Prometheus alert-rule testing and Gmail notification validation.
- Isolated mock tests for deployment failure and recovery branches.
- Terraform-based AWS infrastructure configuration.

**Important:** Successful component validation does not automatically establish that every component is currently running or that every end-to-end recovery scenario has been verified. Current status and remaining validation are documented below.

## 2. Project Objectives

The objectives of this project are to:

1. Automate application testing and deployment.
2. Integrate source control with Jenkins using GitHub webhooks.
3. Build and publish versioned container images.
4. Deploy application containers to a remote Docker host.
5. Verify deployments using application health endpoints.
6. Validate remote infrastructure with Ansible.
7. Deploy and expose an application using Kubernetes, EKS, and ALB.
8. Test monitoring rules and alert notifications.
9. Investigate deployment failure handling and rollback behavior.
10. Document security considerations, validation results, and AWS cost exposure.

## 3. Architecture

### 3.1 CI/CD deployment flow

```text
Developer
   |
   v
GitHub Repository
   |
   | Push webhook
   v
Jenkins Pipeline
   |
   +--> Checkout source code
   |
   +--> Install dependencies and run pytest
   |
   +--> Build Docker image
   |
   +--> Authenticate to Amazon ECR
   |
   +--> Push versioned image
   |
   +--> Connect to remote Docker server over SSH
   |
   +--> Start candidate container
   |
   +--> Validate application health
   |
   +--> Switch production container
   |
   +--> Verify deployment and record audit evidence
   |
   +--> Run Ansible post-deployment validation
```

The production deployment process includes candidate and production health checks and preservation of the previous container for recovery attempts. Actual rollback recovery and traffic recovery are not yet established by the isolated mock tests alone.

### 3.2 Kubernetes and monitoring architecture

```text
GitHub / Application Image
           |
           v
    Amazon ECR
           |
           v
    Amazon EKS
           |
           v
 Kubernetes Deployment
           |
           v
 Kubernetes Service
           |
           v
 AWS Application Load Balancer
           |
           v
     Flask Application

Monitoring:
Prometheus --> Alertmanager --> Gmail notifications
```

The Kubernetes deployment and ALB flow was validated during the documented EKS lab sessions. Monitoring rule tests and Gmail notification tests were also completed. See the validation evidence for dates and limitations.

## 4. Technology Stack

| Category | Technology |
|---|---|
| Operating system and administration | Linux, Amazon Linux |
| Application | Python, Flask |
| Automated testing | pytest |
| Source control | Git, GitHub |
| CI/CD | Jenkins |
| Containerization | Docker |
| Container registry | Amazon ECR |
| Cloud platform | AWS |
| Infrastructure as Code | Terraform |
| Configuration and validation | Ansible |
| Container orchestration | Kubernetes, Amazon EKS |
| Load balancing | AWS Application Load Balancer |
| Monitoring | Prometheus |
| Alert routing | Alertmanager |
| Notifications | Gmail SMTP |
| Automation scripting | Bash, Python |
| Application server | Gunicorn |

## 5. Application Overview

The project provides a Flask REST API.

### Endpoints

| Endpoint | Purpose | Expected response |
|---|---|---|
| `/` | Application welcome endpoint | Welcome message and version |
| `/health` | Application health check | `{"status":"healthy"}` |
| `/api/users` | Example user API | JSON containing application users |

Example health response:

```json
{
  "status": "healthy"
}
```

The application test suite covers the home endpoint, health endpoint, and users endpoint.

### Run locally

Prerequisites: Python and Git.

```bash
git clone https://github.com/Ayushgautam2007/Devops-Project.git
cd Devops-Project

python -m venv .venv
source .venv/bin/activate

python -m pip install -r app/requirements.txt
python -m pytest -v
```

To run the Flask application, use the project's application entry point and the configured development or production server settings.

For production deployments, use Gunicorn or the deployment configuration rather than Flask's development server.

## 6. Repository Structure

The principal tracked project files include:

```text
Devops-Project/
├── app/
│   ├── app.py
│   └── requirements.txt
├── tests/
│   └── test_app.py
├── Dockerfile
├── Jenkinsfile
├── README.md
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   └── playbooks/
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

The exact directory contents should be confirmed against the current Git checkout before adding or removing paths from this listing.

Terraform configuration is maintained separately on the Jenkins controller:

```text
/var/lib/jenkins/terraform-eks-capstone
```

The Terraform working directory and state-related artifacts are not part of the tracked GitHub repository.

## 7. CI/CD Pipeline

### Jenkins jobs

| Job | Purpose |
|---|---|
| `Testing` | Main CI/CD pipeline |
| `Ansible-Health-Check` | Ansible connectivity and server validation |
| `Webhook-Test` | GitHub push webhook verification |

The `Testing` job uses an SCM-based Pipeline definition. Its configured branch is `*/main`, and its script path is `Jenkinsfile`, with lightweight checkout enabled.

### Pipeline stages

The main pipeline has included the following activities:

1. Checkout application source code.
2. Install dependencies and run automated tests.
3. Build a Docker image.
4. Authenticate to Amazon ECR.
5. Push the versioned image to ECR.
6. Connect to the remote Docker server.
7. Start and validate a candidate application container.
8. Perform production deployment and health verification.
9. Preserve the previous container for recovery attempts.
10. Run Ansible post-deployment validation.

The exact current stage names and implementation should be checked against the tracked `Jenkinsfile` and the latest successful Jenkins build.

### GitHub webhook integration

The GitHub webhook endpoint is configured for Jenkins at:

```text
/github-webhook/
```

Documented validation showed successful webhook delivery and automatic triggering of the `Webhook-Test` and production `Testing` jobs. Jenkins build `#48` was recorded as push-triggered and successful.

### Pipeline validation

The application test suite has three tests:

- `test_home`
- `test_health`
- `test_users`

The documented test runs passed all three tests.

### Deployment audit and health checks

The deployment process performs application health checks and preserves deployment evidence. The application health endpoint is:

```text
/health
```

The remote production container has been observed returning:

```json
{"status":"healthy"}
```

The pipeline's failure handling and rollback-related behavior are discussed in Section 13.

## 8. Docker and Amazon ECR

The application is packaged as a Docker image and published to Amazon ECR.

**AWS Region:** `ap-south-1`

**ECR repository:**

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api
```

Images use Jenkins build numbers as version tags.

Example:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:<BUILD_NUMBER>
```

The Docker image uses a non-root application user with UID `10001`.

### Operational checks

Check Docker service status:

```bash
sudo systemctl status docker
```

List running containers:

```bash
sudo docker ps
```

Inspect container configuration:

```bash
sudo docker inspect <container-name>
```

Check the application endpoint from the Docker server:

```bash
curl -fsS http://127.0.0.1:9090/health
```

The port above reflects the documented Docker host mapping. Confirm the current container port mapping before reusing this command in another environment.

### Image lifecycle

The deployment pipeline publishes a versioned image and preserves the previously deployed container or image for recovery attempts. Old images and rollback containers should be reviewed before cleanup so that a required recovery artifact is not removed prematurely.

## 9. Ansible Validation

Ansible is used to validate the remote Docker application server after deployment.

The documented Ansible environment includes:

- Ansible Core 2.15.3.
- Python 3.9.25 on the Ansible controller.
- Inventory group `docker_servers`.
- Inventory host `app-server`.
- SSH access as `ec2-user`.

### Playbooks

| Playbook | Purpose |
|---|---|
| `system_info.yml` | Collect system information |
| `docker_health.yml` | Validate Docker service and application health |
| `disk_check.yml` | Check disk usage and fail at or above the configured 80% threshold |

The Ansible configuration uses host-key checking and disables retry-file generation. SSH options include `IdentitiesOnly=yes`.

### Validation performed

The dedicated `Ansible-Health-Check` Jenkins job validated connectivity, playbook syntax, Docker health, and disk usage against the application server.

The documented run confirmed that the Docker service was active, the application health endpoint was healthy, and the disk-usage check passed.

### Security considerations

- Keep the private SSH key outside the Git repository.
- Restrict key permissions and access.
- Use inventory-specific SSH configuration.
- Do not disable SSH host-key checking in production without a documented security decision.

## 10. Kubernetes and Amazon EKS

The project includes Kubernetes manifests for deployment, service, and ALB ingress configuration.

The documented EKS environment used:

```text
Cluster: devops-capstone-eks
Namespace: devops-capstone
Replicas: 2
```

### Deployment configuration

The application manifests include security and reliability settings such as:

- Non-root execution.
- Disabled privilege escalation.
- Dropped Linux capabilities.
- Resource requests and limits.
- Liveness and readiness probes.
- Two application replicas.

### ALB integration

The ingress configuration integrates the application with an AWS Application Load Balancer.

The documented validation on October 26, 2026, recorded:

- EKS cluster and managed node group active.
- Two application replicas ready.
- Two healthy ALB targets.
- `/health` and `/api/users` returning HTTP 200.
- Twenty health requests returning successful responses.
- Direct pod health checks succeeding.

### Image version discrepancy

The tracked Kubernetes manifest uses image tag `27`, while the documented live EKS deployment used tag `49`.

This difference must be reconciled before treating the tracked manifests as a reproducible definition of the live deployment. Do not assume that the Git repository currently reproduces the live image version without updating and reviewing the manifest.

### Cost warning

The EKS lab, node group, load balancer, NAT Gateway, and supporting infrastructure may incur charges while provisioned. Check actual AWS resource status before leaving the environment running or starting cleanup.

## 11. Terraform Infrastructure

Terraform configuration is stored on the Jenkins controller at:

```text
/var/lib/jenkins/terraform-eks-capstone
```

It manages infrastructure such as:

- VPC and networking.
- EKS cluster.
- Managed node group.
- IAM roles and associated outputs.

Terraform state, saved plans, and working data are maintained separately from the tracked application repository.

### Plan history

A saved `cleanup-review.tfplan` from October 24, 2026, proposed destroying 24 Terraform-managed resources with zero additions and zero changes. It is a historical plan and must not be treated as a current destroy plan.

A separate `cost-audit-current.tfplan` was generated on October 27, 2026. The documented refresh plan reported no changes between Terraform configuration/state and the refreshed infrastructure view.

A no-change refresh plan does **not** mean the infrastructure is free of charges, nor does it authorize destroying resources.

### Safe cleanup procedure

Before cleanup:

1. Confirm whether the EKS lab is still needed.
2. Inspect the current Terraform workspace and backend.
3. Refresh the infrastructure view.
4. Generate a new destroy plan if cleanup is intended.
5. Review every resource in that plan.
6. Confirm the plan does not include the remote state bucket or unrelated resources.
7. Obtain explicit approval before applying the destroy plan.
8. Verify remaining billable AWS resources afterward.

Never apply an old saved destroy plan merely because it exists.

## 12. Prometheus, Alertmanager and Gmail

Monitoring validation covered Prometheus alert rules, Alertmanager configuration, and Gmail notifications.

### Production alert rules

The documented production rules are:

| Rule | Intended purpose |
|---|---|
| `NodeExporterDown` | Detect unavailable Node Exporter targets |
| `HighCPUUsage` | Detect high CPU utilization |
| `HighMemoryUsage` | Detect high memory utilization |
| `LowDiskSpace` | Detect low available disk space |

The precise expressions, thresholds, and evaluation durations should be reviewed in the actual Prometheus rule configuration.

### Validation performed

On October 26, 2026, the documented checks included:

- `promtool check rules` reported success for four production rules.
- A synthetic `promtool test rules` suite passed for all four rules.
- The tests exercised synthetic metric values and firing delays.
- A temporary test rule was used to exercise the Prometheus-to-Alertmanager-to-Gmail path.
- Gmail firing and resolved notifications were received.
- The temporary test rule was removed.
- Prometheus was reloaded, and the rules API subsequently showed only the four production rules.
- The production rules file checksum was recorded as:

```text
5d8b7e40f6ba2f87315b9ed5918bf07187298c0be127ea76b757575a60a81974
```

### Limitations

Synthetic tests validate rule expressions and expected behavior against test metrics. They do not demonstrate that every production alert has fired due to a real host failure or that each individual production rule has delivered a Gmail notification.

Current Prometheus, Alertmanager, and Grafana availability must be checked again before claiming that the monitoring stack is currently operational.

Do not commit SMTP passwords, Gmail app passwords, tokens, or other credentials to GitHub.

## 13. Deployment Recovery and Rollback Testing

The project includes deployment recovery logic intended to preserve the previous application container and attempt recovery when candidate deployment or production health checks fail.

### Failure-path mock tests — October 26, 2026

The extracted deployment shell script was checked with `bash -n`; the documented extracted script contained 140 lines and passed syntax validation.

Three isolated mock scenarios were tested:

1. A new production container failed to start, causing the script to attempt starting the previous rollback container.
2. The candidate health check passed, but the production health check failed; rollback was attempted and its mocked health check passed.
3. Both production and rollback health checks failed, resulting in critical recovery messages and a non-zero exit status.

A subsequent read-only SSH check recorded production image `:51` running and `/health` returning a healthy response.

### Supplementary recovery-branch mocks — October 27, 2026

Three further isolated mock scenarios covered:

- Missing rollback and original production containers after a container rename.
- Missing rollback container while the original production container was present, running, and healthy.
- Missing rollback container while the original production container was stopped, followed by a mocked start and successful running-state and application-health checks.

The mocks exercised the relevant recovery branches and expected error handling.

### What is and is not verified

**Verified in the documented tests:**

- Shell syntax validation for the extracted script.
- Mocked failure-path command flow.
- Mocked recovery-branch handling.
- Non-zero exit behavior for failed deployment scenarios.

**Not yet verified by these mock tests:**

- Real Docker state transitions during an actual failed production deployment.
- Actual rollback recovery in the running production environment.
- Restored-container health under real failure conditions.
- Recovery of application traffic after a production switch or failure.

Docker was also reported to have no native health check configured for the production container; application health was checked separately through `/health`.

Mock tests are useful evidence, but they are not a substitute for a controlled real rollback test.

## 14. Validation Evidence

The following table summarizes the documented evidence and its scope.

| Component | Documented evidence | Scope or limitation |
|---|---|---|
| Flask application | Three pytest tests passed | Covers the listed application tests |
| GitHub webhook | Successful push delivery and automatic job triggers | Build `#48` recorded as successful |
| Jenkins CI/CD | Successful build and deployment evidence | Recheck latest build before claiming current status |
| Docker/ECR | Versioned images and healthy application endpoint | Check current image and container state |
| Ansible | Dedicated Jenkins job passed connectivity and health/disk validation | Applies to the tested Docker server |
| EKS/ALB | Two replicas, two healthy targets, HTTP 200 endpoints | Historical validation; recheck current state |
| Prometheus rules | Four production rules passed rule checks and synthetic tests | Does not establish real host-failure behavior |
| Gmail notifications | Firing and resolved test notifications received | Does not prove each production alert's live delivery |
| Rollback | Six isolated mock scenarios across failure and recovery branches | Real rollback and traffic recovery remain unverified |
| Terraform | October 27 refresh plan reported no changes | Does not prove zero AWS charges |
| Cost review | Cost Explorer audit was reviewed | Actual savings from cleanup or optimization must be established separately |

Keep dated build logs, test output, screenshots, and command output as supporting evidence. Remove credentials and sensitive infrastructure details before sharing logs publicly.

## 15. Security Practices

Security controls and practices documented in the project include:

- Run the application container as a non-root user.
- Use Kubernetes security settings that restrict privilege escalation and drop capabilities.
- Store secrets in Jenkins credentials or appropriate secret-management systems.
- Do not commit private keys, passwords, SMTP credentials, tokens, or cloud credentials.
- Restrict SSH access to trusted sources.
- Use least-privilege IAM permissions.
- Preserve SSH host-key verification.
- Restrict access to the Jenkins UI and administrative interfaces.
- Review Terraform plans before infrastructure changes.
- Keep Terraform state and saved plans out of public source control unless explicitly reviewed and approved.
- Review logs before publishing them because they may contain internal addresses, account identifiers, or other sensitive details.

## 16. Cost Management

AWS resources used by this project may incur charges even when no new application deployment is running.

Resources to review include:

- EC2 instances.
- EKS cluster and worker nodes.
- Application Load Balancers.
- NAT Gateways and associated data processing.
- EBS volumes and snapshots.
- Elastic IP addresses.
- CloudWatch log groups and ingestion.
- Other provisioned networking and monitoring resources.

### Cost audit findings

The October 2026 Cost Explorer review recorded an estimated total of approximately **$51.95 for October 1–26, including $7.92 in tax**.

The recorded service breakdown was:

| Service category | Approximate recorded cost |
|---|---:|
| EC2 Compute | $20.04 |
| Elastic Load Balancing | $8.58 |
| Amazon EKS | $5.97 |
| EC2 Other | $5.94 |
| Amazon VPC | $3.49 |
| Amazon ECR | $0.003 |
| Amazon S3 | $0.0007 |

These are historical estimated figures from the documented audit, not a current invoice or a forecast of future charges. The listed categories may not sum exactly to the total because of rounding, taxes, and other billing details.

### Cost optimization procedure

1. Identify which resources are still required for project demonstrations.
2. Inspect current AWS resources and Cost Explorer.
3. Check for unnecessary NAT Gateways, load balancers, EC2 instances, EKS node groups, unattached volumes, and unused Elastic IPs.
4. Generate and review a fresh Terraform plan if Terraform-managed infrastructure is to be removed.
5. Obtain explicit confirmation before destructive operations.
6. Preserve required Terraform state and project evidence.
7. Verify resource deletion and remaining billable resources.
8. Recheck Cost Explorer after billing data updates.

The cost audit has been documented, but do not claim a specific cost saving unless the resource changes and resulting billing impact have been verified.

## 17. Current Project Status

Based on the recorded findings, the project has evidence for:

- Flask API and unit tests.
- GitHub webhook integration.
- Jenkins CI/CD and Docker/ECR publishing.
- Remote Docker deployment and health checks.
- Ansible post-deployment validation.
- Historical EKS/ALB deployment validation.
- Prometheus production rule checks and synthetic tests.
- Gmail firing and resolved test notifications.
- Isolated rollback failure-path and recovery-branch mocks.
- Terraform refresh planning and cost review.

The following distinctions remain important:

- Historical deployment success does not establish current infrastructure availability.
- Synthetic alert tests do not prove real host-failure detection or per-alert email delivery.
- Mock rollback tests do not establish real Docker rollback or traffic recovery.
- A no-change Terraform plan does not establish that AWS resources have no ongoing cost.
- A completed cost audit does not, by itself, demonstrate actual savings.


## 18. Troubleshooting

### Application health check fails

Check the container and logs:

```bash
sudo docker ps
sudo docker logs <container-name>
curl -i http://127.0.0.1:9090/health
```

Confirm the port mapping, application process, and environment configuration.

### Jenkins deployment fails

Review the console output for the failing stage. Check Git checkout, test results, ECR authentication, image push, SSH access, candidate health checks, and production health checks.

Do not rerun a failed production deployment repeatedly without reviewing the current container state and available recovery artifacts.

### Ansible connectivity fails

Verify the inventory, SSH user, private-key permissions, network access, and SSH host-key configuration. Test connectivity before running the validation playbooks.

### EKS application is unavailable

Inspect cluster and deployment state using the appropriate AWS credentials and Kubernetes context. Check pod readiness, events, service endpoints, ingress configuration, ALB target health, and security-group rules.

### Prometheus alerts or Gmail notifications fail

Validate the Prometheus rules and Alertmanager configuration. Check target availability, rule evaluation, alert routing, SMTP connectivity, and sanitized service logs. Never expose email credentials in command output or GitHub.

### Terraform plan differs from expectations

Confirm the working directory, workspace, backend, state, and AWS credentials. Refresh and review the plan before making changes. Never use an old destroy plan as a substitute for a current review.

---

## Project Repository

GitHub: https://github.com/Ayushgautam2007/Devops-Project

**Documentation principle:** Report what was tested, retain the supporting evidence, distinguish historical results from current state, and clearly identify any unverified behavior.
