#Requires -Version 5.1
<#
.SYNOPSIS
  Instala o sistema multi-agente OpenCode no projeto alvo.
.DESCRIPTION
  Copia .opencode/agents/*.md e opencode.json.example para o projeto.
  Uso:
    .\install.ps1 -ProjectPath "C:\caminho\meu-projeto"
    .\install.ps1 -ProjectPath "C:\caminho\meu-projeto" -Global
#>
param(
  [string]$ProjectPath = ".",
  [switch]$Global
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Global) {
  $DestAgents = Join-Path $env:USERPROFILE ".config\opencode\agents"
  New-Item -ItemType Directory -Path $DestAgents -Force | Out-Null
  Copy-Item -Path (Join-Path $RepoRoot ".opencode\agents\*.md") -Destination $DestAgents -Force
  Write-Output "Instalado global em: $DestAgents"
  Write-Output "Use: opencode -> Tab ate 'orquestrador'"
  exit 0
}

$DestRoot = Resolve-Path -LiteralPath $ProjectPath
$DestAgents = Join-Path $DestRoot ".opencode\agents"
New-Item -ItemType Directory -Path $DestAgents -Force | Out-Null
Copy-Item -Path (Join-Path $RepoRoot ".opencode\agents\*.md") -Destination $DestAgents -Force

$ExampleJson = Join-Path $RepoRoot "opencode.json.example"
$TargetJson = Join-Path $DestRoot "opencode.json"
if ((Test-Path -LiteralPath $ExampleJson) -and (-not (Test-Path -LiteralPath $TargetJson))) {
  Copy-Item -LiteralPath $ExampleJson -Destination $TargetJson
  Write-Output "Criado opencode.json a partir do exemplo."
}

# Garante repo git (orquestrador faz commits locais)
if (-not (Test-Path -LiteralPath (Join-Path $DestRoot ".git"))) {
  Write-Warning "Destino nao e repo git. Rode 'git init' la antes de usar o orquestrador."
} else {
  Write-Output "Repo git OK."
}

Write-Output "Instalado em: $DestAgents"
Write-Output "Proximo passo:"
Write-Output "  1. cd '$DestRoot'; opencode"
Write-Output "  2. Tab ate 'orquestrador' e digite seu objetivo."
