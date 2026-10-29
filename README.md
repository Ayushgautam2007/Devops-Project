# DevOps Capstone Project — End-to-End CI/CD, AWS, Kubernetes & Monitoring

## Project Overview

This project demonstrates an end-to-end DevOps workflow for a containerized Flask REST API. It integrates source-code management, automated testing, container image building, Amazon ECR, Jenkins CI/CD, Docker deployment, Ansible validation, Terraform infrastructure provisioning, Amazon EKS, Kubernetes, AWS Application Load Balancer, Prometheus, Grafana, and Alertmanager.

The objective is to automate application delivery, validate deployments, monitor application infrastructure, and document recovery mechanisms while maintaining visibility into AWS resource usage and operational costs.

**Repository:** [Ayushgautam2007/Devops-Project](https://github.com/Ayushgautam2007/Devops-Project)

**AWS Region:** `ap-south-1` (Mumbai)

## Key Features

- Automated CI/CD pipeline using Jenkins
- GitHub push webhook integration
- Automated Python application tests using pytest
- Docker image build and publishing to Amazon ECR
- Container deployment with health-check validation
- Ansible-based post-deployment checks
- Terraform configuration for AWS networking and EKS resources
- Kubernetes Deployment, Service and Ingress
- AWS Application Load Balancer integration
- Prometheus metrics collection and alert rules
- Grafana dashboards for infrastructure monitoring
- Alertmanager email-routing configuration
- Jenkins rollback and recovery logic
- AWS resource inventory and cost-awareness checks

## Architecture

```text
Developer
   |
   v
GitHub Repository
   |
   | Push event / Webhook
   v
Jenkins CI/CD Pipeline
   |
   +--> Checkout Source Code
   |
   +--> Run pytest
   |
   +--> Build Docker Image
   |
   +--> Push Image to Amazon ECR
   |
   +--> Deploy to Docker Application Server
   |
   +--> Validate Deployment Health
   |
   +--> Run Ansible Post-Deployment Checks
   |
   v
Application Deployment

Infrastructure Deployment Path:
Terraform --> AWS VPC / Networking / EKS
                         |
                         v
                   Kubernetes
                         |
                Deployment / Pods
                         |
                    Service
                         |
                 ALB Ingress
                         |
                         v
                    Flask API

Monitoring Path:
Node Exporter / Prometheus
             |
             +--> Alert Rules --> Alertmanager
             |
             +--> Grafana Dashboards
```

The Docker-host deployment and the Kubernetes/EKS deployment are separate deployment paths. Their image versions and deployment results should be verified independently.

## Technology Stack

| Category | Technologies |
|---|---|
| Source control | Git, GitHub |
| CI/CD | Jenkins |
| Application | Python, Flask, Gunicorn |
| Testing | pytest |
| Containers | Docker |
| Container registry | Amazon ECR |
| Infrastructure as Code | Terraform |
| Configuration management | Ansible |
| Container orchestration | Kubernetes, Amazon EKS |
| Networking and ingress | AWS VPC, Application Load Balancer, AWS Load Balancer Controller |
| Monitoring | Prometheus, Node Exporter, Grafana |
| Alerting | Prometheus alert rules, Alertmanager |
| Cloud platform | AWS |
| Operating systems | Amazon Linux 2023 and Linux |

## Application Details

The project contains a Flask REST API with the following endpoints:

| Endpoint | Purpose | Expected response |
|---|---|---|
| `/` | Application welcome endpoint | Welcome message and version |
| `/health` | Health-check endpoint | `{"status":"healthy"}` |
| `/api/users` | Sample users API | JSON containing Ayush and DevOps |

Example health-check response:

```json
{
  "status": "healthy"
}
```

Example API response:

```json
{
  "users": [
    {
      "id": 1,
      "name": "Ayush"
    },
    {
      "id": 2,
      "name": "DevOps"
    }
  ]
}
```

The Docker image uses `python:3.12-slim` and runs the application as a non-root user (`appuser`, UID `10001`). Gunicorn serves the application on container port `8080`.

## Jenkins CI/CD Pipeline

The Jenkins pipeline automates the application delivery workflow.

### Pipeline stages

1. **Checkout:** Retrieves the source code and pipeline definition from GitHub.
2. **Automated Tests:** Runs pytest to validate application behavior.
3. **Build and Push to ECR:** Builds the Docker image and pushes it to Amazon ECR.
4. **Deploy to Docker Server:** Pulls the selected image and deploys the application container.
5. **Health Validation:** Verifies that the deployed application responds successfully.
6. **Ansible Post-Deployment Validation:** Runs infrastructure and Docker health checks on the application server.
7. **Recovery Handling:** Uses the configured rollback logic if deployment or health validation fails.

### Verified Jenkins Build #54

Build #54 completed successfully on October 27, 2026.

| Verification | Result |
|---|---|
| Jenkins build result | `SUCCESS` |
| Automated tests | 3 passed |
| ECR image tag | `54` |
| Previous production container | Preserved as `flask-api-rollback-54` |
| Ansible validation | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |
| Pipeline completion | Successful |

Build #54 checked out commit `3ff0c70e00fe417f6ad7eeca57540c51946c7ef2`, with commit message `fix(k8s): align deployment image tag with live version`.

GitHub push-trigger evidence and Jenkins build-cause metadata were also inspected to distinguish webhook-triggered builds from manually started builds.

## Docker and Amazon ECR

Docker packages the Flask application and its runtime dependencies into a container image.

The Amazon ECR repository is:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api
```

The pipeline uses build-number-based image tags, allowing individual builds to be referenced in deployment and troubleshooting records.

Example image reference:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:54
```

The repository was configured with image scanning on push enabled, AES-256 encryption, and mutable tags at the time of inspection.

**Image traceability note:** ECR inspection showed multiple tags associated with the same image digest. Therefore, a tag name alone does not necessarily prove that two deployments are running different image contents. The image digest should also be compared when verifying versions.

## Ansible Configuration and Validation

Ansible is used for post-deployment validation of the Docker application server.

The documented playbooks include:

- `system_info.yml`
- `docker_health.yml`
- `disk_check.yml`

The validation workflow checks host connectivity, Docker/application health, and disk utilization. The disk validation playbook is configured to fail when root filesystem usage reaches or exceeds 80%.

The Jenkins Build #54 post-deployment validation completed with:

```text
ok=6
changed=0
unreachable=0
failed=0
```

This indicates that the recorded Ansible validation completed without failures or unreachable hosts.

## Terraform Infrastructure as Code

Terraform configuration is maintained separately in the `terraform-eks-capstone` working directory on the Jenkins server.

The configuration is split across multiple `.tf` files rather than a single `main.tf`.

Documented configuration includes:

- AWS provider and version constraints
- Remote Terraform state in an encrypted S3 backend
- VPC and subnet resources
- Internet Gateway and route tables
- NAT Gateway and Elastic IP resources
- EKS cluster and IAM configuration
- EKS managed node group
- Input variables and output values

The S3 backend configuration uses state locking through `use_lockfile = true`.

The EKS configuration enables API, audit, and authenticator control-plane logs. The managed node group is configured with `t3.medium` instances, a 20 GB disk, minimum size 1, desired size 2, and maximum size 2.

Terraform state output was captured as infrastructure-tracking evidence. A Terraform state listing indicates which resources are recorded in state; it does not, by itself, prove that every resource is currently running in AWS.

## Amazon EKS and Kubernetes

The Kubernetes deployment uses the `devops-capstone` namespace.

The documented Kubernetes resources include:

- Deployment: `devops-flask-api`
- Service: `devops-flask-api`
- Ingress: `devops-flask-api`
- Application pods managed by the Deployment
- AWS Load Balancer Controller integration

The EKS cluster was verified as `ACTIVE`, with Kubernetes version `1.37`. The managed node group `devops-capstone-nodes` was also reported as `ACTIVE`.

At the time of the recorded checks:

- Two worker nodes were in `Ready` state.
- Two Flask application pods were `Running` and ready.
- The application Deployment reported 2 desired and 2 available replicas.
- The Kubernetes Service exposed the application internally.
- The ALB Ingress provided external HTTP access to the application.

### Application endpoint verification

The ALB health endpoint returned HTTP 200 with:

```json
{"status":"healthy"}
```

The `/api/users` endpoint also returned HTTP 200 with the expected two-user JSON response.

### Image-version distinction

The recorded EKS Deployment used:

```text
351083991382.dkr.ecr.ap-south-1.amazonaws.com/devops-flask-api:49
```

Jenkins Build #54 deployed image tag `54` to the Docker application host. These are separate deployment records and should not be interpreted as proof that EKS was running tag `54`.

The Kubernetes image tag and application health should be rechecked after any subsequent deployment.

## Prometheus, Grafana and Alertmanager

The monitoring stack includes Prometheus, Node Exporter, Grafana, and Alertmanager.

### Prometheus

Prometheus collects metrics from configured targets. The recorded target checks showed both the Prometheus and Node Exporter targets as `UP`.

The configured alert rules include:

| Alert rule | Condition | Duration | Severity |
|---|---|---|---|
| `NodeExporterDown` | Node Exporter target is down | 120 seconds | Critical |
| `HighCPUUsage` | CPU usage exceeds 80% | 5 minutes | Warning |
| `HighMemoryUsage` | Memory usage exceeds 85% | 5 minutes | Warning |
| `LowDiskSpace` | Root filesystem usage exceeds 80% | 5 minutes | Warning |

At the time of the captured Prometheus alert query, no active alerts were returned. This describes the state at that inspection time, not the absence of all historical incidents.

### Grafana

Grafana provides dashboards for infrastructure metrics, including:

- CPU utilization
- System load
- Memory usage
- Root filesystem usage
- Network activity
- Historical metric trends

The recorded Grafana health check returned a healthy database status. The configured Prometheus datasource uses the internal endpoint `http://prometheus:9090`.

### Alertmanager

Alertmanager was configured with a receiver named `gmail-notifications` and SMTP email routing. The configuration includes resolved-alert notifications.

The recorded Alertmanager status showed the service as ready. Configuration evidence confirms that an email receiver and routing were configured; it does not independently prove successful email delivery.

Grafana contact points were separately observed to be empty during inspection. Grafana contact-point configuration and Alertmanager SMTP configuration are distinct components.

## Rollback and Recovery Strategy

The Jenkins pipeline contains rollback and recovery logic designed to preserve the previous production container and restore it if a new deployment fails validation.

The documented mechanism includes:

1. Preserve the previous production container using a build-specific rollback name.
2. Start the new application container.
3. Validate the candidate deployment using the health endpoint.
4. If deployment or health validation fails, remove the failed candidate where appropriate.
5. Restart the preserved rollback container.

For Build #54, the previous production container was recorded as:

```text
flask-api-rollback-54
```

The build log confirms successful deployment and rollback-container preservation. The recovery logic was reviewed in the Jenkins pipeline source.

**Testing limitation:** The available evidence confirms successful deployment and the presence of recovery logic. It does not establish that an intentional failed deployment was simulated and an actual rollback was successfully executed.

## Challenges and Solutions

This section documents concrete issues and operational considerations encountered during implementation. Each item should be retained only to the extent supported by the corresponding logs, configuration, or verification evidence.

### 1. Jenkins Docker Deployment Failure

**Challenge:** A Jenkins deployment attempt failed when the `docker run` command did not receive the required argument.

**Investigation:** The deployment stage had successfully pulled the image, but the container launch failed. This isolated the failure to the Docker run command or its variable expansion rather than the image pull itself.

**Resolution approach:** Inspect the generated command, quote image and container variables correctly, and verify that all required Docker arguments are present before launching the container.

**Lesson learned:** A successful image pull does not guarantee a successful container deployment. Pipeline stages should validate commands and fail clearly when required variables are missing.

### 2. GitHub Webhook and Jenkins Trigger Verification

**Challenge:** A successful GitHub webhook delivery did not, on its own, establish that the main `Testing` pipeline had been triggered by the push.

**Investigation:** Webhook delivery responses, the `Testing` job's trigger configuration, and Jenkins build-cause metadata were inspected independently.

**Result:** Webhook-trigger evidence was found for the `Webhook-Test` job. Build #54 metadata also identified a GitHub push cause for the `Testing` job.

**Lesson learned:** Webhook delivery, job trigger configuration, and an individual build's cause are separate pieces of evidence. All three should be checked when troubleshooting CI/CD triggers.

### 3. Kubernetes and Docker-Host Image-Version Difference

**Challenge:** Jenkins Build #54 used image tag `54` for the Docker-host deployment, while the live EKS Deployment was recorded with image tag `49`.

**Investigation:** The EKS Deployment's actual image reference was checked with Kubernetes commands and compared with Jenkins build logs.

**Resolution:** The version difference was documented rather than assuming that a successful Docker-host deployment had also updated EKS. The Kubernetes image tag must be updated through the intended deployment workflow when a new EKS release is required.

**Lesson learned:** CI/CD status for one deployment target does not prove that a separate Kubernetes environment has been updated. Each target requires independent version and health validation.

### 4. ECR Tag and Image-Digest Traceability

**Challenge:** ECR inspection showed multiple image tags associated with the same image digest.

**Investigation:** The repository's image details and digest information were inspected.

**Resolution:** Deployment evidence records both the image tag and digest where available. This helps distinguish a tag label from the actual image content it references.

**Lesson learned:** For reliable image traceability, record immutable digest references in addition to tags.

### 5. Terraform State Versus Live Infrastructure

**Challenge:** A Terraform state listing provides resource-tracking information but cannot independently prove the current operational status of every AWS resource.

**Investigation:** Terraform state evidence was compared with direct AWS status checks for EKS, its node group, the NAT Gateway, and the Application Load Balancer.

**Resolution:** The report separates Terraform configuration/state evidence from live AWS resource status.

**Lesson learned:** Infrastructure as Code records and cloud runtime status should be validated independently.

### 6. AWS Cost and Resource-Lifecycle Management

**Challenge:** EKS worker nodes, NAT Gateways, Application Load Balancers, and Elastic IP allocations can incur ongoing costs.

**Investigation:** AWS resource inventories and status information were collected to identify active resources and their associations.

**Resolution:** Resource status and dependencies should be reviewed before making infrastructure changes. Cleanup should be planned deliberately to avoid breaking dependencies or deleting resources still needed for validation.

**Lesson learned:** Cost awareness is part of DevOps operations. Infrastructure should be monitored and unused resources cleaned up when no longer required.

### 7. Monitoring Configuration Versus Alert Delivery

**Challenge:** Having alert rules and an email receiver configured does not, by itself, prove that an alert was triggered or that an email was delivered.

**Investigation:** Prometheus target status, alert rules, active-alert results, Alertmanager readiness, and Grafana contact points were inspected separately.

**Resolution:** Monitoring status and configuration are documented independently from actual notification-delivery tests.

**Lesson learned:** Validate the complete alert path—from metric condition to alert firing, Alertmanager routing, and receipt of the notification—before claiming end-to-end alert delivery.

## Validation Summary

The following results were captured during the documented inspection period:

| Component | Recorded evidence |
|---|---|
| Jenkins Build #54 | `SUCCESS` |
| Automated tests | 3 passed |
| Amazon ECR | Image tag `54` and digest inspected |
| Docker application host | Candidate and production health checks passed |
| Ansible | `ok=6`, `changed=0`, `unreachable=0`, `failed=0` |
| EKS cluster | `ACTIVE` |
| EKS managed node group | `ACTIVE` |
| Kubernetes worker nodes | 2 nodes `Ready` |
| Kubernetes application pods | 2 pods `Running` and ready |
| Application Load Balancer | Active; health and users endpoints returned HTTP 200 |
| Prometheus targets | Configured targets reported `UP` |
| Prometheus alerts | No active alerts at the recorded inspection time |
| Grafana | Health check passed; Prometheus datasource configured |
| Alertmanager | Reported ready; email receiver configuration inspected |
| Rollback mechanism | Preserved previous container and recovery logic reviewed |

These results represent recorded checks at the time of inspection. Resource states, application versions, and metrics can change after subsequent deployments or infrastructure modifications.

## Security Considerations

- Do not commit AWS access keys, secret access keys, passwords, SMTP app passwords, private keys, or access tokens.
- Use IAM roles and least-privilege permissions wherever possible.
- Avoid publishing unnecessary account identifiers, public IP addresses, private endpoints, and sensitive infrastructure details.
- Keep application containers running as non-root users where possible.
- Review Terraform state, Jenkins configuration, and monitoring configuration before making the repository public.
- Use secure secret storage for credentials rather than embedding secret values in source files.
- Review ECR tag mutability and image-scanning results as part of the release process.

## Repository Structure

The repository contains the application and its deployment-related files. The following is a conceptual overview; actual file locations should be verified against the current repository.

```text
Devops-Project/
├── app.py
├── Dockerfile
├── Jenkinsfile
├── requirements.txt
├── tests/
├── ansible/
├── k8s/
├── terraform/        # If maintained inside the repository
├── docs/             # Project documentation and screenshots
└── README.md
```

The Terraform working directory used in the documented environment was maintained separately on the Jenkins server. Do not assume that every Terraform file is already committed to the repository.

## Documentation and Screenshots

The project screenshots are organized into the following documentation categories:

- `Architecture/`
- `Jenkins-CICD/`
- `Docker-ECR-Ansible/`
- `EKS-Kubernetes-ALB/`
- `Terraform/`
- `Monitoring-Alerts/`
- `Rollback-Recovery/`
- `AWS-Resources/`

These folders should be uploaded under the repository's `docs/` directory, or linked from this README after confirming their final paths.

Screenshots provide supporting evidence for configurations, build results, health checks, infrastructure state, and monitoring status. Captions should identify what each screenshot proves and the date or build number where relevant. Sensitive information should be redacted before publication.

## Conclusion

This capstone demonstrates a practical DevOps workflow spanning source control, automated testing, containerization, image publishing, deployment validation, infrastructure automation, Kubernetes orchestration, monitoring, and recovery planning.

The recorded Jenkins Build #54 completed successfully with three passing tests and successful Ansible post-deployment validation. The EKS environment and application endpoints were also independently verified during the documented inspection period.

The project highlights an important operational principle: successful delivery requires not only automation, but also independent health checks, version traceability, monitoring validation, recovery planning, and cost-aware infrastructure management.
