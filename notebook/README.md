# Controle do A10s

O botão **Controlar A10s** do painel abre o scrcpy no Windows, pelo protocolo `a10s-control://open`. Não há terminal remoto ou comandos arbitrários nesse protocolo.

## Instalação

Requer ADB e scrcpy no PATH. Faça o pareamento pela Depuração sem fio do Android, depois execute no PowerShell:

```powershell
./install-control.ps1 -DeviceSerial SERIAL_DO_APARELHO -ServerAddress IP_PRIVADO_DO_APARELHO
```

O instalador registra o protocolo apenas para o usuário atual, em `HKCU\Software\Classes\a10s-control`. Serial e IP ficam nessa chave, não no repositório. O handler valida a ação e a identidade do dispositivo antes de abrir o scrcpy. Não habilita ADB TCP sem autenticação.

O navegador pode pedir autorização para abrir o aplicativo. Fora da rede local, é necessário que o transporte ADB autenticado esteja conectado pelo endereço privado. Após reinício do Android, a porta da depuração pode mudar; reconecte pelo novo endereço. Na mesma rede, o handler procura o dispositivo pareado pelo mDNS.

## Remoção

Remova somente a chave `HKCU\Software\Classes\a10s-control` no Editor do Registro. Isso remove o botão como lançador no Windows, sem alterar o pareamento ADB ou a automação do celular.

## Arquivos

A área Acessos incorpora o serviço existente na porta 3923. Ele mantém sua própria autenticação e permissões para armazenamento interno, cartão SD e Termux. O painel não encaminha sua senha nem amplia as permissões do Android. “Disponível” indica conexão TCP; não comprova login nem acesso a todos os volumes.

## Entrada sem senha em dispositivo confiável

Opcionalmente, o servidor lê `runtime/panel-trusted-peers.json`, com formato `{"peers":["IP_TAILSCALE_DO_NOTEBOOK"]}`. Esse arquivo privado não deve ser publicado. Use somente endereços individuais, nunca uma sub-rede ou o endereço de um proxy compartilhado.

A entrada automática verifica o endereço real da conexão, ignora cabeçalhos de encaminhamento e cria uma sessão com cookie HttpOnly, SameSite Strict e token CSRF. A sessão automática fica vinculada ao IP autorizado. Os demais dispositivos continuam usando a senha. Remover o IP da lista e reiniciar somente o painel revoga a liberação e as sessões existentes, sem alterar a senha ou a automação. “Sair” encerra a sessão atual; recarregar a página no notebook autorizado permite uma nova entrada automática.
