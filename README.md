# A10s | Servidor pessoal Android

Reaproveitei um Samsung Galaxy A10s antigo para manter minhas automações em execução. O celular roda os serviços com Termux, e uso o notebook para acessar os arquivos, acompanhar o aparelho e fazer manutenção.

Este repositório contém o painel de acompanhamento do A10s, as ferramentas de operação e a Rota, uma das automações executadas no servidor. A Rota publica a lista do transporte universitário no WhatsApp nos dias e horários configurados.

Autor: João Vitor Regis.

[![Tests](https://github.com/joaovitorregis/A10s-Servidor-Pessoal/actions/workflows/test.yml/badge.svg)](https://github.com/joaovitorregis/A10s-Servidor-Pessoal/actions/workflows/test.yml)

## O servidor

O painel reúne leituras de armazenamento, memória e bateria, além do estado dos serviços. O histórico preserva as amostras disponíveis e mostra lacunas quando não houve coleta. Métricas bloqueadas pelo Android aparecem como indisponíveis.

O acesso acontece pela rede privada. O serviço de arquivos usa copyparty, com autenticação própria; o controle da tela usa ADB e scrcpy no notebook. Esses serviços dependem da configuração de cada instalação e não ficam prontos apenas ao clonar o repositório.

| Componente | Função |
| --- | --- |
| A10s | Celular Android utilizado como servidor pessoal |
| Termux e runit | Ambiente de execução e supervisão dos processos |
| Painel web | Monitoramento do aparelho e operação da Rota |
| Rota | Agendamento das listas do transporte universitário |
| Notebook | Desenvolvimento, acesso remoto e manutenção |

## Documentação

- [Instalação Android](docs/servidor-android.md)
- [Servidor pessoal e acessos](docs/a10s.md)
- [Monitoramento e alertas](docs/monitoramento.md)
- [Ferramentas do notebook](notebook/README.md)
- [Painel e comandos do notebook](docs/painel-rota.md)
- [Diagnóstico e incidentes](docs/operacao.md)
- [Arquitetura e decisões](docs/arquitetura.md)
- [Backup e restauração](docs/backup.md)
- [Validação real de recuperação](docs/validacao-recuperacao.md)
- [Contribuição e critérios de entrega](CONTRIBUTING.md)

## Execução e validação

O A10s ganhou uma nova função: manter serviços e automações pessoais em execução, sem depender do notebook ligado. O painel permite acompanhar os recursos do aparelho e gerenciar a Rota. Node.js executa o agendador e o conector do WhatsApp; o notebook é utilizado para desenvolvimento e manutenção.

A execução no celular teve um envio agendado confirmado em 25/09/2026, às 02:00, no fuso America/Fortaleza.

## A automação Rota

- Monta a lista com a data e os participantes configurados.
- Agenda a execução por dias da semana, horário e janela de recuperação.
- Confere o grupo de destino e permite um grupo separado para testes.
- Registra o estado antes do envio e verifica o ACK do servidor.
- Bloqueia repetições quando uma tentativa já existe ou seu resultado é incerto.
- Oferece supervisor, trava de concorrência e recuperação do processo no Android.
- Inclui o painel Rota: controle de envios, agenda, pausas por data, prévia da mensagem e histórico de confirmações.
- Permite verificar a conta, vincular pelo QR protegido e escolher grupos pelo identificador, em manutenção com envios desativados.

ACK confirma aceitação pelo servidor; não significa leitura pelos integrantes do grupo.

## Tecnologias

JavaScript · Node.js · Termux · Baileys · runit. O código também preserva componentes da adaptação anterior por navegador com whatsapp-web.js; o conector de operação no Android fica em `socket/`.

## Desenvolvimento local

Use Node.js 24.x, a faixa suportada e testada na CI; outras versões não têm compatibilidade declarada. Para conhecer o painel sem conectar uma conta do WhatsApp, execute `node panel/preview.cjs`. A prévia usa dados fictícios e envio simulado em `http://127.0.0.1:8788`.

```sh
# Na raiz do projeto
npm ci --ignore-scripts
cd socket
npm ci --ignore-scripts
cd ..
cp config.example.json config.json
npm run dry-run
```

O exemplo contém participantes e grupos fictícios e mantém `sendingEnabled: false`. O comando `dry-run` mostra a mensagem que seria gerada, sem enviá-la.

Para desenvolvimento, use Node.js 24, execute `npm test` e acompanhe a CI. No servidor configurado, `npm run doctor` faz um diagnóstico somente leitura; ele não comprova envio nem altera a instalação.

A instalação no Termux está documentada no [guia do servidor Android](docs/servidor-android.md). A autenticação e a habilitação de envio são etapas manuais da instalação.

## Estrutura

```text
src/                  lógica de mensagem e componentes do executor
socket/               conector WhatsApp, autenticação, política e testes
test/                 testes da lógica e dos processos
scheduler.cjs         agendador
service.cjs           controle do supervisor
config.example.json   configuração fictícia, com envios desativados
docs/                 instalação e limites de operação
panel/                painel do A10s e controles da Rota
notebook/             ferramentas de acesso ao celular
painel.ps1            instalação e consulta pelo notebook
```

## Operação pelo painel

O painel A10s separa os recursos do servidor dos controles da Rota. A área Automações permite controlar a agenda, pausar datas, editar a mensagem e consultar confirmações. A configuração de exemplo usa localhost e dados fictícios.

O acesso é pelo notebook na rede privada, sem exposição pública pela internet.

Veja [configuração e uso do painel](docs/painel-rota.md). O painel exige login, protege alterações com token de sessão e confirmação de teste, e mantém credenciais e registros fora do Git.

Ferramentas que interrompem processos reais ficam em [scripts/maintenance/](scripts/maintenance/README.md), separadas dos testes isolados.

## Limites

O funcionamento depende de conexão, energia e permissão para executar o Termux em segundo plano. O Android pode encerrar o processo. A retomada após reinício real, com desbloqueio da tela, e a restauração isolada de backup foram [validadas no A10s em 03/10/2026](docs/validacao-recuperacao.md). Isso não comprova recuperação antes do primeiro desbloqueio, após reset de fábrica ou em outro aparelho. A integração depende da compatibilidade do conector com o WhatsApp.

A configuração pessoal, a sessão do WhatsApp e os registros de operação ficam fora do repositório. Cada instalação requer a configuração dos grupos e participantes e a vinculação de uma conta do WhatsApp.

## Autoria e licenças

Projeto pessoal de [João Vitor Regis](https://github.com/joaovitorregis), desenvolvido com apoio de ferramentas de IA.

- Código, scripts, testes e configuração de exemplo: [MIT](LICENSE).
- README e documentação em `docs/`: [CC BY 4.0](LICENSE-MATERIALS), com atribuição a João Vitor Regis.

As dependências conservam suas próprias licenças.
