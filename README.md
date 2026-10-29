# DevOps Capstone Project — End-to-End CI/CD, AWS, Kubernetes & Monitoring

An end-to-end DevOps capstone project demonstrating automated testing, containerization, CI/CD automation, infrastructure as code, Kubernetes deployment, monitoring, security, and recovery planning.

**Repository:** [Ayushgautam2007/Devops-Project](https://github.com/Ayushgautam2007/Devops-Project)  
**AWS Region:** `ap-south-1` (Mumbai)  
**Application:** Flask REST API  
**Container Registry:** Amazon ECR  
**Orchestration:** Amazon EKS and Kubernetes

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Objectives](#2-project-objectives)
3. [Key Features](#3-key-features)
4. [Architecture Diagrams](#4-architecture-diagrams)
5. [End-to-End Architecture and Workflow](#5-end-to-end-architecture-and-workflow)
6. [Technology Stack](#6-technology-stack)
7. [Application API](#7-application-api)
8. [Jenkins CI/CD Pipeline](#8-jenkins-cicd-pipeline)
9. [Docker and Amazon ECR](#9-docker-and-amazon-ecr)
10. [Ansible Validation](#10-ansible-validation)
11. [Terraform Infrastructure](#11-terraform-infrastructure)
12. [Amazon EKS and Kubernetes](#12-amazon-eks-and-kubernetes)
13. [Monitoring and Alerting](#13-monitoring-and-alerting)
14. [Rollback and Recovery](#14-rollback-and-recovery)
15. [Challenges and Solutions](#15-challenges-and-solutions)
16. [Validation Results](#16-validation-results)
17. [Security Best Practices](#17-security-best-practices)
18. [Cost Management](#18-cost-management)
19. [Repository Structure](#19-repository-structure)
20. [Documentation and Screenshots](#20-documentation-and-screenshots)
21. [Future Improvements](#21-future-improvements)
22. [Conclusion](#22-conclusion)

---

## 1. Project Overview

This project demonstrates an end-to-end DevOps workflow for a containerized Flask REST API.

The project integrates source code management, automated testing, Docker image builds, Amazon Elastic Container Registry (ECR), Jenkins CI/CD, deployment validation, Ansible, Terraform, Amazon EKS, Kubernetes, AWS Application Load Balancer (ALB), Prometheus, Grafana, and Alertmanager.

The primary objective is to automate application delivery, improve deployment reliability, provision infrastructure consistently, monitor application health, and document recovery procedures.

The project contains two separate deployment paths:

1. **Docker-host deployment:** Jenkins builds and publishes an image, deploys it to the Docker application host, validates application health, and performs Ansible checks.
2. **Kubernetes/EKS deployment:** The application runs on Amazon EKS using Kubernetes resources and is exposed through an AWS load balancer.

These deployment paths must be validated independently because a successful Docker-host deployment does not automatically update the EKS application.

## 2. Project Objectives

The main objectives are:

- Implement a CI/CD pipeline using Jenkins and GitHub.
- Automate application testing using pytest.
- Containerize the Flask API using Docker.
- Store and manage container images in Amazon ECR.
- Automate deployment validation with Ansible.
- Provision AWS infrastructure using Terraform.
- Deploy the application on Amazon EKS.
- Configure Kubernetes Deployments, Services, and Ingress.
- Expose the application using an AWS Application Load Balancer.
- Monitor infrastructure metrics using Prometheus and Grafana.
- Configure alert rules and notification routing.
- Document rollback and recovery procedures.
- Maintain GitHub documentation and screenshot evidence.

## 3. Key Features

- GitHub source control and push-triggered Jenkins builds.
- Jenkins pipeline defined as code.
- Automated Python tests.
- Docker image creation and Amazon ECR publishing.
- Application health-check validation.
- Ansible host and application checks.
- Terraform-based infrastructure configuration.
- Amazon EKS managed node groups.
- Kubernetes application Deployment and Service.
- AWS Load Balancer Controller and ALB integration.
- Prometheus monitoring and alert rules.
- Grafana dashboards.
- Alertmanager notification configuration.
- Jenkins deployment recovery logic.
- Infrastructure inventory and cost awareness.
- Architecture diagrams and topic-wise documentation.

---

## 4. Architecture Diagrams

This section contains architecture diagrams for the major components of the capstone.

**Important:** The following image links use the filenames listed in the repository root. They will work while the images remain in that location. If you move an image into a subfolder, update its relative path accordingly.

### 4.1 Overall End-to-End DevOps Architecture

The overall architecture shows the flow from source code to CI/CD, container image publishing, cloud infrastructure, Kubernetes deployment, and monitoring.

![Overall End-to-End DevOps Architecture](<Final Capstone AWS DevOps Architecture.png>)

### 4.2 AWS Resources Architecture

The AWS architecture covers the cloud networking and resource design used by the project, including VPC, subnets, IAM, EKS, ECR, and load balancing.

**Documentation note:** A separate AWS Resources architecture image is not currently listed in the repository root. Add it to `docs/capstone-documentation/AWS-Resources/` before embedding it here.

### 4.3 Docker, ECR and Ansible Architecture

This architecture covers container image creation, ECR publishing, deployment to the Docker application host, and post-deployment validation using Ansible.

**Documentation note:** A separate Docker-ECR-Ansible architecture image is not currently listed in the repository root. Add it to `docs/capstone-documentation/Docker-ECR-Ansible/` when available.

### 4.4 Jenkins CI/CD Architecture

The Jenkins pipeline automates source checkout, testing, Docker image creation, image publishing, deployment, health checks, and recovery handling.

![Jenkins CI/CD Architecture](<Jenkins CI_CD Architecture for EKS.png>)

### 4.5 Amazon EKS, Kubernetes and ALB Architecture

This diagram shows how the application is exposed through a load balancer and served by Kubernetes workloads running on Amazon EKS.

![EKS Kubernetes ALB Architecture](<AWS EKS Kubernetes ALB Architecture Diagram.png>)

### 4.6 Terraform Infrastructure Architecture

Terraform defines and provisions AWS infrastructure, including networking, EKS, IAM, and supporting resources.

![Terraform AWS Infrastructure Architecture](<Terraform AWS Infrastructure Architecture.png>)

### 4.7 Monitoring and Alerts Architecture

The monitoring design includes Prometheus, Node Exporter, Grafana, alert rules, and Alertmanager notification routing.

![Kubernetes Monitoring and Alerts Architecture](<Kubernetes Monitoring & Alerts Architecture.png>)

### 4.8 Rollback and Recovery Architecture

The recovery architecture illustrates application version preservation, rollback procedures, and infrastructure recovery strategies.

![Rollback and Recovery Architecture](<Rollback and Recovery Architecture Infographic.png>)

### 4.9 Final Capstone Architecture and Deployment Flow

The final architecture combines application development, CI/CD, AWS infrastructure, containerization, Kubernetes deployment, monitoring, and recovery planning.

![Final Capstone Architecture](<Final Capstone AWS DevOps Architecture.png>)

---

## 5. End-to-End Architecture and Workflow

The application delivery process follows this workflow:

```text
Developer
    |
    v
GitHub Repository
    |
    | Push / Pull Request / Webhook
    v
Jenkins CI/CD Pipeline
    |
    +----> Source Checkout
    |
    +----> Automated Tests (pytest)
    |
    +----> Docker Image Build
    |
    +----> Image Security Scan
    |
    v
Amazon ECR
    |
    +----------------------------+
    |                            |
    v                            v
Docker Application Host       Amazon EKS
    |                            |
    v                            v
Health Check + Ansible       Kubernetes Deployment
    |                            |
    v                            v
Deployment Validation        Application Pods
                                 |
                                 v
                          Kubernetes Service
                                 |
                                 v
                             ALB Ingress
                                 |
                                 v
                            Flask REST API


Infrastructure Provisioning:

Terraform
    |
    v
AWS VPC and Networking
    |
    +----> IAM
    +----> ECR
    +----> EKS
    +----> Managed Node Group


Monitoring:

Node Exporter / Application Metrics
    |
    v
Prometheus
    |
    +----> Alert Rules
    |
    +----> Grafana Dashboards
    |
    v
Alertmanager
    |
    v
Configured Notifications
```

### Workflow explanation

1. A developer pushes application changes to GitHub.
2. The configured GitHub webhook triggers the Jenkins pipeline.
3. Jenkins checks out the source code.
4. Automated tests validate application behavior.
5. Docker builds the application image.
6. The pipeline scans and publishes the image to Amazon ECR when those stages are configured.
7. The Docker-host deployment path performs deployment and health validation.
8. The separate EKS deployment path runs the selected image using Kubernetes resources.
9. The AWS load balancer provides external access to the application.
10. Prometheus and Grafana support monitoring, while configured alerting components handle notifications.
11. Recovery procedures help restore a known-good application version when deployment validation fails.

The exact execution order depends on the stages implemented in the current Jenkinsfile.

---

## 6. Technology Stack

| Area | Technology |
|---|---|
| Source Control | Git, GitHub |
| CI/CD | Jenkins |
| Application | Python, Flask, Gunicorn |
| Testing | pytest |
| Containerization | Docker |
| Container Registry | Amazon ECR |
| Configuration Management | Ansible |
| Infrastructure as Code | Terraform |
| Cloud Platform | AWS |
| Orchestration | Kubernetes, Amazon EKS |
| Load Balancing | AWS ALB, AWS Load Balancer Controller |
| Monitoring | Prometheus, Node Exporter, Grafana |
| Alerting | Prometheus Alert Rules, Alertmanager |
| Operating System | Linux |
| Documentation | GitHub Markdown, PNG screenshots |

---

## 7. Application API

The project uses a Flask REST API.

### API endpoints

| Endpoint | Purpose | Expected Result |
|---|---|---|
| `/` | Welcome endpoint | Application welcome message and version |
| `/health` | Health endpoint | JSON health status |
| `/api/users` | Sample users API | JSON response containing sample users |

### Health endpoint example

```json
{
  "status": "healthy"
}
```

### Test the application

Run the application using your configured local environment, then execute:

```bash
curl -i http://localhost:8080/health
curl -i http://localhost:8080/api/users
```

Expected result: HTTP 200 for the configured endpoints.

If the application is running on a different port, change the URL accordingly.

The documented Docker image uses Python 3.12 slim, Gunicorn on container port `8080`, and a non-root application user named `appuser` with UID `10001`. Verify these settings against the current Dockerfile before treating them as the live configuration.

---

## 8. Jenkins CI/CD Pipeline

Jenkins automates application delivery and deployment validation.

### Pipeline stages

1. **Checkout:** Retrieve source code from GitHub.
2. **Test:** Run automated tests using pytest.
3. **Build:** Create a Docker image.
4. **Security Scan:** Scan the image if the scanning stage is configured.
5. **Publish:** Push the image to Amazon ECR.
6. **Deploy:** Deploy the selected image to the configured Docker application host.
7. **Health Check:** Validate the application endpoint.
8. **Ansible Validation:** Run host, Docker, disk, and application checks.
9. **Recovery:** Execute configured recovery logic when deployment validation fails.

### Recorded Jenkins Build #54

The existing project documentation records the following result for Build #54 on October 27, 2026.

| Item | Recorded Result |
|---|---|
| Jenkins Build | `SUCCESS` |
| Automated Tests | 3 passed |
| Docker Image Tag | `54` |
| Previous Production Container | `flask-api-rollback-54` |
| Ansible | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |

Recorded source commit:

```text
3ff0c70e00fe417f6ad7eeca57540c51946c7ef2
```

Commit message:

```text
fix(k8s): align deployment image tag with live version
```

These results are historical evidence. New pipeline runs should be checked independently.

### GitHub webhook validation

To validate webhook automation:

1. Open the GitHub repository.
2. Open Settings → Webhooks.
3. Inspect the webhook delivery history.
4. Confirm that Jenkins received the push event.
5. Open the corresponding Jenkins job.
6. Inspect the build cause to verify that the build was triggered by the GitHub push.

A successful webhook HTTP response alone does not prove that the intended Jenkins job ran.

---

## 9. Docker and Amazon ECR

Docker packages the application and its runtime dependencies into a container image. Amazon ECR stores images for deployment.

### ECR repository

The existing project documentation records this repository:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api
```

### Example image reference

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:54
```

### Docker validation

Build the image using the repository's actual Dockerfile:

```bash
docker build -t devops-flask-api:local .
```

Run the container:

```bash
docker run -d \
  --name devops-flask-api-test \
  -p 8080:8080 \
  devops-flask-api:local
```

Validate the endpoint:

```bash
curl -i http://localhost:8080/health
```

Inspect the container:

```bash
docker ps
docker logs devops-flask-api-test
```

After testing, remove the temporary container:

```bash
docker rm -f devops-flask-api-test
```

### Amazon ECR considerations

The recorded ECR configuration included image scanning on push, AES-256 encryption, and mutable tags.

For better release traceability:

- Use unique image tags for releases.
- Record image digests.
- Prefer digest-based deployment where appropriate.
- Scan images before deployment.
- Avoid relying on `latest` as the only version identifier.

A tag does not guarantee unique image contents. Compare image digests to verify whether two tags reference the same image.

---

## 10. Ansible Validation

Ansible performs post-deployment validation on the Docker application host.

### Documented playbooks

```text
system_info.yml
docker_health.yml
disk_check.yml
```

These playbooks cover:

- Host connectivity and system information.
- Docker and application health.
- Root filesystem utilization.
- Validation of configured operational thresholds.

The recorded disk-check configuration fails when root filesystem usage reaches or exceeds 80%.

### Recorded result

```text
ok=6 changed=0 unreachable=0 failed=0
```

This result was recorded for Jenkins Build #54.

A successful Ansible run indicates that the tasks completed without failed or unreachable hosts. It does not by itself prove that every application feature is working.

---

## 11. Terraform Infrastructure

Terraform is used to manage the AWS infrastructure as code.

### Documented Terraform working directory

The Jenkins server's Terraform working directory was recorded as:

```text
/var/lib/jenkins/terraform-eks-capstone
```

This directory is separate from the repository's `terraform/` directory unless the current configuration explicitly connects them.

### Infrastructure components

The documented configuration covered:

- AWS provider and version constraints.
- Encrypted S3 remote state.
- S3 state locking using `use_lockfile = true`.
- VPC and public/private subnets.
- Internet Gateway and route tables.
- NAT Gateway and Elastic IP.
- EKS cluster and IAM configuration.
- EKS managed node group.
- Terraform variables and outputs.

### Recorded node group settings

| Setting | Value |
|---|---|
| Instance type | `t3.medium` |
| Disk size | 20 GB |
| Minimum nodes | 1 |
| Desired nodes | 2 |
| Maximum nodes | 2 |

EKS control-plane logging was recorded as enabled for API, audit, and authenticator logs.

### Terraform validation workflow

Run commands from the actual Terraform working directory:

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan
```

Review the plan before applying changes.

**Important:** Do not run `terraform apply` or `terraform destroy` without reviewing the plan, state, dependencies, and potential AWS charges. Terraform state is not proof that every tracked resource is currently active.

---

## 12. Amazon EKS and Kubernetes

The documented Kubernetes namespace is:

```text
devops-capstone
```

The application Deployment, Service, and Ingress are documented as:

```text
devops-flask-api
```

### Recorded EKS status

The project documentation recorded:

- EKS cluster `devops-capstone-eks` as `ACTIVE`.
- Node group `devops-capstone-nodes` as `ACTIVE`.
- Two worker nodes in `Ready` state.
- Two application Pods running and ready.
- Two desired and available Deployment replicas.
- An ALB Ingress exposing the application over HTTP.

These results must be rechecked before reporting the current deployment status.

### Kubernetes validation commands

```bash
kubectl get nodes
kubectl get namespaces
kubectl get pods -n devops-capstone
kubectl get deployments -n devops-capstone
kubectl get services -n devops-capstone
kubectl get ingress -n devops-capstone
```

Check rollout status:

```bash
kubectl rollout status deployment/devops-flask-api \
  -n devops-capstone
```

Inspect application logs:

```bash
kubectl logs deployment/devops-flask-api \
  -n devops-capstone
```

Inspect the Deployment image:

```bash
kubectl get deployment devops-flask-api \
  -n devops-capstone \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
```

### Image version tracking

The documented EKS Deployment used:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:49
```

Jenkins Build #54 deployed tag `54` to the Docker application host.

These are separate deployment records. Verify the actual EKS image before claiming that EKS is running the latest Jenkins build.

### Application endpoint validation

The recorded ALB endpoints returned HTTP 200:

- `/health`
- `/api/users`

For a new validation, obtain the current Ingress hostname:

```bash
kubectl get ingress -n devops-capstone
```

Then test the actual hostname:

```bash
curl -i http://YOUR-ALB-HOSTNAME/health
curl -i http://YOUR-ALB-HOSTNAME/api/users
```

Replace `YOUR-ALB-HOSTNAME` with the real hostname shown by Kubernetes.

---

## 13. Monitoring and Alerting

The monitoring stack includes Prometheus, Node Exporter, Grafana, and Alertmanager.

### Prometheus

Prometheus collects configured metrics and evaluates alert rules.

The documented monitoring targets were reported as `UP` during the recorded inspection.

### Configured alert rules

| Rule | Condition | Duration | Severity |
|---|---|---|---|
| `NodeExporterDown` | Node Exporter target is down | 120 seconds | Critical |
| `HighCPUUsage` | CPU usage exceeds 80% | 5 minutes | Warning |
| `HighMemoryUsage` | Memory usage exceeds 85% | 5 minutes | Warning |
| `LowDiskSpace` | Root filesystem usage exceeds 80% | 5 minutes | Warning |

These are documented thresholds; confirm the actual Prometheus rule expressions before treating them as the current configuration.

### Grafana dashboards

The documented dashboards cover:

- CPU utilization.
- System load.
- Memory usage.
- Root filesystem usage.
- Network activity.
- Historical metric trends.

The configured Prometheus datasource was recorded as:

```text
http://prometheus:9090
```

### Alertmanager

The documented Alertmanager configuration included a receiver named `gmail-notifications` and SMTP email-routing configuration.

A configured receiver does not prove that an email has been delivered. Verify alert firing, routing, SMTP configuration, and actual receipt separately.

The previous inspection also found Grafana contact points empty. Grafana contact points and Alertmanager SMTP configuration are different components.

### Monitoring validation

Verify the following in your environment:

1. Prometheus is reachable.
2. Configured scrape targets are `UP`.
3. Alert rules are loaded.
4. Grafana dashboards display actual metrics.
5. Alertmanager is ready.
6. Test alerts are routed correctly.
7. Notifications are actually received.

---

## 14. Rollback and Recovery

The Jenkins pipeline contains recovery logic intended to preserve the previous production container and restore it if deployment validation fails.

### Documented recovery workflow

1. Preserve the previous production container using a build-specific rollback name.
2. Start the new application container.
3. Validate the candidate deployment using the health endpoint.
4. If deployment or validation fails, remove the failed candidate where appropriate.
5. Restart the preserved rollback container.
6. Validate the restored application.

The previous production container recorded for Build #54 was:

```text
flask-api-rollback-54
```

### Kubernetes rollback

Kubernetes supports Deployment rollout history and rollback:

```bash
kubectl rollout history deployment/devops-flask-api \
  -n devops-capstone
```

If a previous revision exists and is known to be healthy, a rollback can be performed:

```bash
kubectl rollout undo deployment/devops-flask-api \
  -n devops-capstone
```

Verify the result:

```bash
kubectl rollout status deployment/devops-flask-api \
  -n devops-capstone

kubectl get pods -n devops-capstone
```

Run rollback commands only when a suitable previous revision exists and the rollback is appropriate for the environment.

**Testing limitation:** The available documentation confirms the presence of recovery logic and preservation of a previous container. It does not establish that an intentional failure was injected and a real rollback was successfully executed.

Database recovery, infrastructure recreation, and cross-region disaster recovery require separate backup, recovery, and validation procedures.

---

## 15. Challenges and Solutions

### 15.1 Jenkins Docker Deployment Command Failure

**Challenge:** A deployment attempt failed because `docker run` did not receive a required argument, even though the image pull succeeded.

**Investigation:** The failure was associated with the container-launch command or variable expansion.

**Lesson:** Validate required variables and command arguments before launching the container. A successful image pull alone does not prove successful deployment.

### 15.2 GitHub Webhook Trigger Verification

**Challenge:** Successful webhook delivery did not, by itself, prove that the intended Jenkins pipeline was triggered.

**Investigation:** Webhook delivery records, Jenkins trigger configuration, and build-cause metadata were checked separately.

**Recorded result:** Push-trigger evidence was recorded for `Webhook-Test`, and Build #54 metadata showed a GitHub push cause for `Testing`.

**Lesson:** Verify webhook delivery, job configuration, and build cause independently.

### 15.3 Docker-Host and EKS Image-Version Difference

**Challenge:** Build #54 used image tag `54` on the Docker application host, while the recorded EKS Deployment used tag `49`.

**Resolution approach:** Treat these as separate deployment targets and verify the image running on each target.

**Lesson:** A successful Docker-host deployment does not prove that EKS has been updated.

### 15.4 ECR Tag and Digest Traceability

**Challenge:** Multiple image tags were observed with the same image digest.

**Lesson:** Record image tags and digests to trace deployments to their actual image contents.

### 15.5 Terraform State Versus Live AWS Status

**Challenge:** Terraform state alone does not establish current resource health.

**Lesson:** Compare Terraform configuration and state with direct AWS resource status checks.

### 15.6 AWS Resource Cost Awareness

**Challenge:** EKS worker nodes, NAT Gateways, ALBs, and Elastic IP allocations may incur ongoing charges.

**Lesson:** Review active resources and dependencies before changing or deleting infrastructure.

### 15.7 Monitoring Configuration Versus Notification Delivery

**Challenge:** A configured alert rule and email receiver do not prove that an alert fired or an email was received.

**Lesson:** Test alert firing, routing, and actual notification delivery separately.

---

## 16. Validation Results

The following results were recorded during the documented inspection period.

| Component | Recorded Evidence |
|---|---|
| Jenkins Build #54 | `SUCCESS` |
| Automated tests | 3 passed |
| Amazon ECR | Tag `54` and image digest inspected |
| Docker-host deployment | Candidate and production health checks passed |
| Ansible | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |
| EKS cluster | `ACTIVE` |
| EKS node group | `ACTIVE` |
| Kubernetes nodes | Two nodes `Ready` |
| Application Pods | Two Pods running and ready |
| ALB endpoints | `/health` and `/api/users` returned HTTP 200 |
| Prometheus | Configured targets reported `UP` |
| Prometheus alerts | No active alerts at the recorded inspection time |
| Grafana | Health check passed; Prometheus datasource configured |
| Alertmanager | Reported ready; email receiver configuration inspected |
| Recovery mechanism | Previous container preservation and recovery logic reviewed |

These results are historical and must not be interpreted as a guarantee of current resource status.

For final submission, update this table only after repeating the relevant checks and collecting current evidence.

---

## 17. Security Best Practices

- Never commit AWS access keys, passwords, private keys, SMTP app passwords, or access tokens.
- Prefer IAM roles and least-privilege permissions.
- Use Kubernetes RBAC to restrict access.
- Store sensitive application values in an appropriate secrets-management solution.
- Scan Docker images before release.
- Use non-root containers where practical.
- Review Jenkins credentials and permissions.
- Avoid exposing internal services unnecessarily.
- Review screenshots for sensitive account and infrastructure information.
- Consider immutable image tags and digest-based deployments.
- Remove committed secrets from Git history if they were ever exposed.
- Keep Terraform state encrypted and restrict access to it.

Before publishing the repository, inspect the complete commit history for credentials or secrets.

## 18. Cost Management

AWS resources can continue to incur charges even when application development has stopped.

Potential cost-generating resources include:

- EKS control plane.
- EC2 worker nodes.
- NAT Gateways.
- Application Load Balancers.
- Elastic IP addresses.
- EBS volumes.
- CloudWatch logs and metrics.
- Container image storage in ECR.

### Cost-control practices

1. Check active AWS resources regularly.
2. Review AWS billing and Cost Explorer.
3. Remove unused resources only after verifying dependencies.
4. Preserve Terraform state and required documentation.
5. Use appropriate development-environment capacity.
6. Verify that load balancers, NAT Gateways, and EKS resources are no longer needed before removing them.

Do not run `terraform destroy` without reviewing the plan and understanding the consequences.

## 19. Repository Structure

The following structure represents the documented repository and the intended organization of its supporting documentation. Verify each file against the current GitHub repository.

```text
Devops-Project/
├── ansible/
├── app/
├── docs/
│   └── capstone-documentation/
│       ├── AWS-Resources/
│       ├── Architecture/
│       ├── Docker-ECR-Ansible/
│       ├── EKS-Kubernetes-ALB/
│       ├── Jenkins-CICD/
│       ├── Monitoring-Alerts/
│       ├── Rollback-Recovery/
│       └── Terraform/
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

The documented Terraform working directory on the Jenkins server is:

```text
/var/lib/jenkins/terraform-eks-capstone
```

It should not be assumed to be identical to the repository's `terraform/` directory without verification.

### Root architecture image files

The following image filenames were listed in the repository root during the documented inspection:

```text
AWS EKS Kubernetes ALB Architecture Diagram.png
Final Capstone AWS DevOps Architecture.png
Jenkins CI_CD Architecture for EKS.png
Kubernetes Monitoring & Alerts Architecture.png
Rollback and Recovery Architecture Infographic.png
Terraform AWS Infrastructure Architecture.png
```

The README uses these existing filenames for its architecture images. Move them into the documentation folders only if you also update the image paths.

---

## 20. Documentation and Screenshots

The project documentation is organized by topic:

| Folder | Evidence to include |
|---|---|
| `Architecture/` | Overall architecture and final workflow |
| `AWS-Resources/` | AWS resource inventory and networking |
| `Docker-ECR-Ansible/` | Docker build, ECR image and Ansible validation |
| `Jenkins-CICD/` | Pipeline stages, successful builds and webhook evidence |
| `EKS-Kubernetes-ALB/` | Cluster, nodes, Pods, Service and Ingress |
| `Terraform/` | Formatting, validation, plan and resource outputs |
| `Monitoring-Alerts/` | Prometheus targets, Grafana dashboards and alert tests |
| `Rollback-Recovery/` | Previous image, rollback procedure and recovery validation |

### Recommended evidence filenames

```text
snapshots/
├── 01-github/
│   ├── repository-structure.png
│   └── commit-history.png
├── 02-application-tests/
│   └── pytest-passed.png
├── 03-docker/
│   ├── docker-build.png
│   └── container-health.png
├── 04-jenkins/
│   ├── pipeline-success.png
│   └── webhook-trigger.png
├── 05-ecr/
│   └── image-tag-and-digest.png
├── 06-terraform/
│   ├── terraform-validate.png
│   └── terraform-plan.png
├── 07-eks/
│   ├── cluster-status.png
│   └── nodegroup-status.png
├── 08-kubernetes/
│   ├── pods-running.png
│   └── deployment-rollout.png
├── 09-load-balancer/
│   └── application-health.png
├── 10-monitoring/
│   └── grafana-dashboard.png
├── 11-security/
│   └── image-scan-results.png
└── 12-final-validation/
    └── end-to-end-success.png
```

These are recommended evidence filenames. Create and commit each screenshot only after capturing the corresponding real result.

Redact credentials, tokens, private keys, SMTP app passwords, and sensitive infrastructure information before publishing screenshots.

---

## 21. Future Improvements

Potential improvements for future iterations include:

- Stronger automated code-quality checks.
- Automated image vulnerability scanning and security gates.
- Image digest-based release traceability.
- A unified CI/CD workflow for the EKS deployment path.
- Helm-based deployment management.
- Tested Kubernetes rollback procedures.
- End-to-end alert notification tests.
- Application-level metrics and dashboards.
- More restrictive IAM and Kubernetes RBAC policies.
- Automated post-deployment smoke tests.
- Documented backup and recovery testing.
- AWS resource inventory and cost monitoring.
- Automated cleanup of temporary development resources.

These improvements should be marked as completed only when implemented and supported by evidence.

## 22. Conclusion

This capstone demonstrates a practical DevOps workflow spanning source control, automated testing, containerization, image publishing, deployment validation, infrastructure as code, Kubernetes orchestration, monitoring, and recovery planning.

The documented Jenkins Build #54 completed successfully with three passing tests and successful Ansible post-deployment validation. EKS resources and application endpoints were also independently checked during the documented inspection period.

The project emphasizes that reliable delivery requires more than automation. It also requires independent health checks, image-version traceability, monitoring validation, recovery planning, security awareness, and cost-aware infrastructure management.

**Final submission note:** The architecture diagrams, configuration files, screenshots, and validation results should accurately represent the implementation. Distinguish completed features from planned improvements and historical results from current verification.
