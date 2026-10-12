---
name: A10s
description: Servidor pessoal Android com a automação Rota como módulo.
colors:
  ink: "#f0f2f5"
  blue: "#84b9ff"
  yellow: "#e9c46a"
  fog: "#101317"
  paper: "#191d23"
  muted: "#b4bdce"
  line: "#343b47"
  success: "#91d7b9"
  surface-raised: "#212936"
  surface-blue: "#1b2b3e"
  surface-violet: "#29243b"
  surface-green: "#1b302c"
typography:
  body:
    fontFamily: '"Segoe UI", Arial, sans-serif'
    lineHeight: 1.65
  headline:
    fontFamily: '"Segoe UI", Arial, sans-serif'
    fontSize: "22px"
    letterSpacing: "-.02em"
  title:
    fontSize: "16px"
    fontWeight: 650
    lineHeight: 1.35
  label:
    fontSize: "13px"
    fontWeight: 600
rounded:
  control: "7px"
  navigation: "8px"
  card: "16px"
  pill: "20px"
spacing:
  control: "16px"
  card: "24px"
  content: "32px"
components:
  button-primary:
    backgroundColor: "{colors.blue}"
    textColor: "{colors.fog}"
    rounded: "{rounded.control}"
    padding: "11px 16px"
  input:
    backgroundColor: "#11151b"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "11px 13px"
  navigation:
    textColor: "{colors.muted}"
    rounded: "{rounded.navigation}"
    padding: "12px 16px"
  chip:
    backgroundColor: "#173b30"
    textColor: "#a3e6c5"
    rounded: "{rounded.pill}"
    padding: "6px 10px"
  card:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.card}"
    padding: "24px"
---

# A10s

## Overview

Servidor pessoal Android com a automação Rota como módulo. A entrada mostra recursos do aparelho e serviços; controles de envio pertencem à Rota. A interface usa superfícies escuras, navegação persistente e uma área ampla de trabalho.

## Colors

Recursos e gráficos usam superfícies tonais por série: armazenamento azul, memória violeta e bateria verde. A superfície de recursos tem contraste maior que o fundo; Rota usa azul para identificar o módulo acionável. Cores de série identificam medições, não classificam sua saúde.

Azul identifica ações e foco; amarelo sinaliza atenção e verde sinaliza confirmação. Fundo, superfícies, texto principal, texto secundário e bordas usam os tokens do frontmatter. Memória usa violeta, armazenamento azul e bateria verde, com nomes explícitos além da cor.

## Typography

Segoe UI, Arial e sans-serif atendem controles e leitura, sem fontes externas. A10s usa peso forte e estilo normal, sem símbolo adicional; Rota conserva a marca inclinada. Cabeçalhos de seção têm maior hierarquia que títulos internos. Valores de recursos, gráficos e tabelas usam números tabulares.

## Layout

Serviços do servidor e envios da Rota são grupos distintos. Rota apresenta estado do agendamento e resultados registrados em um módulo compacto, com Gerenciar e histórico como ações. Registros sem confirmação têm destaque de atenção sem implicar falha atual. Recursos e gráficos compartilham uma superfície por grupo, sem caixas individuais dentro dos cartões; a cor permanece nos valores, linhas e medidores.

A navegação principal ocupa uma barra lateral fixa de 224px, com rolagem vertical quando necessário. O conteúdo começa após essa barra, sem limite central de 820px, com espaço lateral de 32px; a partir de 1600px, esse espaço aumenta para 48px. Cada seção usa o cabeçalho principal, sem repetir o título na área de conteúdo.

Recursos usam três colunas no desktop, com medidores e leituras na mesma superfície. Serviços e Rota ficam em duas colunas com proporção 1.5:1 e intervalo de 20px; até 1100px, passam a uma coluna. Gráficos usam três colunas no desktop.

