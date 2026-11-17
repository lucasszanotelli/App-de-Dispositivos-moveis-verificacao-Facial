# Notas Biométricas

Aplicativo Flutter para um seminário de dispositivos móveis sobre biometria.
A tela inicial mostra notas comuns. O botão **Notas privadas** solicita Face ID
ou Touch ID antes de abrir a área privada.

## Funcionalidades

- Criar, visualizar, editar e excluir notas com título e conteúdo.
- Notas comuns e privadas salvas localmente, mesmo após encerrar o aplicativo.
- Confirmação antes de excluir e validação para impedir notas totalmente vazias.
- Nova autenticação ao sair da área privada ou colocar o aplicativo em segundo plano.
- Rascunhos privados não salvos são descartados ao bloquear.
- Interface em português, sem cadastro, internet ou servidor.

## Armazenamento e biometria

Conforme o escopo do seminário, **não há criptografia**. Tanto notas comuns como
privadas são armazenadas como JSON em `shared_preferences`, em chaves separadas.
O bloqueio biométrico protege o acesso pela interface; ele não criptografa os
arquivos nem impede sua leitura por alguém com acesso aos dados do aplicativo.
Use apenas dados fictícios na demonstração.

O `local_auth` delega a autenticação ao sistema operacional, usando as biometrias
cadastradas no aparelho. O app não recebe nem armazena rostos ou impressões digitais.
`biometricOnly: true` exige biometria, sem alternativa de senha dentro do app.
O conteúdo privado só é carregado após sucesso e é removido da lista em memória
quando a sessão é bloqueada. Cancelamentos e erros não liberam o acesso.

## Executar no iOS pelo Xcode

Requisitos: macOS, Flutter compatível com o `pubspec.yaml` (Dart 3.13.7 ou superior
na série 3), Xcode completo com uma plataforma iOS e simulador instalados.
O projeto usa iOS 15 ou superior e integração Swift Package Manager do Flutter.

1. Instale o Xcode e abra-o para concluir a instalação dos componentes.
2. Em **Xcode > Settings > Locations > Command Line Tools**, selecione o Xcode instalado.
3. Em **Xcode > Settings > Components**, instale a plataforma iOS caso necessário.
4. Na pasta deste projeto, execute:

   ```sh
   flutter doctor -v
   flutter pub get
   open -a Simulator
   flutter devices
   flutter run -d <identificador-do-simulador>
   ```

5. Depois da preparação pelo Flutter, abra `ios/Runner.xcworkspace` no Xcode,
   selecione o esquema **Runner** e um simulador de iPhone, e use **Run**.

A descrição de uso do Face ID já está configurada em `ios/Runner/Info.plist`.
O idioma de desenvolvimento do Runner é português do Brasil.

## Primeiro build e iPhone físico

Antes de executar diretamente pelo Xcode pela primeira vez, prepare os plugins:

```sh
flutter pub get
flutter build ios --debug --no-codesign
open ios/Runner.xcworkspace
```

Esse build gera a integração Swift Package Manager dos plugins, incluindo
`local_auth_darwin`. Se o Xcode estava aberto antes, feche e reabra o workspace.
Para instalar no iPhone, selecione o target **Runner**, abra **Signing & Capabilities**,
marque **Automatically manage signing** e escolha sua conta em **Team**.
Adicione a conta em **Xcode > Settings > Apple Accounts**, se necessário.
Selecione seu iPhone como destino e use **Run**. O build sem assinatura acima
apenas prepara e valida o projeto; a instalação no aparelho exige essa assinatura.

## Roteiro do seminário

1. No simulador de iPhone com Face ID, habilite **Features > Face ID > Enrolled**.
   Dependendo da versão do Xcode, os menus podem aparecer em **Hardware**.
2. Crie uma nota comum e mostre que ela aparece sem autenticação.
3. Toque em **Notas privadas**. Aceite a permissão do Face ID se solicitada.
4. Com o diálogo ativo, use **Features > Face ID > Matching Face** para simular sucesso.
5. Crie uma nota privada, volte e mostre que ela não aparece nas notas comuns.
6. Abra novamente a área privada e simule **Non-matching Face** ou cancele.
   O acesso deve continuar bloqueado; o sistema pode permitir uma nova tentativa no diálogo.
7. Autentique novamente, abra uma nota e digite um rascunho sem salvar.
   Vá à tela inicial do iPhone e volte ao app: a área estará bloqueada e o rascunho será descartado.
8. Desabilite **Enrolled** e tente abrir a área privada para mostrar o aviso de biometria não cadastrada.
9. Encerre e reabra o app para demonstrar a persistência das notas salvas.

No simulador, o reconhecimento é uma simulação controlada pelo apresentador;
a validação de um rosto real requer um iPhone físico.

## Organização e validação

`lib/screens` contém as telas; `lib/controllers` coordena notas e sessão privada;
`lib/services` isola autenticação e persistência; `lib/models` define a nota.
As interfaces `BiometricService` e `NoteRepository` permitem testes sem plugins nativos.

```sh
flutter analyze
flutter test
```

Os testes cobrem CRUD, separação das notas, falha de armazenamento, autenticação
recusada/indisponível, resultados assíncronos após bloqueio, navegação e ciclo de vida.
Os testes automatizados usam implementações em memória. Os diálogos reais de Face ID,
a integração nativa e a persistência do plugin devem ser conferidos no simulador
com o roteiro acima.

## Referências

- [local_auth](https://pub.dev/packages/local_auth)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
