# Terraform Security Review

## CKV_AWS_58 — EKS secrets encryption

Status: Checkov FAIL — design reviewed; live cluster not verified.

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

Status: Single-file Checkov scan PASS; full-scan discrepancy unresolved.

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

Status: Checkov FAIL — possible policy-version mismatch under review.

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

## Latest validation evidence — 2026-10-24

A targeted Checkov 3.3.30 scan of `terraform/eks.tf` produced:
- CKV_AWS_39: PASS
- CKV_AWS_58: FAIL
- CKV_AWS_339: FAIL

The Terraform Validate Jenkins build #9 full scan reported four failed
checks: CKV_AWS_339, CKV_AWS_39, CKV_AWS_58, and CKV2_AWS_11.
Because CKV_AWS_39 differs between the full scan and targeted scan,
the discrepancy remains unresolved; do not mark the full scan as clean.

The Checkov stage is report-only, so Jenkins build #9 finished SUCCESS
even though four security checks failed. Terraform formatting,
initialization, and validation passed. No infrastructure was applied
by that validation job.

Next actions:
- Investigate why CKV_AWS_39 differs between full and targeted scans.
- Reassess CKV_AWS_58 against current AWS EKS encryption requirements.
- Verify the CKV_AWS_339 policy's supported Kubernetes-version list.
- Keep VPC Flow Logs deferred for the cost-conscious lab; reassess before
  production deployment.
