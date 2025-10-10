# EC2 Instance Module

A small Terraform module to provision an EC2 instance with secure defaults and flexible KMS handling for EBS encryption.

---

## Highlights

- Creates an EC2 instance using module variables for AMI, instance type, subnets, security groups, and IAM profile.
- Root EBS block device is encrypted. KMS selection order:
  1. Explicit `kms_key_arn` (set in tfvars)
  2. KMS alias lookup built from `kms_key_alias_name_base` + `-<region>` (default alias base: `alias/ebs-key`)
  3. Falls back to AWS-managed EBS key if nothing resolves
- Supports Linux/Windows user data via `userdata/init_linux` and `userdata/init_win`.

---

## Files

- `ec2.tf` - EC2 resource and data sources.
- `variables.tf` - Module variables used by `ec2.tf`.
- `userdata/init_linux`, `userdata/init_win` - Example user data scripts.

---

## Variables (important ones)

Below are the variables you will commonly need to set. See `variables.tf` for the full list.

- `ami_id` (string) — REQUIRED. AMI ID to use for the instance.
- `instance_name` (string) — REQUIRED. Name tag for the instance.
- `app_instance_type` (string) — REQUIRED. EC2 instance type (e.g., `t3.medium`).
- `key_name` (string) — REQUIRED. SSH key pair name for Linux or RDP for Windows.
- `private_subnets` (list) — REQUIRED. Subnet IDs - instance will be placed in the first private subnet.
- `vpc_id` (string) — REQUIRED. VPC id used to map security groups.
- `instance_role` (string) — optional, default `AmazonSSMRoleForInstancesQuickSetup`.

KMS-related variables:
- `kms_key_arn` (string) — optional. If set, the module uses this ARN for root EBS encryption.
- `kms_key_alias_name_base` (string) — optional, default `alias/ebs-key`. If set, module will attempt to read the KMS alias named `alias/ebs-key-<region>` and use the referenced key.

Other useful variables: `root_vol_size` (default `100`), `os_type` (default `linux`), `ebs_vol_size`.

---

## How KMS is resolved (detailed)

1. If `kms_key_arn` is non-empty, that ARN is used directly for the `root_block_device.kms_key_id`.
2. Otherwise, if `kms_key_alias_name_base` is non-empty, the module will look up an alias named `"${kms_key_alias_name_base}-${region}"` (e.g., `alias/ebs-key-us-west-2`). If that alias exists, the alias's target KMS key is used.
3. If neither provides a usable key, Terraform passes `null` and AWS will use the default AWS-managed EBS key.

This arrangement lets you either set a per-deployment explicit ARN, or maintain consistent naming for a per-region alias and rely on auto-resolution.

---

## Examples

Minimal usage (explicit ARN):

```hcl
module "ec2_server" {
  source = "../ec2-instance"

  ami_id           = "ami-0123456789abcdef0"
  instance_name    = "app-server-01"
  app_instance_type = "t3.medium"
  key_name         = "my-keypair"
  vpc_id           = "vpc-abc123"
  private_subnets  = ["subnet-11111111"]

  # Force a specific key
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Usage with alias naming convention (preferred for automatic resolution):

```hcl
module "ec2_server" {
  source = "../ec2-instance"

  ami_id           = "ami-0123456789abcdef0"
  instance_name    = "app-server-01"
  app_instance_type = "t3.medium"
  key_name         = "my-keypair"
  vpc_id           = "vpc-abc123"
  private_subnets  = ["subnet-11111111"]

  # Use alias-based auto discovery
  kms_key_alias_name_base = "alias/ebs-key"
}
```

Example `terraform.tfvars` (sensible example values):

```hcl
ami_id           = "ami-0123456789abcdef0"
instance_name    = "app-server-01"
app_instance_type = "t3.medium"
key_name         = "my-keypair"
vpc_id           = "vpc-abc123"
private_subnets  = ["subnet-11111111"]
# Optional override:
# kms_key_arn = "arn:aws:kms:..."
```

---

## Best practices

- If you need customer-managed keys across environments, use the alias convention and create the same alias in each region/account.
- Do not commit production key ARNs into source control. Use environment `tfvars` or secret management to supply production ARNs.
- If you require encryption with a customer key, add a validation step or CI check to ensure the module resolves a non-null key.

---

## Troubleshooting

- No alias found: confirm the alias exists in the target account/region by running `aws kms list-aliases --region <region>`.
- Want to force fail when no key: contact me and I can add a validation that errors when no key is resolved.

---

If you'd like, I can also add a `terraform.tfvars.example`, a short `CONTRIBUTING.md`, and a validation that fails when no customer key is resolved. Let me know which of those you'd like next.