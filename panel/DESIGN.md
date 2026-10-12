# A10s
Servidor pessoal Android com a automação Rota como módulo. A entrada mostra recursos do aparelho e serviços; controles de envio pertencem à Rota.

## Sistema visual
Fundo #101317, superfícies #191d23, texto #f0f2f5 e secundário #a7b0bd. Bordas #343b47, ações #92b3ff com texto escuro, atenção #e9c46a e confirmação #91d7b9.
Navegação em abas e conteúdo centralizado até 820px, seguindo a densidade do status.html fornecido como referência. Recursos em linhas com medidor e valor alinhado à direita. Tipografia Segoe UI para controles e leitura. A10s em peso forte, sem símbolo adicional; Rota conserva a marca inclinada. Sem fontes externas ou animações decorativas.

## Áreas
Visão geral concentra recursos e saúde do executor. Automações contém Rota, agenda, conta e pausas. Atividade apresenta envios registrados. Manutenção apresenta backups e logs.
Formulários permanecem montados ao navegar para preservar edições não salvas.
Histórico apresenta gráficos de memória usada, espaço livre e bateria em períodos de 1, 6 e 24 horas. Eixo horizontal usa o horário real; ausência de leitura ou intervalo maior que 150 segundos interrompe a linha. Percentuais usam escala de 0 a 100; espaço livre usa escala local em GiB com limites visíveis. A tabela de até 60 amostras fica recolhida.

## Estados
Executor ativo não comprova entrega. Leituras ausentes não viram zero. Sem consulta recente, manter os últimos valores com aviso explícito. Foco de teclado e medidores mantêm significado além da cor. Navegação e tabelas podem rolar localmente em telas estreitas; a página não deve transbordar.
