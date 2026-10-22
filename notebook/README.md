# Controle do A10s

## Uso atual: arquivo BAT

O painel não tenta mais abrir aplicativos por protocolo. O arquivo `Controlar_A10s.bat` fica em **arquivos > Download** no armazenamento do servidor. Baixe para o notebook e execute quando quiser. Ele contém o código de controle e não depende dos arquivos `.ps1` deste repositório.

Requer o ADB, scrcpy e a configuração inicial do dispositivo em `HKCU\Software\Classes\a10s-control`. Em notebook novo, faça o pareamento e execute uma vez o procedimento de [Instalação](#instalação) abaixo: `install-control.ps1` grava serial, endereço e caminhos das ferramentas nessa chave, também usada pelo BAT. Depois disso, o BAT dispensa os `.ps1` em cada abertura. O arquivo verifica o serial antes de controlar o aparelho, procura uma conexão já pareada e pode descobri-la pelo mDNS na rede local. Não ativa ADB TCP sem autenticação. Se o aparelho estiver desconectado ou faltar uma ferramenta, mostra o erro e aguarda Enter.

## Método anterior: protocolo do Windows

Os scripts de protocolo permanecem para referência e manutenção de instalações antigas. O painel atual não oferece o botão de lançamento. O BAT usa a mesma configuração inicial da seção Instalação, mas não exige escolher um aplicativo padrão no navegador.

O protocolo `a10s-control://open` foi usado para abrir o scrcpy no Windows. Ele não oferece terminal remoto ou comandos arbitrários.

## Instalação

Requer ADB e scrcpy no PATH. Faça o pareamento pela Depuração sem fio do Android, depois execute no PowerShell:

```powershell
./install-control.ps1 -DeviceSerial SERIAL_DO_APARELHO -ServerAddress IP_PRIVADO_DO_APARELHO
```

O instalador registra o protocolo apenas para o usuário atual, em `HKCU\Software\Classes\a10s-control`. Serial e IP ficam nessa chave, não no repositório. O handler valida a ação e a identidade do dispositivo antes de abrir o scrcpy. Não habilita ADB TCP sem autenticação.

O navegador pode pedir autorização para abrir o aplicativo. Fora da rede local, é necessário que o transporte ADB autenticado esteja conectado pelo endereço privado. Após reinício do Android, a porta da depuração pode mudar; reconecte pelo novo endereço. Na mesma rede, o handler procura o dispositivo pareado pelo mDNS.

Se o navegador disser que não existe aplicativo associado, abra **Configurações do Windows > Aplicativos > Aplicativos padrão**, procure o tipo de link `a10s-control` e selecione **A10s - Controle remoto**. O instalador cadastra apenas esse protocolo com um ProgID próprio e `RegisteredApplications`; não altera outros tipos de links e não modifica a escolha protegida do usuário (`UserChoice`).

O instalador salva os caminhos completos do ADB, scrcpy e Windows PowerShell. Após atualizar ou mover o scrcpy, execute novamente o instalador. Falhas do lançador são exibidas e registradas em `%LOCALAPPDATA%\A10sControl\control.log`. Para conferir sintaxe, executáveis e registro sem abrir o controle, execute `./diagnose-control.ps1`.
Depois de registrar o protocolo, o instalador notifica o Windows com `SHChangeNotify(SHCNE_ASSOCCHANGED)`. Isso atualiza o cache de associações sem abrir aplicativos ou remover confirmações do navegador. Se o navegador não reconhecer uma associação recém-instalada, feche e abra o navegador manualmente, preservando suas abas.
O diagnóstico também consulta `AssocQueryStringW` com `ASSOCF_IS_PROTOCOL` para conferir a resolução do comando, executável e nome do aplicativo pelo Windows, sem executá-los. Se essas consultas funcionarem, mas o navegador disser que não existe um handler, encerre o navegador pelo menu Sair: apenas fechar uma janela pode deixar processos antigos ativos. Limpe as mensagens antigas do Console antes de repetir o teste.

## Remoção

Remova somente a chave `HKCU\Software\Classes\a10s-control` no Editor do Registro. Isso também remove os parâmetros necessários ao BAT, que deixará de funcionar até repetir a instalação. Não altera o pareamento ADB ou a automação do celular.
Para remover também o cadastro na lista de aplicativos padrão, remova a entrada **A10s - Controle remoto** de `HKCU\Software\RegisteredApplications` e as chaves próprias `HKCU\Software\A10sControl` e `HKCU\Software\Classes\A10sControl.Url`. Preserve todas as outras entradas.

## Arquivos

A área Acessos incorpora o serviço existente na porta 3923. Ele mantém sua própria autenticação e permissões para armazenamento interno, cartão SD e Termux. O painel não encaminha sua senha nem amplia as permissões do Android. “Disponível” indica conexão TCP; não comprova login nem acesso a todos os volumes.

## Entrada sem senha em dispositivo confiável

Opcionalmente, o servidor lê `runtime/panel-trusted-peers.json`, com formato `{"peers":["IP_TAILSCALE_DO_NOTEBOOK"]}`. Esse arquivo privado não deve ser publicado. Use somente endereços individuais, nunca uma sub-rede ou o endereço de um proxy compartilhado.

A entrada automática verifica o endereço real da conexão, ignora cabeçalhos de encaminhamento e cria uma sessão com cookie HttpOnly, SameSite Strict e token CSRF. A sessão automática fica vinculada ao IP autorizado. Os demais dispositivos continuam usando a senha. Remover o IP da lista e reiniciar somente o painel revoga a liberação e as sessões existentes, sem alterar a senha ou a automação. “Sair” encerra a sessão atual; recarregar a página no notebook autorizado permite uma nova entrada automática.
