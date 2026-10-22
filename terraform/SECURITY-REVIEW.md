# Terraform Security Review

## CKV_AWS_58 — EKS secrets encryption

Status: Reviewed — AWS default encryption applies.

The EKS cluster is configured for Kubernetes 1.37.
Amazon EKS provides default envelope encryption for Kubernetes API
data on clusters running Kubernetes 1.28 or later, using an AWS-owned
KMS key unless a customer-managed key is configured.

AWS documentation:
https://docs.aws.amazon.com/eks/latest/userguide/envelope-encryption.html

Checkov 3.3.30 checks for an explicit Terraform
`encryption_config/[0]/resources` value containing `secrets`.
That static check does not account for EKS default envelope encryption.

Decision:
- Do not add a customer-managed KMS key solely to satisfy this check.
- Do not modify the installed Checkov policy.
- Do not suppress the finding in the scan.
- Reassess if the cluster version or AWS encryption behavior changes.
