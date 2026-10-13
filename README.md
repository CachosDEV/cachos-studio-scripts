# Cachos Studio — scripts

Repositório público único com os scripts do pack e os módulos da interface Cachos Studio.

Scripts incluídos: **358**

A seleção automática usa o `PlaceId`. O loader executável fica fora deste repositório,
para hospedagem separada, e contém nome, PlaceId e URL raw de cada arquivo.
Não é necessário token para baixar os arquivos públicos.

## Estrutura de distribuição

- `scripts/`: 358 arquivos, incluindo variantes e arquivos auxiliares.
- `ui/`: runtime da interface aprovada e bibliotecas de controles.
- `routes.json`: 352 PlaceIds ativos com a rota padrão de cada jogo.
- `script-info.json`: informações e URLs raw de todos os 358 arquivos.
- `manifest.json`: inventário completo e metadados de revisão.

Base raw: `https://raw.githubusercontent.com/CachosDEV/cachos-studio-scripts/main/`

O loader baixa somente o jogo atual e suas bibliotecas. Variantes permanecem no
inventário; a seleção automática dá preferência ao script sem variante.
`donation` não tem PlaceId. `Steal An Egg` permanece desativado no loader porque
seu código somente expulsa o jogador.

A interface usa abas animadas, avatar e nome reais do jogador no rodapé,
loader com arco vermelho/verde girando e notificação para jogos sem suporte.
Compilação e verificações de integração não substituem validação dentro de cada jogo.

Arquivos excluídos da publicação por obfuscação, duplicidade ou payload codificado: **27**.

## Revisão Cachos Studio v2

Os 358 arquivos foram normalizados para UTF-8/LF, receberam metadados de jogo, `PlaceId` e UI, e foram verificados contra payloads remotos e buffers codificados. O loader usa exatamente estes arquivos revisados; a pasta `rebuild-report.json` registra o hash SHA-256 de cada script.
