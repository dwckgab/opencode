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
$SourceDir = Join-Path $RepoRoot ".opencode\agents"
if (-not (Test-Path -LiteralPath $SourceDir)) {
  throw "Pasta de origem nao encontrada: $SourceDir. Rode este script a partir do clone do repo."
}
$SourceFiles = Get-ChildItem -LiteralPath $SourceDir -Filter *.md
if ($SourceFiles.Count -eq 0) {
  throw "Nenhum agente encontrado em: $SourceDir."
}

if ($Global) {
  $DestAgents = Join-Path $env:USERPROFILE ".config\opencode\agents"
  New-Item -ItemType Directory -Path $DestAgents -Force | Out-Null
  $SourceFiles | Copy-Item -Destination $DestAgents -Force
  $SourceSkills = Join-Path $RepoRoot ".opencode\skills"
  if (Test-Path -LiteralPath $SourceSkills) {
    $DestSkills = Join-Path $env:USERPROFILE ".config\opencode\skills"
    New-Item -ItemType Directory -Path $DestSkills -Force | Out-Null
    Copy-Item -Path (Join-Path $SourceSkills "*") -Destination $DestSkills -Recurse -Force
  }
  Write-Output "Instalado global em: $DestAgents (somente agentes; config e memoria sao por projeto)"
  Write-Output "Use: opencode -> Tab ate 'orquestrador'"
  return
}

if (-not (Test-Path -LiteralPath $ProjectPath)) {
  New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
}
$DestRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
$DestAgents = Join-Path $DestRoot ".opencode\agents"
New-Item -ItemType Directory -Path $DestAgents -Force | Out-Null
$SourceFiles | Copy-Item -Destination $DestAgents -Force
New-Item -ItemType Directory -Path (Join-Path $DestRoot ".opencode\memory\inbox") -Force | Out-Null
$SourceSkills = Join-Path $RepoRoot ".opencode\skills"
if (Test-Path -LiteralPath $SourceSkills) {
  Copy-Item -Path $SourceSkills -Destination (Join-Path $DestRoot ".opencode\skills") -Recurse -Force
}

$ExampleJson = Join-Path $RepoRoot "opencode.json.example"
$TargetJson = Join-Path $DestRoot "opencode.json"
if ((Test-Path -LiteralPath $ExampleJson) -and (-not (Test-Path -LiteralPath $TargetJson))) {
  Copy-Item -LiteralPath $ExampleJson -Destination $TargetJson
  Write-Output "Criado opencode.json a partir do exemplo."
}

$MemSeed = Join-Path $RepoRoot ".opencode\memory\MEMORIA.md"
$MemDest = Join-Path $DestRoot ".opencode\memory\MEMORIA.md"
if ((Test-Path -LiteralPath $MemSeed) -and (-not (Test-Path -LiteralPath $MemDest))) {
  New-Item -ItemType Directory -Path (Split-Path -Parent $MemDest) -Force | Out-Null
  Copy-Item -LiteralPath $MemSeed -Destination $MemDest
  Write-Output "Criada memoria inicial (.opencode/memory/MEMORIA.md)."
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
