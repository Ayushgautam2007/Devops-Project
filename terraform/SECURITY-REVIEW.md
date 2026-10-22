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

## CKV_AWS_39 — EKS public API endpoint

Status: Reviewed — restricted public access retained for the lab.

The cluster configuration enables private and public API endpoint access.
Public access is restricted to the Jenkins controller's IPv4 address
using the `/32` CIDR `13.232.197.246/32`. The private endpoint remains
enabled as well.

Checkov recommends disabling the public endpoint entirely. For this lab,
the restricted public endpoint supports Jenkins access without requiring
additional VPC connectivity to the private endpoint.

Decision:
- Keep the public endpoint CIDR restricted; never use `0.0.0.0/0`.
- Verify the Jenkins controller's public IP before recreating the cluster.
- For production, prefer private-only access where Jenkins has suitable
  private network connectivity to the EKS API.
- Reassess this decision if the Jenkins network or deployment architecture changes.
