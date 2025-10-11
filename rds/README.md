# RDS Module — secure, flexible, and multi-engine

This module provisions an AWS RDS instance (MySQL, PostgreSQL, or SQL Server) with best practices for encryption, tagging, and engine selection.

--

## Why use this module

- Secure by default: storage encryption enabled, KMS key auto-discovery.
- Multi-engine: select MySQL, PostgreSQL, or SQL Server via `db_engine` variable.
- Tagging-ready: pass business metadata (owner, compliance, application, etc.).
- Flexible subnet and security group configuration.

--

## Files in this folder

- `rds_mysql.tf`, `rds_postgres.tf`, `rds_sqlserver.tf` — engine-specific resources.
- `variables.tf` — all module variables and validations.
- `versions.tf` — provider compatibility.
- `terraform.tfvars.example` — example variable file (copy to `terraform.tfvars`).
- `datastore.tf` — shared data sources (e.g., KMS alias).

--

## Required variables (quick list)

Set these in your `terraform.tfvars` or workspace variables:

- `db_engine` — "mysql", "postgres", or "sqlserver"
- `db_engine_version` — e.g., "8" for MySQL
- `db_engine_minorVersion` — e.g., "0.42"
- `db_name` — database name
- `db_instance_type` — e.g., "db.m5.large"
- `db_username` — master username
- `db_password` — master password
- `db_storage` — allocated storage (GB)
- `vpc_id` — VPC id
- `subnet_id` — list of subnet ids
- Tag variables (all REQUIRED): `it_owner`, `BPO`, `compliance`, `application`, `environment`, `department`

See the full variable reference below.

--

## KMS key selection

- Uses AWS-managed RDS key by default via alias `aws/rds` (region-agnostic).
- To use a customer-managed key, update the data source in `datastore.tf`.

--

## Examples

Minimal — create a MySQL RDS instance:

```hcl
module "rds" {
  source = "../rds"

  db_engine            = "mysql"
  db_engine_version    = "8"
  db_engine_minorVersion = "0.42"
  db_name              = "mydb"
  db_instance_type     = "db.m5.large"
  db_username          = "admin"
  db_password          = "SuperSecret123"
  db_storage           = 100
  vpc_id               = "vpc-abc123"
  subnet_id            = ["subnet-11111111", "subnet-22222222"]

  it_owner    = "Your Name"
  BPO         = "Business Owner"
  compliance  = "Non-GxP"
  application = "AppName"
  environment = "dev"
  department  = "IT"
}
```

--

## Full variable reference (high level)

- `db_engine` (string) — "mysql", "postgres", or "sqlserver"
- `db_engine_version` (string)
- `db_engine_minorVersion` (string)
- `db_name` (string)
- `db_instance_type` (string)
- `db_username` (string)
- `db_password` (string)
- `db_storage` (number)
- `vpc_id` (string)
- `subnet_id` (list)
- Tag variables: `it_owner`, `BPO`, `compliance`, `application`, `environment`, `department`

For the complete file and types/validation, see `variables.tf`.

--

## Quick tips & best practices

- Do NOT commit production passwords or secrets to source control. Use environment-specific tfvars (excluded from VCS) or a secrets manager.
- Use the correct engine and version for your application needs.
- Use subnet groups and security groups to control access.

--

## Troubleshooting

- If KMS alias lookup fails: verify alias exists with `aws kms list-aliases --region <region>`.
- If you see provider deprecation warnings, pin provider versions in `versions.tf` (already included).

--

Enjoy! 🎉
