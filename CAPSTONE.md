# TS Academy DevOps Capstone 1

## Project Overview

This project demonstrates containerization, automated testing,
container vulnerability scanning, CI/CD, Infrastructure as Code,
Kubernetes deployment, and Helm rollback.

Repository: https://github.com/davinane/example-voting-app

## Architecture

[View the DevOps architecture diagram](docs/architecture.md)

The application consists of five services:

1. Vote: Python web application
2. Redis: Vote message queue
3. Worker: .NET background processor
4. PostgreSQL: Persistent database
5. Result: Node.js results application

Application data flow:

Vote -> Redis -> Worker -> PostgreSQL -> Result

## 1. Local Docker Deployment

Requirements: Docker Desktop and Docker Compose.

From the repository root:

    docker compose up -d --build --wait

Open:

- Vote: http://localhost:8080
- Results: http://localhost:8081

Stop the application:

    docker compose down

## 2. Container Security

The application uses:

- Digest-pinned base images
- Non-root execution where configured
- Docker build exclusions through .dockerignore
- Dependency security updates
- Trivy vulnerability scanning

Some upstream operating-system vulnerabilities may remain.
Review the GitHub Actions Trivy reports for current findings.

## 3. GitHub Actions CI/CD

The workflows under .github/workflows/ run on pushes.

They perform:

- Docker Compose smoke testing
- Trivy container vulnerability scanning
- Application image builds
- Image publication to GitHub Container Registry

Application images use commit-SHA tags for traceability.

Registry:

    ghcr.io/davinane/

## 4. Terraform and Amazon EKS

Terraform files are located in terraform/.

The cluster uses:

- AWS region: ca-central-1
- EKS cluster: ts-academy-capstone-eks
- Managed worker node group: capstone-workers
- Default VPC and selected subnets
- Restricted public Kubernetes API access

Initialize and review:

    cd terraform
    terraform init
    terraform plan

Use the configured AWS credentials and profile.

Important: A completely fresh deployment requires the
EBS CSI IAM role, OIDC provider, and EKS add-on to be
created in the correct dependency order.

See terraform/STORAGE-SETUP.md for the existing setup
and its reproducibility limitations.

The cluster was successfully destroyed and recreated
using Terraform during capstone testing.

## 5. Helm Deployment

Chart location:

    helm/voting-app

The chart deploys five application workloads, Kubernetes
Services, a PostgreSQL Secret, and a persistent volume claim.

Validate:

    helm lint helm/voting-app --set-string postgresPassword=lint-only

Deploy with a securely supplied PostgreSQL password.
Do not commit real passwords or rendered Secret manifests.

The chart was tested on Amazon EKS with all five
application deployments healthy.

## 6. Helm Rollback Demonstration

The rollback demonstration followed these steps:

1. Deploy a working application release.
2. Upgrade using an intentionally invalid Vote image.
3. Confirm the Vote deployment enters ImagePullBackOff.
4. Roll back to the previous working Helm revision.
5. Verify all five deployments recover.

The successful rollback created Helm revision 5,
which restored the working configuration from revision 3.

Supporting evidence is available in evidence/.

## 7. Verification Evidence

Evidence includes:

- Terraform resources before cluster destruction
- Terraform resources after cluster recreation
- Kubernetes nodes before and after recreation
- Working Helm deployment status
- Failed Helm deployment status
- Helm revision history
- Successful Helm rollback status

## 8. Cleanup and AWS Costs

Amazon EKS, EC2 worker nodes, and EBS storage incur
charges while running.

Before cleanup, confirm all evidence is saved.

Remove the Helm release and persistent storage only
when its data is no longer required.

Terraform manages the cluster, node group, OIDC
provider, and EBS CSI add-on.

The EBS CSI IAM role is separately managed through
an eksctl CloudFormation stack. Follow a dependency-safe
cleanup procedure for both management systems.

An AWS budget alert is not a spending cap.

## 9. Security Notes

- Never commit AWS credentials or database passwords.
- Never commit Terraform state or plan files.
- Restrict Kubernetes API access to approved IP addresses.
- Use immutable image references for deployments.
- Review vulnerability scan results before production use.

This is a learning capstone, not a production-hardened
reference deployment.