Até 760px, a barra lateral passa a navegação horizontal com rolagem local, o conteúdo ocupa toda a largura com espaço lateral de 18px e os recursos e gráficos passam a uma coluna. Cada recurso alinha nome, medidor e valor em uma linha; até 360px, nome e valor usam duas colunas e o medidor ocupa a linha seguinte. Cartões usam espaço interno de 24px no desktop e 20px nesse breakpoint. Navegação e tabelas podem rolar localmente em telas estreitas; a página não deve transbordar.

## Elevation & Depth

Cartões e navegação usam contraste tonal e bordas, sem sombra de repouso. Sombras delimitam somente sobreposições: diálogo, toast e painel de notificações. Transições de botões duram 0.15s; a preferência por movimento reduzido remove transições e animações. Não há animações decorativas.

## Shapes

Cartões têm cantos de 16px; controles usam 7px, navegação 8px e indicadores de estado 20px. Bordas finas delimitam superfícies e campos. Medidores permanecem discretos, com altura de 6px no layout de recursos.

## Components

Nos gráficos, o valor em destaque acompanha a amostra selecionada, com horário e guia vertical correspondentes. Serviços em execução usam texto verde além do estado por escrito. Serviço parado ou não consultado recebe destaque de atenção com descrição explícita, sem converter ausência de consulta em falha comprovada.

A atualização das métricas exibe “Atualizando…” e aria-busy durante a consulta, restaurando o controle ao terminar. Falha mantém o aviso de dados desatualizados; não há confirmação visual inventada. Gráficos exibem guia vertical e horário/valor da leitura selecionada por ponteiro ou teclado. Foco destaca o gráfico em uso. Abrir Rota tem tratamento de ação primária e feedback de hover e pressão, sem movimento contínuo.

Botões primários usam azul com texto escuro, altura mínima de 44px e preenchimento de 11px por 16px. Hover clareia o azul; controles desabilitados reduzem a opacidade para 0.55. Campos usam fundo escuro, borda visível e altura mínima de 44px. O foco visível usa contorno de 3px com afastamento de 4px; na barra lateral, o contorno é amarelo.

Navegação ativa usa superfície azul escura, borda e texto claro; a navegação da Rota fica dentro do módulo. Indicadores de estado combinam texto com cor. Cartões agrupam recursos, serviços e controles sem equiparar estado do executor a entrega.

Visão geral concentra recursos e saúde do executor. Automações contém Rota, agenda, conta e pausas. Atividade apresenta envios registrados. Manutenção apresenta backups e logs.
Acessos incorpora o serviço de arquivos existente na porta 3923, com login próprio. Por decisão do usuário, o controle do celular é entregue como Controlar_A10s.bat em arquivos/Download para execução manual no notebook, sem links de protocolo. A consulta de conectividade é autenticada; a incorporação permite apenas o serviço de arquivos no mesmo host. Não há senha no HTML, execução de comandos pelo servidor nem promessa de acesso às pastas protegidas do Android.
Formulários permanecem montados ao navegar para preservar edições não salvas.
Histórico apresenta gráficos de memória usada, espaço livre e bateria em períodos de 1, 6 e 24 horas. Eixo horizontal usa o horário real; ausência de leitura ou intervalo maior que 150 segundos interrompe a linha. Percentuais usam escala de 0 a 100; espaço livre usa escala local em GiB com limites visíveis. A tabela de até 60 amostras fica recolhida.
Ponteiro e seletor de teclado permitem inspecionar leituras reais por horário. O sino reúne todos os avisos com links para a área correspondente; alertas críticos também permanecem na visão geral. Notificações refletem a última coleta, sem apagar ou modificar registros.

## Do's and Don'ts

- Do manter os últimos valores com aviso explícito quando não houver consulta recente.
- Do preservar significado além da cor no foco de teclado, medidores e estados.
- Do manter formulários montados ao navegar para preservar edições não salvas.
- Don't representar leituras ausentes como zero.
- Don't apresentar executor ativo como comprovação de entrega.
- Don't adicionar fontes externas ou animações decorativas.
