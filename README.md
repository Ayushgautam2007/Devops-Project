# DevOps Capstone: Flask CI/CD on AWS EKS

## Project Overview
Build an end-to-end CI/CD pipeline using Flask, Docker,
Amazon ECR, Jenkins, Terraform, Ansible, AWS EKS,
Helm, Prometheus, and Grafana.

## Application Endpoints
- /        - Application welcome message
- /health  - Application health check
- /api/users - User API

## Local Development
Install dependencies:

    python -m pip install -r app/requirements.txt

Run tests:

    python -m pytest -v

## Docker
Build the image:

    docker build -t flask-api:v1 .

Run the container locally:

    docker run -d --name flask-api -p 127.0.0.1:9090:8080 flask-api:v1

Test the health endpoint:

    curl http://127.0.0.1:9090/health

## AWS Region
ap-south-1

## Planned Pipeline
GitHub -> Jenkins -> Tests -> Docker Build -> Amazon ECR
-> Helm/Kubernetes Deployment on AWS EKS
