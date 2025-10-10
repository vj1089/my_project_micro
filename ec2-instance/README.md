# EC2 Instance Module — fast, secure, and configurable

This module provisions a single EC2 instance with sensible defaults and flexible options for KMS, AMI selection, tagging, and user-data.

--

## Why use this module

- Secure defaults (EBS encryption enabled, IMDSv2 required).
- Flexible KMS selection: explicit ARN or alias-based discovery.
- Optional AMI lookup if you prefer name-pattern selection over hard-coded AMI IDs.
- Tagging-ready: pass business metadata (owner, compliance, RTO/RPO, etc.).

--

## Files in this folder

- `ec2.tf` — resource and data sources for the EC2 instance.
- `variables.tf` — all module variables and validations.
- `versions.tf` — pins provider compatibility.
- `terraform.tfvars.example` — example variable file (copy to `terraform.tfvars`).
- `userdata/` — user-data scripts (`init_linux`, `init_win`).

--

## Required variables (quick list)

Set these in your `terraform.tfvars` or workspace variables.

- `ami_id` or enable `ami_lookup_enabled` with a name filter
- `instance_name` — instance Name tag
- `app_instance_type` — EC2 instance type (e.g., `t3.medium`)
- `key_name` — SSH/RDP keypair
- `vpc_id` — VPC id used for selecting the security group mapping
- `private_subnets` — list (first element used)

See the full variable reference below.

--

## KMS selection order

1. `kms_key_arn` (explicit)
2. Alias lookup: `"${kms_key_alias_name_base}-${region}"` when `enable_kms_alias_lookup = true`
3. `null` → AWS-managed EBS key

--

## Examples

Minimal — use an explicit KMS ARN:

```hcl
module "ec2_server" {
  source = "../ec2-instance"

  ami_id            = "ami-0123456789abcdef0"
  instance_name     = "app-server-01"
  app_instance_type = "t3.medium"
  key_name          = "my-keypair"
  vpc_id            = "vpc-abc123"
  private_subnets   = ["subnet-11111111"]

  # Customer-managed key
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Auto-discovery via alias (preferred for standardized environments):

```hcl
module "ec2_server" {
  source = "../ec2-instance"

  ami_id            = "ami-0123456789abcdef0"
  instance_name     = "app-server-01"
  app_instance_type = "t3.medium"
  key_name          = "my-keypair"
  vpc_id            = "vpc-abc123"
  private_subnets   = ["subnet-11111111"]

  enable_kms_alias_lookup = true
  kms_key_alias_name_base = "alias/ebs-key"  # module will look for alias/ebs-key-<region>
}
```

AMI lookup example (optional):

```hcl
module "ec2_server" {
  source = "../ec2-instance"

  ami_lookup_enabled = true
  ami_name_filter    = "amzn2-ami-hvm-*-x86_64-gp2"
  ami_owners         = ["amazon"]

  instance_name     = "app-server-01"
  app_instance_type = "t3.medium"
  key_name          = "my-keypair"
  vpc_id            = "vpc-abc123"
  private_subnets   = ["subnet-11111111"]
}
```

--

## Full variable reference (high level)

- `ami_id` (string) — AMI id. If empty, enable `ami_lookup_enabled` and set `ami_name_filter`.
- `ami_lookup_enabled` (bool) — false by default.
- `ami_name_filter` (string) — e.g. `amzn2-ami-hvm-*-x86_64-gp2`.
- `ami_owners` (list) — default `["amazon"]`.
- `instance_name` (string) — name tag.
- `app_instance_type` (string) — instance type.
- `key_name` (string) — ssh/rdp key pair.
- `private_subnets` (list) — first subnet used for instance.
- `vpc_id` (string) — used to lookup security group mapping.
- `kms_key_arn` (string) — explicit ARN override.
- `enable_kms_alias_lookup` (bool) — default `false`.
- `kms_key_alias_name_base` (string) — default `alias/ebs-key`.
- Tag variables: `it_owner`, `BPO`, `compliance`, `RPO`, `RTO`, `application`, `environment`, `department`.

For the complete file and types/validation, see `variables.tf`.

--

## Quick tips & best practices

- Put sensitive production values (KMS ARNs, etc.) into secret workspace variables or external secure stores.
- Use alias-based KMS only when aliases are created consistently across accounts/regions.
- Prefer `ami_id` in CI for reproducible builds, or use precise `ami_name_filter` patterns.

--

## Troubleshooting

- If KMS alias lookup fails: verify alias exists with `aws kms list-aliases --region <region>`.
- If AMI lookup returns no results: check `ami_name_filter` and `ami_owners`.
- If you see provider deprecation warnings, pin provider versions in `versions.tf` (already included).

--

If you'd like, I can:
- Add a CONTRIBUTING.md or CI workflow (GitHub Actions or OpenTofu) to validate PRs.
- Add a variable validation that fails fast when required encryption settings are missing.

Enjoy! 🎉