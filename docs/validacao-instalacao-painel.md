# Ensaio isolado da preparação do painel — 22/10/2026

Base revisada: `493f03b92c349b9500706096f2c984d0b26adebc`. Ambiente local: Windows, PowerShell e Node.js 24.21.0. Este registro cobre a correção do comando público `painel.ps1 -Action Install`, sem executar instalação operacional.

## Reprodução e correção

`node --test test/panel-stage.test.cjs` executa o script público substituindo as fronteiras de SSH, SCP, Node e HTTP por funções locais. O upload copia arquivos reais para uma pasta temporária. As cópias de dependências da instalação são reproduzidas com arquivos do repositório. O teste lê o inventário completo de `panel/install.cjs` sem executar o instalador e executa os testes candidatos na pasta temporária com Node real.

Antes da correção, o teste falhou com `Incomplete staging: test/telemetry.test.cjs, test/integrations.test.cjs`. Após incluir esses arquivos, a execução dos testes na preparação revelou outro bloqueio: `Cannot find module '../src/health.cjs'`. A telemetria importa esse módulo, mas a preparação não o copiava. A correção copia a versão já instalada e inclui seu hash na verificação de dependências preservadas; não promove uma versão local desse módulo.

O resultado final do ensaio foi: 24 arquivos candidatos presentes e 55 testes da preparação aprovados, sem falhas ou testes ignorados. A remoção de qualquer um dos dois uploads ou da cópia de `src/health.cjs` volta a quebrar esse contrato.

## Verificações e limites

- `npm ci --ignore-scripts --no-audit --no-fund` na raiz e em `socket/`: concluídos. O npm informou depreciação de `glob@10.5.0` e `fluent-ffmpeg@2.1.3`; dependências não foram atualizadas nesta correção.
- `npm test`: 109 testes, 108 aprovados, nenhuma falha e um ignorado no Windows: exclusão por `flock` e liberação após SIGKILL real, específico de Linux. Os 55 testes internos da preparação são relatados separadamente pelo ensaio.
- Verificação de sintaxe dos JavaScript rastreados e dos PowerShell alterados, e `git diff --check`: sem erros.

Nenhum SSH, credencial real, envio, serviço, reboot ou checkout operacional foi utilizado. As instalações npm acessam o registro de pacotes; o ensaio usa somente arquivos locais e listeners de loopback dos testes, sem conexão externa. O instalador, sua promoção, rollback operacional e comandos runit não foram executados. O ensaio PowerShell é específico de Windows e é ignorado no Linux; a CI mantém os demais testes nas duas plataformas. Não houve nova validação no Android, nem validação de boot ou copyparty. Para o escopo separado dos serviços privados, veja [backup e restauração](backup.md#serviços-adicionais-privados).
