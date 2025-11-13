# Harness Integration Guide

Complete guide for deploying the multi-resource framework with Harness CD using Terraform or OpenTofu.

> **💡 OpenTofu Support**: This guide covers both Terraform and OpenTofu. Simply use `OpenTofuPlan` and `OpenTofuApply` steps instead of `TerraformPlan` and `TerraformApply` for OpenTofu.

## 🎯 Overview

The multi-resource framework integrates seamlessly with Harness, providing:
- **YAML-driven deployments** - Edit one file to change infrastructure
- **Secrets management** - Use Harness Secret Manager for sensitive values
- **Environment support** - Different configurations per environment
- **Approval gates** - Manual approval before applying changes
- **Rich outputs** - Access deployment details in downstream steps

## 📋 Prerequisites

Before setting up Harness integration:

1. ✅ Harness account with Terraform or OpenTofu provisioner enabled
2. ✅ AWS connector configured in Harness
3. ✅ GitHub connector (if storing code in GitHub)
4. ✅ S3 bucket for Terraform/OpenTofu state
5. ✅ DynamoDB table for state locking (recommended)
6. ✅ Harness secrets created for sensitive values

## 🔐 Step 1: Create Harness Secrets

Navigate to **Project Setup > Secrets** and create:

### RDS Passwords

Create a secret for each RDS instance:
- Secret name: `mysql_primary_password`
- Type: Text
- Value: (your password)

### KMS Keys (Optional)

- Secret name: `kms_key_arn`
- Type: Text
- Value: `arn:aws:kms:us-west-2:123456789012:key/...`

### ACM Certificates (For HTTPS)

- Secret name: `acm_certificate_arn`
- Type: Text
- Value: `arn:aws:acm:us-west-2:123456789012:certificate/...`

## 🏗️ Step 2: Create Harness Pipeline

### Basic Pipeline Structure (Terraform)

**For Terraform:**

```yaml
pipeline:
  name: Multi-Resource Deployment (Terraform)
  identifier: multi_resource_deployment_tf
  projectIdentifier: your_project
  orgIdentifier: default
  tags: {}
  
  stages:
    - stage:
        name: Deploy Infrastructure
        identifier: deploy_infra
        type: Custom
        spec:
          execution:
            steps:
              # Step 1: Terraform Plan
              - step:
                  type: TerraformPlan
                  name: Plan Multi-Resource Stack
                  identifier: plan_resources
                  spec:
                    provisionerIdentifier: multi_resource_stack
                    configuration:
                      command: Apply
                      workspace: <+pipeline.variables.environment>
                      configFiles:
                        store:
                          type: Github
                          spec:
                            gitFetchType: Branch
                            branch: main
                            folderPath: deployments/multi-resource
                            connectorRef: <+input>  # Your GitHub connector
                        moduleSource:
                          useConnectorCredentials: true
                      secretManagerRef: account.harnessSecretManager
                      backendConfig:
                        type: Inline
                        spec:
                          content: |
                            bucket         = "<+pipeline.variables.tf_state_bucket>"
                            key            = "multi-resource/<+pipeline.variables.environment>/terraform.tfstate"
                            region         = "<+pipeline.variables.region>"
                            encrypt        = true
                            dynamodb_table = "<+pipeline.variables.tf_lock_table>"
                      varFiles:
                        - varFile:
                            type: Inline
                            identifier: secrets
                            spec:
                              content: |-
                                # RDS Passwords (from Harness secrets)
                                rds_passwords = {
                                  "mysql-primary"      = "<+secrets.getValue('mysql_primary_password')>"
                                  "postgres-analytics" = "<+secrets.getValue('postgres_analytics_password')>"
                                }
                                
                                # KMS Encryption
                                kms_key_arn              = "<+secrets.getValue('kms_key_arn')>"
                                kms_key_alias_name_base  = "alias/ebs-key"
                                enable_kms_alias_lookup  = true
                                
                                # ACM Certificates for ALB HTTPS
                                certificate_arns = {
                                  "web-alb" = "<+secrets.getValue('acm_certificate_arn')>"
                                }
                                
                                # Deployment metadata
                                deployment_id        = "<+pipeline.executionId>"
                                deployment_timestamp = "<+pipeline.startTs>"
                                deployed_by          = "<+pipeline.triggeredBy.name>"
                  timeout: 15m
              
              # Step 2: Manual Approval (optional)
              - step:
                  type: HarnessApproval
                  name: Approve Deployment
                  identifier: approve_deployment
                  spec:
                    approvalMessage: |-
                      Please review the Terraform plan and approve deployment.
                      
                      Environment: <+pipeline.variables.environment>
                      Region: <+pipeline.variables.region>
                      
                      Resources to deploy:
                      - Check plan output above
                    includePipelineExecutionHistory: true
                    isAutoRejectEnabled: false
                    approvers:
                      minimumCount: 1
                      disallowPipelineExecutor: false
                      userGroups:
                        - account.Infrastructure_Admins
                    approverInputs: []
                  timeout: 1d
                  when:
                    stageStatus: Success
                    condition: <+pipeline.variables.require_approval> == "true"
              
              # Step 3: Terraform Apply
              - step:
                  type: TerraformApply
                  name: Apply Multi-Resource Stack
                  identifier: apply_resources
                  spec:
                    provisionerIdentifier: multi_resource_stack
                    configuration:
                      type: InheritFromPlan
                  timeout: 30m
              
              # Step 4: Display Outputs
              - step:
                  type: ShellScript
                  name: Display Deployment Summary
                  identifier: display_summary
                  spec:
                    shell: Bash
                    source:
                      type: Inline
                      spec:
                        script: |-
                          echo "========================================="
                          echo "Multi-Resource Deployment Complete"
                          echo "========================================="
                          echo ""
                          echo "Deployment ID: <+pipeline.executionId>"
                          echo "Environment: <+pipeline.variables.environment>"
                          echo "Region: <+pipeline.variables.region>"
                          echo ""
                          echo "Resources Deployed:"
                          echo "- EC2 Instances: <+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.deployment_summary.ec2_count>"
                          echo "- RDS Instances: <+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.deployment_summary.rds_count>"
                          echo "- Load Balancers: <+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.deployment_summary.alb_count>"
                          echo ""
                          echo "========================================="
                    environmentVariables: []
                    outputVariables: []
                  timeout: 2m
  
  # Pipeline Variables
  variables:
    - name: environment
      type: String
      description: Deployment environment
      required: true
      value: <+input>.default(dev).allowedValues(dev,staging,prod)
    
    - name: region
      type: String
      description: AWS region
      required: true
      value: <+input>.default(us-west-2).allowedValues(us-east-1,us-west-2,eu-west-1)
    
    - name: tf_state_bucket
      type: String
      description: S3 bucket for Terraform state
      required: true
      value: <+input>
    
    - name: tf_lock_table
      type: String
      description: DynamoDB table for state locking
      required: true
      value: terraform-state-lock
    
    - name: require_approval
      type: String
      description: Require manual approval before apply
      required: false
      value: "true"
```

