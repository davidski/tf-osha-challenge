[CmdletBinding()]
param(
  [Parameter(Mandatory=$False, position=1)]
  [string]$command = "plan"
)

$ip = "$(invoke-restmethod https://api.ipify.org)"
terraform $command -var ''home_ip=""$ip""''