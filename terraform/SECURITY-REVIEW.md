# Terraform Security Review

## CKV_AWS_58 — EKS secrets encryption

Status: Reviewed — default encryption behavior; live cluster not verified.

The Terraform configuration specifies Kubernetes version 1.37.
AWS documentation states that Amazon EKS provides default envelope
encryption for Kubernetes API data on clusters running Kubernetes
version 1.28 or later, using an AWS-owned KMS key by default.

This is a configuration review, not a live-cluster verification.
Checkov 3.3.30's Terraform policy checks for an explicit
`encryption_config/[0]/resources` value containing `secrets`.
Therefore, the Checkov result alone does not establish whether the
actual AWS cluster has adequate encryption protection.

AWS documentation:
https://docs.aws.amazon.com/eks/latest/userguide/envelope-encryption.html

Decision:
- Do not add a customer-managed KMS key solely to satisfy this check.
- Do not modify the installed Checkov policy or suppress the finding.
- Verify encryption settings if an EKS cluster is created in the future.
- Reassess if AWS encryption behavior or cluster requirements change.

## CKV_AWS_39 — EKS public API endpoint

Status: Addressed in Terraform configuration; not verified on a live cluster.

The Terraform configuration enables private API endpoint access and
disables public API endpoint access (`endpoint_public_access = false`).

This improves API isolation. However, deployment tools such as `kubectl`
and Jenkins must have network connectivity to the private EKS endpoint
when a cluster is created.

Decision:
- Keep the public endpoint disabled by default.
- Before recreating the cluster, verify that Jenkins and administrators
  can reach the private endpoint through suitable VPC connectivity.
- No live-cluster change has been made; the EKS cluster is currently absent.

## CKV2_AWS_11 — VPC Flow Logs

Status: Deferred — enable before production deployment.

Checkov 3.3.30 reports that VPC Flow Logs are not enabled for
`aws_vpc.main` in `network.tf`.

VPC Flow Logs provide network traffic metadata that can help investigate
connectivity issues and suspicious traffic. They do not capture packet
payloads. Sending logs to CloudWatch Logs or S3 can incur ingestion,
storage, and related charges.

Decision:
- Do not create logging resources solely to clear this finding in the
  currently inactive, cost-conscious lab.
- Before production deployment, assess security and compliance requirements
  and enable VPC Flow Logs with an approved destination and retention policy.
- Estimate logging costs using expected traffic volume and destination
  pricing before enabling collection.
- Do not suppress the Checkov finding or modify the installed policy.

## CKV_AWS_339 — EKS Kubernetes version

Status: Reviewed — outdated Checkov 3.3.30 policy.

The Terraform configuration specifies Kubernetes version 1.37.
Amazon EKS officially supports Kubernetes 1.37, released on
October 1, 2026, with standard support ending December 1, 2027.

Checkov 3.3.30 has a hard-coded supported-version list ending at 1.35.
Consequently, its CKV_AWS_339 result is a false positive for version 1.37.

AWS documentation:
https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html

Decision:
- Retain version 1.37 while it remains supported by Amazon EKS.
- Do not modify the installed Checkov policy or suppress the finding.
- Reassess this result when Checkov is upgraded.
