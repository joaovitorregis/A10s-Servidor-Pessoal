# Monitoramento do servidor

A tela **Servidor** consulta `/api/server`, protegida pela mesma sessão do painel. Não abre uma nova porta pública nem permite executar comandos, apagar arquivos ou reiniciar serviços.

## Coleta

O painel coleta uma amostra por minuto, mesmo sem visitantes, enquanto seu processo estiver ativo. Mantém até 1.440 amostras das últimas 24 horas em `runtime/server-metrics.json`. O arquivo contém métricas, não mensagens ou credenciais. O histórico continua após reiniciar o painel; períodos sem coleta permanecem como lacunas.

A interface prioriza armazenamento, memória e bateria. Detalhes técnicos ficam recolhidos. O histórico permite selecionar 1, 6 ou 24 horas e mostra até 60 amostras reais distribuídas pelo período, sem interpolação. A organização foi informada pelo [server-box](https://github.com/felipenalves/server-box), citado no [artigo de Felipe Natanael](https://inovadigitalid.com/news/servidor-j5-prime); a implementação permanece própria e mantém a autenticação do Rota.

- RAM: `MemTotal` e `MemAvailable` de `/proc/meminfo`.
- Armazenamento: sistema de arquivos da instalação, com espaço disponível para gravação.
- CPU global: diferenças de `/proc/stat`, quando permitido. Carga: `/proc/loadavg`.
- Bateria e temperatura da bateria: `termux-battery-status`, com prazo máximo de execução. Temperatura da bateria não é temperatura da CPU.
- Painel: RAM residente, tempo do processo e CPU média entre amostras, relativa a um núcleo.
- Serviços: consulta `sv status`; saúde do executor exige PID, supervisor e heartbeat correspondentes.
- SSH: conexão apenas a `127.0.0.1:8022`; não comprova acesso remoto pela rede.
- Reinícios: mudanças de PID entre amostras registradas nas últimas 24 horas. Não é contagem absoluta; reinícios entre amostras podem não ser observados.

Métricas bloqueadas aparecem como **Indisponível**. Sem root, versões do Android restringem CPU global, tráfego de rede e tempo desde o boot. O monitor não altera permissões nem instala Shizuku para contornar essas restrições.

## Alertas

Os alertas aparecem no painel: armazenamento com menos de 1 GiB livre ou uso de 90%; RAM ou CPU a partir de 90%; bateria até 20% sem alimentação; temperatura da bateria a partir de 40 °C; executor sem saúde; estado dos envios ilegível; tentativas incertas; snapshot ausente ou com mais de sete dias; falha ao salvar métricas. São limites operacionais iniciais, não diagnósticos de hardware. Não são enviadas notificações ao WhatsApp.

## Backups e entrega

Procura manifestos de snapshots em `backups` e em `~/.local/share/rota-recovery`, com varredura limitada. Cópias de instalação não equivalem a snapshots completos. Um manifesto encontrado não comprova integridade atual nem restauração. Backups guardados somente no notebook não são visíveis ao monitor do celular.

Mostra tamanho dos backups de instalação e dos logs conhecidos sem ler seu conteúdo para a interface. O histórico de envios continua sendo a fonte da confirmação do WhatsApp. Serviço em execução não comprova envio ou leitura.
