#!/usr/bin/env bash
# Instala o sistema multi-agente OpenCode no projeto alvo.
# Uso:
#   ./install.sh /caminho/meu-projeto
#   ./install.sh --global
set -euo pipefail
shopt -s nullglob

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_FILES=("$REPO_ROOT"/.opencode/agents/*.md)

if [[ ${#SRC_FILES[@]} -eq 0 ]]; then
  echo "ERRO: nenhum agente encontrado em $REPO_ROOT/.opencode/agents/. Rode este script a partir do clone do repo." >&2
  exit 1
fi

if [[ "${1:-}" == "--global" ]]; then
  DEST="$HOME/.config/opencode/agents"
  mkdir -p "$DEST"
  cp "${SRC_FILES[@]}" "$DEST/"
  echo "Instalado global em: $DEST"
  echo "Use: opencode -> Tab ate 'orquestrador'"
  exit 0
fi

PROJECT_PATH="${1:-.}"
if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "ERRO: projeto nao encontrado: $PROJECT_PATH" >&2
  exit 1
fi
DEST_AGENTS="$PROJECT_PATH/.opencode/agents"
mkdir -p "$DEST_AGENTS"
cp "${SRC_FILES[@]}" "$DEST_AGENTS/"

if [[ -f "$REPO_ROOT/opencode.json.example" && ! -f "$PROJECT_PATH/opencode.json" ]]; then
  cp "$REPO_ROOT/opencode.json.example" "$PROJECT_PATH/opencode.json"
  echo "Criado opencode.json a partir do exemplo."
fi

if [[ ! -d "$PROJECT_PATH/.git" ]]; then
  echo "AVISO: destino nao e repo git. Rode 'git init' la antes de usar o orquestrador." >&2
else
  echo "Repo git OK."
fi

echo "Instalado em: $DEST_AGENTS"
echo "Proximo passo:"
echo "  1. cd '$PROJECT_PATH'; opencode"
echo "  2. Tab ate 'orquestrador' e digite seu objetivo."
