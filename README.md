# DevOps Capstone Project — CI/CD, AWS, Kubernetes & Monitoring

> An end-to-end DevOps capstone project demonstrating automated testing, containerization, CI/CD, infrastructure as code, Kubernetes deployment, monitoring, and recovery planning.

**Repository:** [Ayushgautam2007/Devops-Project](https://github.com/Ayushgautam2007/Devops-Project)  
**AWS Region:** `ap-south-1` (Mumbai)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Architecture](#architecture)
4. [Technology Stack](#technology-stack)
5. [Application API](#application-api)
6. [Jenkins CI/CD Pipeline](#jenkins-cicd-pipeline)
7. [Docker and Amazon ECR](#docker-and-amazon-ecr)
8. [Ansible Validation](#ansible-validation)
9. [Terraform Infrastructure](#terraform-infrastructure)
10. [Amazon EKS and Kubernetes](#amazon-eks-and-kubernetes)
11. [Monitoring and Alerting](#monitoring-and-alerting)
12. [Rollback and Recovery](#rollback-and-recovery)
13. [Challenges and Solutions](#challenges-and-solutions)
14. [Validation Results](#validation-results)
15. [Security and Cost Considerations](#security-and-cost-considerations)
16. [Repository Structure](#repository-structure)
17. [Documentation and Screenshots](#documentation-and-screenshots)
18. [Future Improvements](#future-improvements)

---

## 1. Project Overview

This project demonstrates an end-to-end DevOps workflow for a containerized Flask REST API. It integrates source control, automated testing, Docker image builds, Amazon Elastic Container Registry (ECR), Jenkins CI/CD, Docker-host deployment, Ansible validation, Terraform, Amazon EKS, Kubernetes, AWS Application Load Balancer (ALB), Prometheus, Grafana, and Alertmanager.

The project demonstrates how application delivery, infrastructure provisioning, health checks, monitoring, and recovery procedures can be organized into a repeatable workflow.

**Important:** The Docker-host deployment and Kubernetes/EKS deployment are separate deployment paths. Their image versions and health checks must be verified independently.

## 2. Key Features

- Jenkins CI/CD pipeline for checkout, testing, image build, and deployment
- GitHub push webhook integration and build-cause verification
- Automated Python testing with `pytest`
- Docker containerization and Amazon ECR image publishing
- Application health-check validation
- Ansible post-deployment validation
- Terraform-based AWS infrastructure configuration
- Amazon EKS and Kubernetes deployment
- Kubernetes Deployment, Service, and Ingress resources
- AWS Load Balancer Controller and ALB integration
- Prometheus targets and alert rules
- Grafana infrastructure dashboards
- Alertmanager email receiver and routing configuration
- Jenkins rollback and recovery logic
- AWS resource inventory and cost-awareness checks

## 3. Architecture

```text
                 Developer
                     |
                     v
              GitHub Repository
                     |
               Push / Webhook
                     |
                     v
                Jenkins CI/CD
                     |
          +----------+-----------+
          |          |           |
          v          v           v
       Checkout    pytest    Docker Build
                                 |
                                 v
                            Amazon ECR
                                 |
                                 v
                       Docker Application Host
                                 |
                      Health Check + Ansible
                                 |
                                 v
                       Deployment Validation


          Separate Infrastructure / Kubernetes Path

                         Terraform
                             |
                             v
                    AWS VPC and Networking
                             |
                             v
                         Amazon EKS
                             |
                             v
                    Kubernetes Deployment
                             |
                             v
                     Application Pods
                             |
                             v
                    Kubernetes Service
                             |
                             v
                       ALB Ingress
                             |
                             v
                         Flask API


                       Monitoring Stack

                    Node Exporter
                         |
                         v
                     Prometheus
                      /       \
                     v         v
                Alert Rules   Grafana
                     |
                     v
                 Alertmanager
                     |
                     v
             Configured Notifications
```

## 4. Technology Stack

| Area | Technology |
|---|---|
| Source Control | Git, GitHub |
| CI/CD | Jenkins |
| Application | Python, Flask, Gunicorn |
| Testing | pytest |
| Containerization | Docker |
| Image Registry | Amazon ECR |
| Configuration Management | Ansible |
| Infrastructure as Code | Terraform |
| Orchestration | Kubernetes, Amazon EKS |
| Load Balancing | AWS ALB, AWS Load Balancer Controller |
| Monitoring | Prometheus, Node Exporter, Grafana |
| Alerting | Prometheus Alert Rules, Alertmanager |
| Cloud Platform | Amazon Web Services |

## 5. Application API

The Flask application exposes the following endpoints:

| Endpoint | Purpose | Expected Result |
|---|---|---|
| `/` | Welcome endpoint | Welcome message and application version |
| `/health` | Health check | JSON response indicating healthy status |
| `/api/users` | Sample users API | JSON response containing sample users |

### Health Endpoint Example

```json
{
  "status": "healthy"
}
```

### Sample Users Response

The application’s documented sample data includes Ayush and DevOps. The exact JSON response should be verified against the current application implementation.

The Dockerfile uses `python:3.12-slim`, runs Gunicorn on container port `8080`, and uses a non-root application user named `appuser` with UID `10001`.

## 6. Jenkins CI/CD Pipeline

The Jenkins pipeline automates application delivery through the following stages:

1. **Checkout:** Retrieve source code from GitHub.
2. **Automated Tests:** Execute the Python test suite using `pytest`.
3. **Build and Push:** Build the Docker image and push it to Amazon ECR.
4. **Deploy:** Pull and start the selected image on the Docker application host.
5. **Health Validation:** Verify application health after deployment.
6. **Ansible Validation:** Run host, disk, Docker, and application checks.
7. **Recovery Handling:** Use the configured recovery logic if deployment validation fails.

### Recorded Jenkins Build #54

Build #54 was recorded as successful on October 27, 2026.

| Check | Recorded Result |
|---|---|
| Jenkins Build | `SUCCESS` |
| Automated Tests | 3 passed |
| Docker Image Tag | `54` |
| Previous Production Container | Preserved as `flask-api-rollback-54` |
| Ansible Validation | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |

Recorded source commit:

`3ff0c70e00fe417f6ad7eeca57540c51946c7ef2`

Commit message:

`fix(k8s): align deployment image tag with live version`

Webhook delivery, Jenkins trigger configuration, and an individual build's cause are separate checks. The recorded evidence included GitHub push-trigger evidence for `Webhook-Test` and GitHub push-cause metadata for `Testing` Build #54.

## 7. Docker and Amazon ECR

Docker packages the application and runtime dependencies into a container image. Amazon ECR stores images used by the deployment pipeline.

### ECR Repository

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api
```

### Example Image Reference

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:54
```

The recorded ECR repository settings included image scanning on push, AES-256 encryption, and mutable image tags.

Multiple ECR tags were observed associated with the same image digest. Therefore, a tag alone does not prove that the image contents are different.

For better traceability, record both the image tag and image digest for each release.

## 8. Ansible Validation

Ansible is used for post-deployment checks on the Docker application host.

### Playbooks

- `system_info.yml`
- `docker_health.yml`
- `disk_check.yml`

These playbooks cover host connectivity, system information, Docker/application health, and root filesystem utilization.

The disk-check playbook is configured to fail when root filesystem usage reaches or exceeds 80%.

### Recorded Ansible Result

```text
ok=6 changed=0 unreachable=0 failed=0
```

This result was recorded for Build #54 and indicates that the Ansible run completed without failed or unreachable hosts.

## 9. Terraform Infrastructure

The Terraform working directory used in the documented environment was maintained separately on the Jenkins server:

```text
/var/lib/jenkins/terraform-eks-capstone
```

This separate working directory should not be assumed to be identical to the Terraform files committed to the GitHub repository.

### Infrastructure Components

The Terraform configuration covered:

- AWS provider and version constraints
- Encrypted S3 remote state and state locking
- VPC and public/private subnets
- Internet Gateway and route tables
- NAT Gateway and Elastic IP
- EKS cluster and IAM configuration
- EKS managed node group
- Variables and outputs

The backend configuration uses S3 state encryption and `use_lockfile = true`.

### Recorded Node Group Configuration

| Setting | Value |
|---|---|
| Instance Type | `t3.medium` |
| Disk Size | 20 GB |
| Minimum Size | 1 |
| Desired Size | 2 |
| Maximum Size | 2 |

EKS control-plane logging was enabled for API, audit, and authenticator logs.

A Terraform state listing proves which resources Terraform tracks in that state. It does not independently prove that every resource is currently active in AWS. Live AWS resource status must be checked separately.

## 10. Amazon EKS and Kubernetes

The documented Kubernetes namespace is `devops-capstone`.

The application Deployment, Service, and Ingress are named `devops-flask-api`.

### Recorded Kubernetes Status

- EKS cluster `devops-capstone-eks` reported `ACTIVE`.
- Node group `devops-capstone-nodes` reported `ACTIVE`.
- Two worker nodes were `Ready`.
- Two application pods were running and ready.
- The Deployment reported two desired and two available replicas.
- The ALB Ingress exposed the application over HTTP.

These are recorded inspection results, not a guarantee of current resource status.

### Application Endpoint Validation

The ALB `/health` endpoint returned HTTP 200 with:

```json
{
  "status": "healthy"
}
```

The `/api/users` endpoint also returned HTTP 200 with the expected sample users response.

### Image Version Tracking

The recorded live EKS Deployment used:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:49
```

Jenkins Build #54 deployed tag `54` to the Docker application host.

These are separate deployment records. A successful Docker-host deployment does not prove that EKS is running the same image version.

## 11. Monitoring and Alerting

The monitoring stack includes Prometheus, Node Exporter, Grafana, and Alertmanager.

### Prometheus

The recorded target checks showed the Prometheus and Node Exporter targets as `UP`.

Configured alert rules included:

| Rule | Condition | Duration | Severity |
|---|---|---|---|
| `NodeExporterDown` | Node Exporter target is down | 120 seconds | Critical |
| `HighCPUUsage` | CPU usage exceeds 80% | 5 minutes | Warning |
| `HighMemoryUsage` | Memory usage exceeds 85% | 5 minutes | Warning |
| `LowDiskSpace` | Root filesystem usage exceeds 80% | 5 minutes | Warning |

At the time of the captured alert query, Prometheus returned no active alerts. This reflects the state at that inspection time; it does not mean that no alerts can occur.

### Grafana

Grafana dashboards display infrastructure metrics such as:

- CPU utilization
- System load
- Memory usage
- Root filesystem usage
- Network activity
- Historical metric trends

The recorded health check reported the Grafana database as `ok`.

The configured Prometheus datasource used:

```text
http://prometheus:9090
```

### Alertmanager

Alertmanager was reported ready, with a receiver named `gmail-notifications` and SMTP email-routing configuration. Resolved-alert notifications were also configured.

Configuration evidence shows that an email receiver was configured, but it does not independently prove that an email was successfully delivered or received.

Grafana contact points were separately observed to be empty during the recorded inspection. Grafana contact points and Alertmanager SMTP configuration are different components.

## 12. Rollback and Recovery

The Jenkins pipeline contains recovery logic intended to preserve the previous production container and restore it if a new deployment fails validation.

### Recovery Workflow

1. Preserve the previous production container using a build-specific rollback name.
2. Start the new application container.
3. Validate the candidate deployment using the health endpoint.
4. If deployment or validation fails, remove the failed candidate where appropriate.
5. Restart the preserved rollback container.

For Build #54, the previous production container was recorded as:

```text
flask-api-rollback-54
```

**Testing limitation:** The available evidence confirms successful deployment, preservation of the previous container, and the presence of recovery logic. It does not establish that an intentional failure was injected and a real rollback was successfully executed.

## 13. Challenges and Solutions

### 13.1 Jenkins Docker Deployment Command Failure

**Challenge:** A deployment attempt failed because `docker run` did not receive the required argument, although the image pull had succeeded.

**Investigation:** The failure was isolated to the container-launch command or variable expansion, rather than the preceding image-pull step.

**Operational lesson:** Validate required variables and command arguments before launching a container. A successful image pull alone does not establish a successful deployment.

**Evidence note:** Claim the issue was resolved only if a later verified build confirms that the corrected command ran successfully.

### 13.2 GitHub Webhook Trigger Verification

**Challenge:** A successful webhook delivery response alone did not prove that the main `Testing` pipeline was triggered by a push.

**Investigation:** Webhook delivery records, Jenkins trigger configuration, and build-cause metadata were checked separately.

**Recorded result:** GitHub push-trigger evidence was found for `Webhook-Test`, and Build #54 metadata showed a GitHub push cause for `Testing`.

**Lesson learned:** Verify webhook delivery, job trigger configuration, and individual build cause independently.

### 13.3 Docker-Host and EKS Image-Version Difference

**Challenge:** The Docker-host deployment for Build #54 used tag `54`, while the live EKS Deployment was recorded with tag `49`.

**Investigation:** The image reference in the Kubernetes Deployment was compared with the image tag in Jenkins logs.

**Resolution approach:** Treat Docker-host and EKS as separate deployment targets. Verify the image running on each target and update EKS through the intended release workflow when required.

**Lesson learned:** A successful pipeline for one target does not prove that another environment has been updated.

### 13.4 ECR Tag and Digest Traceability

**Challenge:** Multiple ECR tags were associated with the same image digest.

**Investigation:** ECR image details were checked for tags, digest, and push timestamp.

**Lesson learned:** Record both image tags and digests so releases can be traced to image content instead of relying only on tag names.

### 13.5 Terraform State Versus Live AWS Status

**Challenge:** Terraform state alone cannot establish the current runtime status of every tracked resource.

**Investigation:** Terraform state evidence was compared with direct AWS status checks for EKS, the node group, NAT Gateway, and ALB.

**Lesson learned:** Treat infrastructure configuration, Terraform state, and live resource health as separate types of evidence.

### 13.6 AWS Resource Cost Awareness

**Challenge:** EKS worker nodes, NAT Gateways, ALBs, and Elastic IP allocations may incur ongoing charges.

**Investigation:** AWS resource inventory and status outputs were collected to identify active resources and their associations.

**Operational approach:** Review resource dependencies and usage before making changes. Plan cleanup carefully so that required resources are not removed prematurely.

**Lesson learned:** Cost awareness and resource lifecycle management are part of reliable DevOps operations.

### 13.7 Monitoring Configuration Versus Notification Delivery

**Challenge:** Configured alert rules and an email receiver do not prove that an alert fired or that an email was received.

**Investigation:** Prometheus target status, alert rules, active-alert results, Alertmanager readiness, and Grafana contact points were inspected separately.

**Lesson learned:** An end-to-end notification claim requires evidence that the alert fired, was routed, and was actually received.

## 14. Validation Results

The following results were recorded during the documented inspection period.

| Component | Recorded Evidence |
|---|---|
| Jenkins Build #54 | `SUCCESS` |
| Automated Tests | 3 passed |
| Amazon ECR | Tag `54` and image digest inspected |
| Docker-Host Deployment | Candidate and production health checks passed |
| Ansible | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |
| EKS Cluster | `ACTIVE` |
| EKS Node Group | `ACTIVE` |
| Kubernetes Nodes | Two nodes `Ready` |
| Application Pods | Two pods running and ready |
| ALB Endpoints | `/health` and `/api/users` returned HTTP 200 |
| Prometheus | Configured targets reported `UP` |
| Prometheus Alerts | No active alerts at the recorded inspection time |
| Grafana | Health check passed; Prometheus datasource configured |
| Alertmanager | Reported ready; email receiver configuration inspected |
| Recovery Mechanism | Previous container preservation and recovery logic reviewed |

These are historical inspection results, not guarantees of the current state. Resource states, image versions, and metrics can change after subsequent deployments or infrastructure changes.

## 15. Security and Cost Considerations

- Never commit AWS access keys, secret keys, passwords, SMTP app passwords, private keys, or access tokens.
- Prefer IAM roles and least-privilege permissions.
- Review screenshots for public IPs, account identifiers, private endpoints, and sensitive infrastructure details before publication.
- Use non-root containers where practical.
- Review Terraform state, Jenkins configuration, and monitoring configuration before making the repository public.
- Consider immutable image references and digest-based deployment traceability.
- EKS worker nodes, NAT Gateway, ALB, and Elastic IP resources may incur ongoing charges.
- Review active resources and their dependencies before making infrastructure changes.
- Remove secrets from Git history if they were ever committed; deleting them from the latest version alone may not be sufficient.

## 16. Repository Structure

The following is a high-level view of the repository. Check the current GitHub tree before adding or removing paths so that this section remains accurate.

```text
Devops-Project/
├── ansible/
├── app/
├── docs/
│   └── capstone-documentation/
├── k8s/
├── terraform/
├── tests/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── Jenkinsfile
├── Jenkinsfile.terraform
└── README.md
```

The Terraform working directory on the Jenkins server is maintained separately at `/var/lib/jenkins/terraform-eks-capstone`; it should not be treated as the same directory as the repository's `terraform/` folder without verification.

## 17. Documentation and Screenshots

Supporting screenshots are organized into the following categories:

- `Architecture/`
- `Jenkins-CICD/`
- `Docker-ECR-Ansible/`
- `EKS-Kubernetes-ALB/`
- `Terraform/`
- `Monitoring-Alerts/`
- `Rollback-Recovery/`
- `AWS-Resources/`

Add links to these folders or individual images only after confirming their actual paths in the repository. Each caption should explain what the screenshot demonstrates and include the build number or inspection date where relevant.

Before publishing screenshots, redact credentials, tokens, private keys, SMTP app passwords, and any infrastructure details that do not need to be public.


## Conclusion

This capstone demonstrates a practical DevOps workflow spanning source control, automated testing, containerization, image publishing, deployment validation, infrastructure as code, Kubernetes orchestration, monitoring, and recovery planning.

The recorded Jenkins Build #54 completed successfully with three passing tests and successful Ansible post-deployment validation. EKS resources and application endpoints were also independently checked during the documented inspection period.

The project emphasizes that reliable delivery requires more than automation. It also requires independent health checks, image-version traceability, monitoring validation, recovery planning, security awareness, and cost-aware infrastructure management.
