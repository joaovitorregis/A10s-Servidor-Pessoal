# Visão geral: piloto Grafana

Escopo: somente #server. Outras rotas, autenticação, coleta, agenda e registros permanecem inalterados. Extensão do padrão depende de aprovação do usuário.

Referência principal: https://grafana.com/docs/grafana/latest/visualizations/dashboards/
Referência de implementação: https://github.com/grafana/grafana
Metodologia: Refero Design, referências locais de tipografia, cor e validação visual. Sem uso da conexão paga Refero MCP.

| Decisão | Origem | Aplicação |
|---|---|---|
| Painéis em linhas para dados relacionados | Organização de dashboards Grafana | Indicadores, série temporal, serviços |
| Séries temporais antes de detalhes operacionais | Objetivo do usuário: monitorar o servidor | Histórico sobe na ordem de leitura |
| Neutros escuros e elevação contida | Direção aprovada e guia de cor Refero | Tokens locais, sem alterar outras telas |
| Escala tipográfica compacta e números tabulares | Guia de tipografia Refero | Títulos pequenos, leitura numérica destacada |
| Cor com papel definido | Guia de cor Refero | Série, estado e ação; sem efeitos decorativos |

Preservar: dados reais, escala dos gráficos, lacunas, seleção por teclado e distinção entre processo ativo e envio confirmado. Não incorporar recursos do Grafana ou insinuar que ele está instalado. Mídia: gráficos vetoriais produzidos das amostras reais, sem imagens ilustrativas.
