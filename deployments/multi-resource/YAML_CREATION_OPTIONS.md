# How to Create resources.yaml - All Options

This document outlines **all the ways** you can create the `resources.yaml` configuration file, from easiest (no coding) to most advanced.

## 🎯 Choose Your Method

| Method | Difficulty | Best For | Time | Flexibility |
|--------|------------|----------|------|-------------|
| **1. Web Generator** | ⭐ Easiest | Non-technical users, beginners | 5-10 min | Medium |
| **2. Copy from Examples** | ⭐⭐ Easy | Quick starts, similar setups | 2-5 min | Medium |
| **3. YAML Editor with Schema** | ⭐⭐⭐ Moderate | Technical users, custom configs | 10-15 min | High |
| **4. Manual YAML Editing** | ⭐⭐⭐⭐ Advanced | Power users, complex setups | 15-30 min | Highest |
| **5. Programmatic Generation** | ⭐⭐⭐⭐⭐ Expert | Automation, CI/CD, bulk creation | Varies | Highest |

---

## Method 1: Web-Based Generator 🎨

**Best for**: Anyone who wants a visual, point-and-click interface

### Pros:
✅ **No YAML knowledge required**  
✅ **No coding needed**  
✅ **Form validation prevents errors**  
✅ **Real-time preview**  
✅ **One-click download**  
✅ **Works offline in browser**

### How to Use:

```bash
# Open the generator
start yaml-generator.html   # Windows
open yaml-generator.html    # Mac
```

### Steps:
1. Open `yaml-generator.html` in any web browser
2. Fill in the form (dropdowns, text fields)
3. Click "+ Add EC2 Instance" / "+ Add RDS Database" etc.
4. See real-time YAML preview on the right
5. Click "💾 Download File" to get `resources.yaml`

### Example Screenshot Flow:
```
[Common Config] → [Add EC2] → [Add RDS] → [Download]
   ↓                  ↓            ↓           ↓
Fill region     Fill instance  Fill DB    Get YAML file
  & VPC           details      details
```

**Documentation**: See [YAML_GENERATOR_GUIDE.md](./YAML_GENERATOR_GUIDE.md)

---

## Method 2: Copy from Examples 📋

**Best for**: When you need something similar to existing examples

### Pros:
✅ **Very fast**  
✅ **Proven configurations**  
✅ **Minimal editing needed**  
✅ **Learn by example**

### How to Use:

1. Open **EXAMPLES.md**
2. Find a scenario similar to yours
3. Copy the YAML configuration
4. Paste into `resources.yaml`
5. Modify values (IDs, names, sizes)

### Available Examples:
- Simple web application (EC2 + RDS + ALB)
- Multi-tier application (web, app, database layers)
- High availability setup (multi-AZ, auto-scaling)
- Disaster recovery environment
- Development environment
- Microservices architecture
- And 5+ more scenarios

**Documentation**: See [EXAMPLES.md](./EXAMPLES.md)

---

## Method 3: YAML Editor with Schema Validation 🔧

**Best for**: Technical users who want assistance while editing

### Pros:
✅ **Auto-completion**  
✅ **Syntax validation**  
✅ **Error highlighting**  
✅ **Full flexibility**

### Recommended Editors:

#### VS Code (Recommended)
```bash
# Install VS Code YAML extension
code --install-extension redhat.vscode-yaml
```

**Setup** (in VS Code settings.json):
```json
{
  "yaml.schemas": {
    "./resources.schema.json": "resources.yaml"
  }
}
```

#### Other Editors:
- **IntelliJ IDEA**: Built-in YAML support
- **Sublime Text**: YAML syntax package
- **Atom**: language-yaml package
- **Vim**: vim-yaml plugin

### Tips:
- Use 2-space indentation
- Enable "show whitespace" to see indentation
- Use YAML linters for validation
- Keep a reference example open

---

## Method 4: Manual YAML Editing ✍️

**Best for**: Experienced users, complex custom configurations

### Pros:
✅ **Complete control**  
✅ **No tool dependencies**  
✅ **Can add custom fields**  
✅ **Direct editing**

### Template Structure:

```yaml
# Start with this minimal template
common:
  region: "us-west-2"
  vpc_id: "vpc-xxx"
  environment: "dev"
  common_tags:
    department: "Engineering"

ec2_instances:
  my-server:
    enabled: true
    instance_name: "my-server"
    ami_id: "ami-xxx"
    instance_type: "t3.medium"
    subnet_id: "subnet-xxx"
    os_type: "linux"
    tags:
      Name: "my-server"

rds_instances:
  # Add RDS configs here

load_balancers:
  # Add ALB configs here
```

### Best Practices:
1. Start with minimal config
2. Add resources incrementally
3. Test with `terraform plan` after each addition
4. Use comments to document decisions
5. Keep indentation consistent

### Validation Tools:

```bash
# Online validators
https://www.yamllint.com/
https://codebeautify.org/yaml-validator

# Command-line tools
yamllint resources.yaml
python -c 'import yaml; yaml.safe_load(open("resources.yaml"))'
```

---

## Method 5: Programmatic Generation 🤖

**Best for**: Automation, CI/CD pipelines, bulk infrastructure

### Pros:
✅ **Fully automated**  
✅ **Dynamic generation**  
✅ **Integration with other tools**  
✅ **Version control friendly**