### Basic Pipeline Structure (OpenTofu)

**For OpenTofu (just change step types):**

```yaml
pipeline:
  name: Multi-Resource Deployment (OpenTofu)
  identifier: multi_resource_deployment_tofu
  projectIdentifier: your_project
  orgIdentifier: default
  tags: {}
  
  stages:
    - stage:
        name: Deploy Infrastructure
        identifier: deploy_infra
        type: Custom
        spec:
          execution:
            steps:
              # Step 1: OpenTofu Plan
              - step:
                  type: OpenTofuPlan  # ← Changed from TerraformPlan
                  name: Plan Multi-Resource Stack
                  identifier: plan_resources
                  spec:
                    provisionerIdentifier: multi_resource_stack
                    configuration:
                      command: Apply
                      workspace: <+pipeline.variables.environment>
                      configFiles:
                        store:
                          type: Github
                          spec:
                            gitFetchType: Branch
                            branch: main
                            folderPath: deployments/multi-resource
                            connectorRef: <+input>
                        moduleSource:
                          useConnectorCredentials: true
                      secretManagerRef: account.harnessSecretManager
                      backendConfig:
                        type: Inline
                        spec:
                          content: |
                            bucket         = "<+pipeline.variables.tf_state_bucket>"
                            key            = "multi-resource/<+pipeline.variables.environment>/terraform.tfstate"
                            region         = "<+pipeline.variables.region>"
                            encrypt        = true
                            dynamodb_table = "<+pipeline.variables.tf_lock_table>"
                      varFiles:
                        - varFile:
                            type: Inline
                            identifier: secrets
                            spec:
                              content: |-
                                rds_passwords = {
                                  "mysql-primary" = "<+secrets.getValue('mysql_primary_password')>"
                                }
                                   kms_key_arn = "<+secrets.getValue('prod_kms_key')>"
   ```

5. **Plan Before Apply**: Always run Terraform Plan step before Apply
                                deployment_id = "<+pipeline.executionId>"
                  timeout: 15m
              
              - step:
                  type: HarnessApproval
                  name: Approve Deployment
                  # ... same as Terraform version
              
              - step:
                  type: OpenTofuApply  # ← Changed from TerraformApply
                  name: Apply Multi-Resource Stack
                  identifier: apply_resources
                  spec:
                    provisionerIdentifier: multi_resource_stack
                    configuration:
                      type: InheritFromPlan
                  timeout: 30m
  
  # Variables are identical to Terraform version
  variables:
    - name: environment
      type: String
      value: <+input>.default(dev).allowedValues(dev,staging,prod)
    # ... rest of variables same as Terraform
