resource "null_resource" "agent" {
  # Re-run when the JSON spec changes
  triggers = {
    spec_hash = filesha256(var.agent_spec_file)
  }

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
