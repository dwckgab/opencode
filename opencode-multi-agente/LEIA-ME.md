# Multi-Agente Autônomo — OpenCode

Estrutura de 5 agentes (1 orquestrador + 4 subagentes) que trabalham em paralelo
para construir um projeto do início ao fim sem intervenção humana.

## Agentes

| Agente          | Papel                                                        |
|-----------------|--------------------------------------------------------------|
| `orquestrador`  | Chefe (primary). Planeja, delega em paralelo, arbitra conflitos, só finaliza quando tudo passa |
| `dev-frontend`  | Implementa interface/componentes (subagente)                  |
| `dev-backend`   | Implementa API/lógica/banco, gera API.md (subagente)          |
| `testador`      | Roda/escreve testes, lint e build (subagente)                 |
| `revisor`       | Revisão final read-only (segurança, bugs, qualidade)          |

## Como instalar no outro PC

### Opção A — por projeto (recomendado)

Copie a pasta `.opencode` para a **raiz do seu projeto**:

```
meu-projeto/
├── .opencode/
│   └── agents/
│       ├── orquestrador.md
│       ├── dev-frontend.md
│       ├── dev-backend.md
│       ├── testador.md
│       └── revisor.md
└── ... (código do projeto)
```

> Faça o projeto ser um repositório git antes (`git init`), pois o orquestrador
> faz commits em marcos importantes.

### Opção B — global (todos os projetos)

Copie os 5 arquivos `.md` para:

```
%USERPROFILE%\.config\opencode\agents\
```

(Linux/Mac: `~/.config/opencode/agents/`)

## Como usar

1. Abra o terminal na raiz do projeto e rode `opencode`.
2. Pressione **Tab** para trocar do agente `build` para o `orquestrador`.
3. Dê o objetivo e vá embora:

```
Crie um app de lista de tarefas com login, frontend React, API em Node
e banco SQLite. Teste tudo e deixe pronto para rodar com npm run dev.
```

Ou direto por CLI, sem abrir a interface:

```
opencode run "Crie um app X com Y e Z. Complete e teste tudo."
```

## O que esperar

- O orquestrador dispara `dev-frontend` e `dev-backend` **simultaneamente**, depois
  valida com o `testador` e finaliza com o `revisor`, iterando até passar.
- Cada subagente reporta de volta; conflitos (ex: contrato de API divergente) são
  decididos pelo orquestrador e re-delegados.
- Um `PLANO.md` é criado na raiz com o plano e o progresso.

## Custos e limites

- Horas de agentes = muitos tokens. Monitore o consumo no painel do seu provedor.
- Para limitar iterações de um agente, adicione `steps: 50` (ou outro número)
  no frontmatter do arquivo dele.
- Revise sempre antes de dar push/deploy — os agentes só fazem commit local.

## Personalizar

- Troque modelos por agente adicionando `model: provedor/modelo` no frontmatter
  (ex: modelo barato no testador, modelo forte no orquestrador).
- Adicione novos agentes (ex: `dev-mobile.md`) — o orquestrador só vai poder
  chamá-los se você liberar no bloco `permission.task` do `orquestrador.md`.
