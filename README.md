# Multi-Agente Autônomo — OpenCode

Estrutura de 5 agentes (1 orquestrador + 4 subagentes) que trabalham em paralelo
para construir um projeto do início ao fim sem intervenção humana.

## Agentes

| Agente | Papel |
|---|---|
| `orquestrador` | Chefe (primary). Planeja, define contrato de API primeiro, delega em paralelo, arbitra conflitos, só finaliza com teste + revisão OK |
| `dev-frontend` | Implementa interface/componentes (subagente, hidden) |
| `dev-backend` | Implementa API/lógica/banco, mantém `API.md` (subagente, hidden) |
| `testador` | Roda/escreve testes, lint e build. Nunca edita `src/` (subagente, hidden) |
| `revisor` | Revisão final read-only (segurança, bugs, qualidade) |

Estrutura deste repo (pronta para copiar):

```
.opencode/
  agents/
    orquestrador.md
    dev-frontend.md
    dev-backend.md
    testador.md
    revisor.md
opencode.json.example
install.ps1
install.sh
README.md
```

## Instalação

### Opção A — por projeto (recomendado)

Windows (PowerShell):

```powershell
git clone https://github.com/dwckgab/opencode.git
.\opencode\install.ps1 -ProjectPath "C:\caminho\meu-projeto"
```

Linux/Mac:

```bash
git clone https://github.com/dwckgab/opencode.git
./opencode/install.sh /caminho/meu-projeto
```

> Faça o projeto destino ser um repo git antes (`git init`), pois o orquestrador faz commits locais em marcos. Ele nunca faz `git push` (bloqueado por permissão).

Manual: copie `.opencode/` para a raiz do seu projeto e `opencode.json.example` para `opencode.json` (se ainda não tiver um).

### Opção B — global (todos os projetos)

```powershell
.\opencode\install.ps1 -Global
```

```bash
./opencode/install.sh --global
```

Destino: `%USERPROFILE%\.config\opencode\agents\` (Linux/Mac: `~/.config/opencode/agents/`)

## Como usar

1. Abra o terminal na raiz do projeto e rode `opencode`.
2. Pressione **Tab** até o agente `orquestrador`.
3. Dê o objetivo e vá embora:

```
Crie um app de lista de tarefas com login, frontend React, API em Node
e banco SQLite. Teste tudo e deixe pronto para rodar com npm run dev.
```

Ou direto por CLI, sem TUI:

```bash
opencode run "Crie um app X com Y e Z. Complete e teste tudo."
```

## O que esperar

- O orquestrador cria `PLANO.md` e um rascunho de `API.md` **antes** de paralelizar (evita frontend/backend divergirem).
- Depois dispara `dev-frontend` + `dev-backend` **simultaneamente**, valida com `testador` e finaliza com `revisor`, iterando até passar.
- Cada subagente devolve relatório padronizado; conflito de contrato é decidido pelo orquestrador e re-delegado.
- `testador: FALHOU` -> correção volta para o dono do código, nunca para o testador editar `src/`.
- `revisor: REPROVADO` = existe ao menos 1 CRÍTICO. Só finaliza com APROVADO ou APROVADO COM RESSALVAS sem CRÍTICO.

## Custos e limites

- Horas de agentes = muitos tokens. Monitore no painel do seu provedor.
- Limites já vêm configurados: `orquestrador steps: 100`, demais `steps: 30-50`, `temperature: 0.1-0.3` para respostas determinísticas.
- Para apertar mais, edite `steps:` no frontmatter do agente.
- Revise sempre antes de push/deploy — os agentes só fazem commit local.

## Personalizar

- Troque modelos por agente adicionando `model: provedor/modelo` no frontmatter (ex: barato no `testador`/`revisor`, forte no `orquestrador`):
  ```yaml
  model: anthropic/claude-sonnet-4-20250514
  ```
- Sem `model` definido, subagentes herdam o modelo do `orquestrador` — que por sua vez usa o modelo global do seu `opencode.json`.
- Adicione novos agentes (ex: `.opencode/agents/dev-mobile.md`) e libere no bloco `permission.task` do `orquestrador.md`.
- Subagentes vêm com `hidden: true` (só o orquestrador chama via Task). Remova se quiser chamar via `@nome` no autocomplete.
- Autonomia garantida por `question: deny` + `task: {"*": deny}` nos subagentes (evita recursão e trava esperando humano). `external_directory: deny` mantém os agentes dentro do projeto e `doom_loop: allow` deixa a recuperação de loop ser automática, sem prompt.
- Regras de permissão com glob seguem "última regra vence": o curinga `"*"` vem primeiro e as exceções depois. Não inverta a ordem.

## Solução de problemas

- `revisor` não lê arquivos: atualize — versão antiga negava `read/glob/grep`. A atual libera leitura e só nega `edit` + `bash` (exceto `git diff/log/status`).
- Frontend inventando API: garanta que o orquestrador criou `API.md` antes do paralelo. Frontend sem contrato deve criar mock `TODO(mock)` e reportar bloqueador.
- Loop teste-falha infinito: limite é 3 tentativas no mesmo erro, depois o orquestrador pivota (troca lib/simplifica). Ajuste `steps:` se precisar.
- `Task tool` não lista subagente: confira `permission.task` no `orquestrador.md` — `deny` remove da descrição da tool.
- `install.ps1` bloqueado (ExecutionPolicy): rode com `powershell -ExecutionPolicy Bypass -File install.ps1 -ProjectPath "C:\caminho\meu-projeto"`.
- `install.sh` com erro de `bash\r` no Linux: atualize — o repo agora tem `.gitattributes` forçando `eol=lf` em `*.sh`.
- Agente parado esperando aprovação no meio da madrugada: confira se alguma permissão está como `ask` (ex: `external_directory`). Nos 5 agentes o padrão é `deny`/`allow` justamente para não travar sem humano.
