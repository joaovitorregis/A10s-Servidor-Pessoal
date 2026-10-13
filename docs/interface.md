# Interface do painel A10s

O painel é uma ferramenta de operação do servidor privado. A interface não executa o agendamento: o celular continua responsável pelos envios quando o painel está fechado.

## Organização

| Tela | Responsabilidade |
| --- | --- |
| Visão geral | Recursos do aparelho, histórico de métricas e serviços do servidor |
| Automações / Rota | Próximo envio, estado do executor, ativação e prévia da mensagem |
| Agendamento e mensagem | Horário, dias, janela de recuperação e conteúdo da lista |
| Conta e grupos | Verificação da conta, QR temporário e seleção dos destinos |
| Pausas por data | Exceções à programação semanal |
| Histórico de envios | Tentativas registradas e limites de cada confirmação |
| Manutenção | Backups e tamanho dos logs |

As rotas usam fragmentos de URL. Apenas uma tela fica visível; os formulários permanecem montados para preservar edições durante a navegação. Rotas desconhecidas abrem a visão geral. O link atual recebe `aria-current="page"`.

## Direção visual

A interface separa o monitoramento do A10s dos controles da Rota. Superfícies escuras agrupam os dados; ações e estados têm cores próprias, acompanhadas de texto. A tipografia usa Segoe UI e fontes locais, com números tabulares para horários e medições. Os tokens e os componentes estão descritos em [DESIGN.md](../panel/DESIGN.md); a referência da visão geral está em [OVERVIEW-REFERENCE.md](../panel/OVERVIEW-REFERENCE.md).

Controles têm foco visível, áreas de interação de pelo menos 44 pixels nas ações principais e indicação de indisponibilidade. Diálogos têm nomes acessíveis. Janelas menores reorganizam os cartões e permitem rolagem localizada na navegação e na tabela. Animações respeitam a preferência por movimento reduzido.

## Limites e manutenção

- A atualização visual não altera sessão WhatsApp, configuração, histórico ou regras de envio.
- Avisos de conexão e atualização ficam fora das telas individuais para permanecerem disponíveis durante a navegação.
- Verificação da conta exige os envios desativados; um processo saudável não comprova entrega.
- Confirmação pelo servidor não comprova leitura pelos participantes.
- Alterações em navegação devem manter os testes de preservação de edição em `test/panel.test.cjs`.
- Prévia e testes visuais devem usar dados fictícios e nenhum conector de envio real.

A revisão visual de 03/10/2026 cobriu as cinco telas, entrada, confirmação de teste e janelas de 1440, 1024 e 600 pixels. Os 91 testes isolados resultaram em 90 aprovações no Windows e uma verificação de kernel Linux ignorada nessa plataforma. Essa revisão não constitui certificação integral de acessibilidade nem validação de entrega do WhatsApp.