```

> **Note**: The only difference between Terraform and OpenTofu pipelines is the step type:
> - Terraform: `TerraformPlan` and `TerraformApply`
> - OpenTofu: `OpenTofuPlan` and `OpenTofuApply`
> 
> All other configuration (configFiles, varFiles, backendConfig, etc.) is identical.

## 🌍 Step 3: Environment Configuration
    
    - name: resources_config_file
      type: String
      description: Override YAML config file path
      required: false
      value: ""
```

## 🌍 Step 3: Environment Configuration

### Option 1: Environment Overrides

Create environments in Harness and override variables:

1. Navigate to **Environments**
2. Create environment: `dev`
3. Add **Configuration Overrides** or **Service Overrides**
4. Set environment-specific values

Example `dev` environment override:
```yaml
variables:
  region: us-west-2
  tf_state_bucket: terraform-state-dev
  require_approval: "false"
```

Example `prod` environment override:
```yaml
variables:
  region: us-west-2
  tf_state_bucket: terraform-state-prod
  require_approval: "true"
```

### Option 2: Separate YAML Files

Create environment-specific YAML files:
```
deployments/multi-resource/
├── resources-dev.yaml
├── resources-staging.yaml
├── resources-prod.yaml
```

In pipeline variables:
```yaml
variables:
  - name: resources_config_file
    value: resources-<+pipeline.variables.environment>.yaml
```

Pass to Terraform:
```yaml
varFiles:
  - varFile:
      type: Inline
      spec:
        content: |-
          resources_config_file = "<+pipeline.variables.resources_config_file>"
```

## 🚀 Step 4: Run the Pipeline

1. Click **Run Pipeline**
2. Select values:
   - **environment**: `dev` / `staging` / `prod`
   - **region**: `us-west-2`
   - **tf_state_bucket**: `your-state-bucket`
   - **GitHub connector**: Your connector
3. Click **Run Pipeline**
4. Monitor execution
5. Review plan output
6. Approve (if approval enabled)
7. View deployment summary

## 📊 Step 5: Access Outputs in Downstream Steps

You can access Terraform outputs in subsequent pipeline steps or stages.

### Example: Deploy Application After Infrastructure

```yaml
stages:
  - stage:
      name: Deploy Infrastructure
      # ... (as above)
  
  - stage:
      name: Deploy Application
      type: Deployment
      spec:
        execution:
          steps:
            - step:
                type: ShellScript
                name: Configure Application
                spec:
                  script: |-
                    # Access EC2 instance IDs
                    EC2_IDS='<+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.ec2_instance_ids>'
                    
                    # Access RDS endpoint
                    RDS_ENDPOINT='<+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.rds_instances.mysql-primary.endpoint>'
                    
                    # Access ALB DNS
                    ALB_DNS='<+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.load_balancers.web-alb.dns_name>'
                    
                    echo "Deploying to instances: $EC2_IDS"
                    echo "Database endpoint: $RDS_ENDPOINT"
                    echo "Load balancer: $ALB_DNS"
```

### Example: Send Notification

```yaml
- step:
    type: Email
    name: Send Deployment Notification
    spec:
      to: infrastructure-team@company.com
      subject: "Infrastructure Deployed: <+pipeline.variables.environment>"
      body: |-
        <+pipeline.stages.deploy_infra.spec.execution.steps.apply_resources.output.harness_deployment_message>
```

## 🔄 Step 6: Update Resources

To update infrastructure:

### Edit YAML File

1. Commit changes to `resources.yaml` in your Git repository
2. Run the Harness pipeline
3. Harness will detect changes and show them in plan
4. Approve and apply

### Add New Resource

1. Add to `resources.yaml`:
   ```yaml
   ec2_instances:
     app-server-03:  # New instance
       enabled: true
       # ... config
   ```
2. Commit and push
3. Run pipeline
4. New resources will be added

### Disable Resource

1. Set `enabled: false`:
   ```yaml
   ec2_instances:
     app-server-03:
       enabled: false  # Will be removed
   ```
2. Run pipeline
3. Terraform will destroy the resource

## 🎨 Advanced Patterns

### Pattern 1: Multi-Region Deployment

Deploy to multiple regions in parallel:

```yaml
stages:
  - parallel:
      - stage:
          name: Deploy to us-west-2
          spec:
            # ... deployment with region=us-west-2
      
      - stage:
          name: Deploy to us-east-1
          spec:
            # ... deployment with region=us-east-1
```