### Option A: Python Script

```python
import yaml

config = {
    'common': {
        'region': 'us-west-2',
        'vpc_id': 'vpc-123',
        'environment': 'prod'
    },
    'ec2_instances': {
        f'web-server-{i}': {
            'enabled': True,
            'instance_name': f'web-{i}',
            'ami_id': 'ami-xxx',
            'instance_type': 't3.medium',
            'subnet_id': f'subnet-{i}',
            'os_type': 'linux',
            'tags': {'Name': f'web-{i}'}
        } for i in range(1, 4)  # Create 3 servers
    }
}

with open('resources.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False)
```

### Option B: Jinja2 Template

```yaml
# resources.yaml.j2 template
common:
  region: {{ region }}
  vpc_id: {{ vpc_id }}
  environment: {{ environment }}

ec2_instances:
{% for server in servers %}
  {{ server.name }}:
    enabled: true
    instance_name: "{{ server.name }}"
    ami_id: "{{ server.ami }}"
    instance_type: "{{ server.type }}"
    subnet_id: "{{ server.subnet }}"
{% endfor %}
```

```python
from jinja2 import Template

template = Template(open('resources.yaml.j2').read())
output = template.render(
    region='us-west-2',
    vpc_id='vpc-123',
    environment='prod',
    servers=[
        {'name': 'web-1', 'ami': 'ami-xxx', 'type': 't3.medium', 'subnet': 'subnet-1'},
        {'name': 'web-2', 'ami': 'ami-xxx', 'type': 't3.medium', 'subnet': 'subnet-2'},
    ]
)

with open('resources.yaml', 'w') as f:
    f.write(output)
```

### Option C: Terraform (Ironically)

Use Terraform to generate the YAML:

```hcl
# generate-yaml.tf
locals {
  resources_config = {
    common = {
      region = var.region
      vpc_id = var.vpc_id
    }
    ec2_instances = {
      for i in range(3) : "web-${i}" => {
        enabled = true
        instance_name = "web-${i}"
        ami_id = var.ami_id
        instance_type = "t3.medium"
      }
    }
  }
}

resource "local_file" "resources_yaml" {
  content  = yamlencode(local.resources_config)
  filename = "resources.yaml"
}
```

### Option D: REST API / Database

Generate from external source:

```python
import requests
import yaml

# Fetch infrastructure config from API/Database
response = requests.get('https://api.company.com/infrastructure/prod')
infrastructure = response.json()

# Transform to YAML format
config = {
    'common': {
        'region': infrastructure['region'],
        'vpc_id': infrastructure['vpc_id'],
        'environment': infrastructure['environment']
    },
    'ec2_instances': {
        server['name']: {
            'enabled': True,
            'instance_name': server['name'],
            'ami_id': server['ami'],
            'instance_type': server['type'],
            'subnet_id': server['subnet'],
            'os_type': server['os']
        } for server in infrastructure['servers']
    }
}

with open('resources.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False)
```

---

## 🎯 Recommendation by Use Case

### For First-Time Users
👉 **Use Method 1: Web Generator**
- Easiest to understand
- Visual feedback
- No mistakes
- Get started in minutes

### For Quick Deployments
👉 **Use Method 2: Copy from Examples**
- Fastest way
- Proven configurations
- Minimal changes needed

### For Regular Infrastructure Work
👉 **Use Method 3: YAML Editor with Schema**
- Balance of ease and power
- Auto-completion helps
- Full control when needed

### For Complex Customizations
👉 **Use Method 4: Manual Editing**
- Complete flexibility
- Add custom fields
- Advanced configurations

### For Automation & CI/CD
👉 **Use Method 5: Programmatic Generation**
- Fully automated
- Dynamic based on inputs
- Integrate with other systems

---

## 🔄 Hybrid Approach (Recommended!)

**Best practice**: Combine multiple methods

### Example Workflow:

1. **Initial Creation**: Use Web Generator
   - Create base configuration
   - Download `resources.yaml`

2. **Refinement**: Use YAML Editor
   - Add advanced settings
   - Customize specific resources
   - Add comments

3. **Automation**: Use Programmatic Generation
   - Generate environment-specific configs
   - Automate repetitive changes
   - Integrate with CI/CD

4. **Maintenance**: Use Examples + Manual Editing
   - Reference examples for new patterns
   - Manually adjust as needed

---

## 📝 Summary

| If you want to... | Use this method... |
|-------------------|-------------------|
| Get started quickly without coding | **Web Generator** |
| Use a proven configuration | **Copy from Examples** |
| Edit with assistance | **YAML Editor** |
| Have complete control | **Manual Editing** |
| Automate everything | **Programmatic Generation** |
| Learn YAML | **Examples** + **Manual Editing** |
| Train non-technical team | **Web Generator** |
| Build CI/CD pipeline | **Programmatic Generation** |
| Prototype quickly | **Web Generator** or **Examples** |
| Production deployment | **YAML Editor** or **Manual** |

---

## 🆘 Need Help?

- **Web Generator**: See [YAML_GENERATOR_GUIDE.md](./YAML_GENERATOR_GUIDE.md)
- **Examples**: See [EXAMPLES.md](./EXAMPLES.md)
- **Commands**: See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
- **Framework**: See [README.md](./README.md)

Start with the easiest method and progress as you get more comfortable! 🚀
