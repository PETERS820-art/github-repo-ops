param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('create','clone','info')]
  [string]$Action,

  [string]$Name,
  [string]$Path,
  [string]$Url,
  [switch]$Private,
  [switch]$Public,
  [switch]$WithReadme,
  [string]$GitIgnore,
  [string]$Description,
  [switch]$Json
)

$ErrorActionPreference = 'Stop'

function Get-Now {
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss 'GMT+8'")
}

function Test-GhAuth {
  $null = & gh auth status 2>$null
  return $LASTEXITCODE -eq 0
}

function Test-GhInstalled {
  $null = & gh --version 2>$null
  return $LASTEXITCODE -eq 0
}

function New-Repo {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [switch]$Private,
    [switch]$WithReadme,
    [string]$Gitignore,
    [string]$Description
  )

  if (-not (Test-GhInstalled)) {
    throw "gh CLI not found. Install from https://cli.github.com"
  }

  if (-not (Test-GhAuth)) {
    throw "gh authentication required. Run 'gh auth login' first."
  }

  $args = @('repo', 'create', $Name)

  if ($Private) { $args += '--private' }
  else { $args += '--public' }

  if ($WithReadme) { $args += '--add-readme' }

  if ($GitIgnore) {
    $args += '--gitignore'
    $args += $GitIgnore
  }

  if ($Description) {
    $args += '--description'
    $args += $Description
  }

  # gh CLI v2.87+ no confirmation needed when --public/--private is specified
  $output = & gh @args 2>&1

  # Parse repo info
  $repoInfo = & gh repo view $Name --json name,url,isPrivate,createdAt,description,owner 2>$null

  if ($LASTEXITCODE -ne 0) {
    throw "Failed to fetch repo info after creation"
  }

  $repoObj = $repoInfo | ConvertFrom-Json
  $owner = $repoObj.owner.login

  return [pscustomobject]@{
    name = $repoObj.name
    html_url = $repoObj.url
    clone_url = "https://github.com/$owner/$($repoObj.name).git"
    ssh_url = "git@github.com:$owner/$($repoObj.name).git"
    private = $repoObj.isPrivate
    created_at = $repoObj.createdAt
    description = $(if($repoObj.description){$repoObj.description}else{''})
  }
}

function Clone-Repo {
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [string]$Path
  )

  if (-not (Test-GhInstalled)) {
    throw "gh CLI not found. Install from https://cli.github.com"
  }

  $cloneArgs = @('repo', 'clone', $Url)

  if ($Path) {
    $cloneArgs += $Path
  }

  & gh @cloneArgs

  if ($LASTEXITCODE -ne 0) {
    throw "Clone failed. Check URL and authentication."
  }

  $targetPath = $(if($Path){$Path}else{(Split-Path -Leaf $Url -Extensionless)})

  return [pscustomobject]@{
    cloned_to = (Resolve-Path $targetPath).Path
    url = $Url
  }
}

function Get-RepoInfo {
  param([Parameter(Mandatory=$true)][string]$Name)

  if (-not (Test-GhInstalled)) {
    throw "gh CLI not found. Install from https://cli.github.com"
  }

  $repoInfo = & gh repo view $Name --json name,htmlUrl,cloneUrl,sshUrl,private,createdAt,description 2>$null

  if ($LASTEXITCODE -ne 0) {
    throw "Repo not found: $Name"
  }

  $repoObj = $repoInfo | ConvertFrom-Json

  return [pscustomobject]@{
    name = $repoObj.name
    html_url = $repoObj.htmlUrl
    clone_url = $repoObj.cloneUrl
    ssh_url = $repoObj.sshUrl
    private = $repoObj.private
    created_at = $repoObj.createdAt
    description = $repoObj.description
  }
}

# Main execution
try {
  $result = $null

  switch ($Action) {
    'create' {
      if (-not $Name) { throw 'create requires -Name' }
      $result = New-Repo -Name $Name -Private:$Private -WithReadme:$WithReadme -Gitignore $Gitignore -Description $Description
    }
    'clone' {
      if (-not $Url) { throw 'clone requires -Url' }
      $result = Clone-Repo -Url $Url -Path $Path
    }
    'info' {
      if (-not $Name) { throw 'info requires -Name' }
      $result = Get-RepoInfo -Name $Name
    }
  }

  if ($Json) {
    $result | ConvertTo-Json -Depth 5
  } else {
    $result | Format-List *
  }
} catch {
  Write-Error $_.Exception.Message
  exit 1
}
