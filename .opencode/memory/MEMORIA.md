# MEMORIA — aprendizado contínuo dos agentes

Os agentes leem este arquivo no INÍCIO de cada tarefa e registram lições no FIM.
O orquestrador consolida aqui o que vale reaproveitar. Nada de segredos, tokens ou dados pessoais.

## Como funciona

1. Todo agente lê este arquivo antes de começar e aplica regras/aprendizados.
2. Workers anexam até 3 lições por tarefa em `.opencode/memory/inbox/<nome-do-agente>.md` (um arquivo por agente = sem conflito em paralelo).
3. Coords/revisores incluem "Aprendizados" no relatório (não escrevem arquivos).
4. O orquestrador promove o útil para cá (com dedupe), apaga o consumido do inbox e commita (`docs: atualiza memoria`).
5. Lição vista 3x vira **Regra permanente**. Teto: 60 itens; recentes em FIFO (máx 30).

Formato: `- [AAAA-MM-DD] contexto: fato -> ação`

## Regras permanentes

- Contrato (`API.md` + ownership de pastas) definido ANTES de qualquer paralelo — divergência é o retrabalho mais caro (visto em 10/10 contextos seed).
- QA nunca edita produção; falha volta ao coord dono com arquivo:linha + sugestão (visto em 8/10 contextos seed).
- Nenhum segredo, token ou PII no repo, nos logs ou nesta memória; envs via `.env.example` (visto em 7/10 contextos seed).

## Aprendizados recentes (máx 30, FIFO)

- [2026-10-09] seed/fullstack-todo: frontend chutou campo `title`, backend criou `name` -> fixar `API.md` antes do paralelo e espelhar tipos no api-client.
- [2026-10-09] seed/fullstack-todo: camada `lib/api.ts` isolada permitiu trocar mock->real sem tocar telas -> exigir api-client separado em todo frontend.
- [2026-10-09] seed/fullstack-todo: CORS `*` com credentials quebrou login no browser -> configurar origem explícita + credentials.
- [2026-10-09] seed/auth-jwt: refresh em localStorage vaza via XSS -> refresh em cookie httpOnly + access curto em memória.
- [2026-10-09] seed/auth-jwt: erro "usuário não existe" vs "senha errada" enumera contas -> resposta genérica "credenciais inválidas" + rate-limit no login.
- [2026-10-09] seed/auth-jwt: bcrypt custo 12 equilibra segurança e latência de teste -> padronizar e documentar no API.md.
- [2026-10-09] seed/checkout-stripe: webhook sem verificação de assinatura aceita evento forjado -> exigir verificação + responder 200 rápido e processar async.
- [2026-10-09] seed/checkout-stripe: reentrega de webhook duplicou cobrança -> idempotência por event-id antes de qualquer efeito.
- [2026-10-09] seed/checkout-stripe: log com payload do cartão -> nunca logar payload sensível, só IDs e status.
- [2026-10-09] seed/migration-prod: migration editada após aplicada quebrou ambientes -> migrations só-para-frente, nunca editar aplicada.
- [2026-10-09] seed/migration-prod: listagem lenta com 100k linhas -> índice em FK/filtros usados + testar migrate-from-zero no CI.
- [2026-10-09] seed/ci-docker: imagem de 1.2GB com devDeps -> multi-stage + `.dockerignore` (node_modules, .git).
- [2026-10-09] seed/ci-docker: CI só rodava testes e deixava build quebrado passar -> ordem lint -> build -> testes no workflow.
- [2026-10-09] seed/ci-docker: `.env` commitado vaza no histórico mesmo apagado depois -> `.env.example` + checagem no CI.
- [2026-10-09] seed/e2e-flakes: `sleep(2000)` falhava 1 em 5 runs -> seletor por role/test-id + wait automático, zero sleep fixo.
- [2026-10-09] seed/e2e-flakes: e2e rodado sobre contrato divergente queimou 40min -> pré-requisito qa-unit + qa-contrato verdes (BLOQUEADO senão).
- [2026-10-09] seed/divergencia-contrato: `userName` vs `username` passou em unit e quebrou a tela -> matriz rota-a-rota do qa-contrato é inegociável.
- [2026-10-09] seed/a11y-i18n: strings hardcoded em 3 idiomas viraram 40 arquivos para corrigir -> dicionário i18n desde a primeira tela.
- [2026-10-09] seed/a11y-i18n: modal sem foco travou navegação por teclado -> foco visível + trap de foco + roles/labels.
- [2026-10-09] seed/observabilidade: erro sem correlation-id levou 2h para rastrear -> propagar ID por request em logs e respostas de erro.
- [2026-10-09] seed/docs-onboarding: README com flag inventada travou setup -> comandos copiados de execução real, nunca de cabeça.
- [2026-10-09] seed/web-research: briefing com 1 fonte caiu em API descontinuada -> triangular com 2+ fontes + data de acesso, marcar não confirmado.
- [2026-10-09] seed/web-operator: script com senha hardcoded quase foi commitado -> credenciais só via env, dry-run antes de efeito colateral.
- [2026-10-09] seed/web-operator: sleep fixo no browser quebrou em rede lenta -> waits automáticos + screenshot antes/depois da ação crítica.
- [2026-10-09] seed/auditoria: 3 agentes editando API.md geraram contrato incoerente -> single-writer (só orquestrador commita, resto propõe diff no relatório).
- [2026-10-09] seed/auditoria: dois workers no mesmo arquivo em paralelo sobrescreveram código -> 1 arquivo = 1 dono por rodada; transversal (a11y) audita e o dono aplica.
- [2026-10-09] seed/mimo-v2: QA pesado rodando em modelo pro queimou 3x tokens sem ganho -> rotear qa-*/docs para flash, pro só em implementação e decisão.
- [2026-10-09] seed/skills: checklist de segurança copiado em 4 prompts divergiu -> centralizar em skill (revisao-segura) e referenciar, não duplicar.
