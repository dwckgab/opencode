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

(nenhuma ainda — promovidas após 3 ocorrências)

## Aprendizados recentes (máx 30, FIFO)

(nenhum ainda)