### Pattern 2: Blue-Green Deployment

Deploy new infrastructure alongside old:

```yaml
# resources-blue.yaml (current)
ec2_instances:
  web-server-blue:
    instance_name: "web-server-blue"
    # ...

# resources-green.yaml (new version)
ec2_instances:
  web-server-green:
    instance_name: "web-server-green"
    # ...

# Pipeline switches between blue and green
```

### Pattern 3: Canary Testing

Deploy small subset first:

1. Deploy with limited resources (e.g., 1 instance)
2. Run tests
3. If successful, update YAML to full scale
4. Deploy again

### Pattern 4: Scheduled Deployments

Use Harness triggers to deploy on schedule:

```yaml
trigger:
  name: Nightly Infrastructure Update
  identifier: nightly_deploy
  type: Scheduled
  spec:
    schedule:
      type: Cron
      spec:
        expression: "0 2 * * *"  # 2 AM daily
    pipelineIdentifier: multi_resource_deployment
```

## � Terraform vs OpenTofu in Harness

| Feature | Terraform | OpenTofu | Notes |
|---------|-----------|----------|-------|
| **Harness Step Type** | `TerraformPlan/Apply` | `OpenTofuPlan/Apply` | Only difference |
| **HCL Syntax** | ✅ Same | ✅ Same | No code changes needed |
| **State Format** | ✅ Compatible | ✅ Compatible | Can migrate between them |
| **AWS Provider** | ✅ Same | ✅ Same | Uses same providers |
| **YAML Parsing** | ✅ Same | ✅ Same | Framework unchanged |
| **Harness Secrets** | ✅ Same | ✅ Same | Works identically |
| **Backend (S3)** | ✅ Same | ✅ Same | Same configuration |

**Bottom Line**: Choose either tool - the framework works perfectly with both! 🎉

## �🛡️ Best Practices

### 1. Always Use Remote State

Never use local state for Harness deployments (works for both Terraform and OpenTofu):
```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "multi-resource/terraform.tfstate"
  region         = "us-west-2"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### 2. Use Workspaces for Environments

```yaml
configuration:
  workspace: <+pipeline.variables.environment>  # dev, staging, prod
```

### 3. Enable State Locking

Always use DynamoDB for state locking to prevent concurrent modifications.

### 4. Secrets Management

- Store ALL sensitive values in Harness Secret Manager
- Never commit secrets to YAML files
- Use secret references in pipeline

### 5. Approval Gates for Production

```yaml
when:
  condition: <+pipeline.variables.environment> == "prod"
```

### 6. Tag Everything

Ensure deployment metadata is captured:
```yaml
deployment_id        = "<+pipeline.executionId>"
deployment_timestamp = "<+pipeline.startTs>"
deployed_by          = "<+pipeline.triggeredBy.name>"
```

### 7. Plan Before Apply

Always review plan output before approving apply.

### 8. Enable Deletion Protection

For production resources, enable deletion protection:
```yaml
lb_enable_deletion_protection = true
```

### 9. Choose Terraform or OpenTofu

Both work identically with this framework:
- **Terraform**: Enterprise support, established tool
- **OpenTofu**: Open source, community-driven, vendor-neutral
- **Switch anytime**: Just change Harness step type - no code changes needed!

## 🐛 Troubleshooting

### Issue: "Backend configuration changed"

**Cause**: State backend settings changed  
**Solution**: Run with `-reconfigure` flag or add shell script step:
```bash
terraform init -reconfigure
```

### Issue: State locked

**Cause**: Previous execution didn't complete  
**Solution**: Force unlock (be careful!):
```bash
terraform force-unlock <lock-id>
```

### Issue: Variables not interpolating

**Cause**: Incorrect expression syntax  
**Solution**: Use exact format: `<+pipeline.variables.var_name>`

### Issue: Secrets not resolving

**Cause**: Secret doesn't exist or wrong reference  
**Solution**: Verify secret exists: `<+secrets.getValue('secret_name')>`

### Issue: Module not found

**Cause**: Incorrect folder path  
**Solution**: Verify `folderPath: deployments/multi-resource` matches repository structure

## 📞 Support

For Harness-specific questions:
- Harness Documentation: https://developer.harness.io
- Harness OpenTofu Docs: https://developer.harness.io/docs/continuous-delivery/cd-infrastructure/opentofu-infra/
- Internal Slack: #harness-support
- Infrastructure Team: #infra-terraform

For framework questions:
- See [README.md](./README.md)
- See [EXTENDING.md](./EXTENDING.md)

For OpenTofu:
- OpenTofu Documentation: https://opentofu.org/docs/
- OpenTofu Installation: https://opentofu.org/docs/intro/install/
