# Multi-Agente Autônomo — OpenCode

Hierarquia de 25 agentes (1 orquestrador + 5 coordenadores + 19 especialistas)
que constrói um projeto inteiro do início ao fim sem intervenção humana.
O orquestrador só fala com os 5 coords; cada coord comanda seu time em paralelo.

## Agentes

| Camada | Agentes |
|---|---|
| Chefia (primary) | `orquestrador` — planeja, define contratos, delega aos coords, arbitra cross-team, só finaliza com gates verdes |
| `coord-frontend` | `fe-pages` (rotas/telas), `fe-components` (design system), `fe-state` (store/api-client), `fe-a11y` (a11y/i18n/performance) |
| `coord-backend` | `be-data` (banco), `be-domain` (regras), `be-auth` (login/RBAC), `be-api` (rotas + `API.md`), `be-integrations` (webhooks/filas) |
| `coord-plataforma` | `plat-infra` (Docker/CI/deploy), `plat-docs` (README/API/ADRs), `plat-observability` (logs/métricas/alertas) |
| `coord-pesquisa` | `web-researcher` (pesquisa com fontes), `web-operator` (browser via Playwright com evidências) |
| `coord-qualidade` | `qa-unit` (lint/build/testes), `qa-contrato` (front x API x back), `qa-e2e` (Playwright/Cypress), `qa-security` e `qa-quality` (revisores read-only) |

Todos os subagentes são `hidden` (só o chefe direto chama via Task). Gates do `coord-qualidade` rodam nesta ordem: unit -> contrato -> e2e -> security -> quality.

> Migração da v1 (5 agentes): `dev-frontend` virou time `fe-*`, `dev-backend` virou `be-*`, `testador` virou `qa-unit`+`qa-e2e`+`qa-contrato`, `revisor` virou `qa-security`+`qa-quality`.

Estrutura deste repo (pronta para copiar):

```
.opencode/
  agents/ (25 agentes: orquestrador, 5 coords, 19 workers)
  memory/MEMORIA.md (regras permanentes + aprendizados)
opencode.json.example (copiado para opencode.json só se não existir)
install.ps1 / install.sh (instalação por projeto ou -Global/-—global, só agentes no global)
.gitattributes / .gitignore
README.md / LICENSE
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
chmod +x opencode/install.sh  # só se baixado como zip
./opencode/install.sh /caminho/meu-projeto
```

> Faça o projeto destino ser um repo git antes (`git init`), pois o orquestrador faz commits locais em marcos. Ele nunca faz `git push` (bloqueado por permissão).

Manual: copie `.opencode/agents/*.md` para `.opencode/agents/` do projeto e `opencode.json.example` para `opencode.json` (só se ainda não existir um — nunca sobrescreve).

### Opção B — global (todos os projetos)

```powershell
.\opencode\install.ps1 -Global
```

```bash
./opencode/install.sh --global
```

Destino: `%USERPROFILE%\.config\opencode\agents\` (Linux/Mac: `~/.config/opencode/agents/`) — somente agentes; config (`opencode.json`) e memória são sempre por projeto.

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

- O orquestrador cria `PLANO.md` e um rascunho de `API.md` **antes** de paralelizar (evita times divergirem).
- Depois dispara os coords **simultaneamente** (frontend+backend+plataforma); cada coord comanda seu time com ownership de pastas (1 arquivo = 1 dono por rodada).
- Gates via `coord-qualidade`: unit -> contrato -> e2e -> security -> quality. Correção volta ao coord dono, nunca ao QA editar produção.
- Veredito final: só finaliza com `LIBERADO` (sem CRÍTICO, e2e passando). Cada nível devolve relatório padronizado; conflito cross-team é decidido pelo orquestrador.
- Modo autônomo total: checkpoint em `PLANO.md` + commit a cada retorno de coord; se a sessão cair, ele retoma por `PLANO.md` + `MEMORIA.md` + `git log`. Missões de pesquisa/browser vão pelo `coord-pesquisa` (briefing com fontes, operação com evidências).

## Aprendizado contínuo

Os agentes aprendem sozinhos ao longo dos projetos via `.opencode/memory/`:

- `MEMORIA.md` — regras permanentes + aprendizados recentes (teto 60 itens, FIFO 30). Todo agente lê no início da tarefa.
- `inbox/<agente>.md` — cada worker anexa até 3 lições por tarefa (um arquivo por agente = sem conflito em paralelo). Coords e revisores mandam aprendizados no relatório.
- O orquestrador consolida o inbox na MEMORIA a cada rodada (com dedupe), apaga o consumido e commita (`docs: atualiza memoria`). Lição vista 3x vira regra permanente.
- Antiboato: teto de itens, formato de 1 linha (`- [AAAA-MM-DD] contexto: fato -> ação`) e proibição de segredos/dados pessoais. Para recomeçar do zero, apague `inbox/*` e a seção de recentes.

## Custos e limites

- 25 agentes = muitos tokens. Monitore no painel do seu provedor. Para escopo pequeno, peça ao orquestrador para usar só os coords necessários.
- Limites já vêm configurados: `orquestrador steps: 150`, coords `60-80`, workers `30-50`, `temperature: 0.1-0.3` para respostas determinísticas.
- Para apertar mais, edite `steps:` no frontmatter do agente.
- Revise sempre antes de push/deploy — os agentes só fazem commit local.

## Personalizar

- Troque modelos por agente adicionando `model: provedor/modelo` no frontmatter (ex: barato nos `qa-*`, forte no `orquestrador` e nos coords):
  ```yaml
  model: anthropic/claude-sonnet-4-20250514
  ```
- Sem `model` definido, subagentes herdam o modelo do `orquestrador` — que por sua vez usa o modelo global do seu `opencode.json`.
- Adicione novos workers (ex: `.opencode/agents/fe-mobile.md`) e libere no bloco `permission.task` do coord do time. Novo coord? Libere também no `orquestrador.md`.
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
- Agente parado esperando aprovação no meio da madrugada: confira se alguma permissão está como `ask` (ex: `external_directory`). Nos 25 agentes o padrão é `deny`/`allow` justamente para não travar sem humano.
