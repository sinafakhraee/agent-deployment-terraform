# Azure AI Foundry Agent – Terraform Deployment
## 📁 Folder layout
```text
foundry-agent-tf/
├─ providers.tf      # provider & version pin
├─ variables.tf      # Foundry project URL + path to agent spec
├─ agent_exec.tf     # null_resource that calls az rest
└─ agent.json        # minimal agent specification
```

Clone or copy these files into your own repo; Terraform automatically loads every
`.tf` file in the directory.

---

## ⚙️ Prerequisites

| Requirement | Notes |
|-------------|-------|
| **Terraform CLI ≥ 1.2** | Install with `winget install --id Hashicorp.Terraform` or Chocolatey. |
| **Azure CLI** | Logged in to the correct subscription (`az login`). |
| **RBAC** | The identity that runs Terraform must have **Azure AI Contributor** (or higher) on the **Foundry project**. |
| **PowerShell 7** | The `local-exec` provisioner uses PowerShell to run `az rest`. (Works cross-platform via pwsh on macOS/Linux.) |

---

## 📝 File contents

### `providers.tf`

```hcl
terraform {
  required_providers {
    azapi = { source = "Azure/azapi", version = ">=2.5.0" }
  }
}

provider "azapi" {}   # reuses the az CLI context
```
### `variables.tf`

```hcl

variable "project_endpoint" {
  description = "Foundry project base URL"
  default     = "https://<foundry-account>.services.ai.azure.com/api/projects/<project-name>"
}

variable "agent_spec_file" {
  default = "agent.json"
}
```
### agent_exec.tf
```hcl
resource "null_resource" "agent" {
  # Re-run when the JSON spec changes
  triggers = { hash = filesha256(var.agent_spec_file) }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOT
      $token = az account get-access-token --resource https://ai.azure.com --query accessToken -o tsv
      az rest --method post `
        --url "${var.project_endpoint}/assistants?api-version=v1" `
        --headers "Authorization=Bearer $token" `
        --body "@${var.agent_spec_file}"
    EOT
  }
}
```
### agent.json
```
{
  "model": "gpt-4o",
  "name": "workshop-demo-agent",
  "instructions": "You are a friendly assistant that answers basic questions about our services."
}
```

## 🚀 Usage
```
# 1. Authenticate once

az login
az account set --subscription "<SUBSCRIPTION-ID>"

# 2. Initialise & apply
cd foundry-agent-tf
terraform init      # downloads azapi provider
terraform plan      # preview
terraform apply     # creates the agent – type 'yes' to confirm
```
