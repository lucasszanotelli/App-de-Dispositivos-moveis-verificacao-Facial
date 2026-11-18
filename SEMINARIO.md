# Seminário — Notas Biométricas

**Tema:** autenticação biométrica em um aplicativo Flutter.  
**Duração sugerida:** 12 a 15 minutos, incluindo a demonstração.  
**Projeto:** aplicativo local de notas comuns e privadas, com acesso à área privada por Face ID ou Touch ID.

> Use os tópicos como conteúdo dos slides e as seções “Fala sugerida” como roteiro oral. Os caminhos indicam os arquivos que você pode abrir na IDE durante a apresentação.

## 1. Abertura e proposta — 1 minuto

### No slide

- Notas Biométricas.
- Aplicativo de notas desenvolvido em Flutter e Dart.
- Duas áreas: notas comuns e notas privadas.
- Integração com a autenticação biométrica do dispositivo.

### Fala sugerida

“Neste seminário, vou apresentar o Notas Biométricas, um aplicativo que permite criar e organizar anotações no próprio aparelho. A proposta é demonstrar como um aplicativo Flutter utiliza a biometria do dispositivo para controlar o acesso a uma área privada.

As notas comuns ficam disponíveis na tela inicial. Para acessar as notas privadas, o usuário precisa se autenticar com Face ID ou Touch ID, conforme o recurso disponível no aparelho.”

## 2. Problema e objetivo — 1 minuto

### No slide

- Separar anotações de acesso livre das que exigem autenticação.
- Demonstrar o uso de um recurso nativo do dispositivo.
- Manter as notas salvas entre execuções do app.
- Trabalhar navegação, estado e ciclo de vida do aplicativo.

### Fala sugerida

“O problema escolhido foi a necessidade de separar anotações comuns de outras cujo acesso pela interface deve ser restrito. Para isso, o projeto combina o gerenciamento de notas com uma etapa de autenticação biométrica.

O objetivo é demonstrar essa integração e os cuidados necessários ao abrir, fechar e bloquear a área privada. O aplicativo funciona localmente, sem cadastro, servidor ou necessidade de internet para usar suas funcionalidades.”

## 3. Funcionalidades — 1 minuto

### No slide

- Criar, visualizar, editar e excluir notas.
- Salvar título, conteúdo e data da última alteração.
- Exibir as notas mais recentes primeiro.
- Impedir o salvamento de notas totalmente vazias.
- Pedir confirmação antes da exclusão.
- Bloquear a área privada ao sair dela ou colocar o app em segundo plano.

### Fala sugerida

“O aplicativo implementa um CRUD, que significa criar, consultar, atualizar e excluir registros. Essas operações estão disponíveis tanto para notas comuns quanto para notas privadas.

Também existem cuidados de usabilidade: uma nota precisa ter pelo menos título ou conteúdo, a exclusão exige confirmação e a listagem apresenta as notas por ordem de atualização. Uma nota com conteúdo, mas sem título, aparece como ‘Sem título’.”

## 4. Tecnologias utilizadas — 1 minuto

### No slide

| Tecnologia ou recurso | Papel no projeto |
| --- | --- |
| Flutter e Dart | Interface e lógica do aplicativo |
| Material 3 | Componentes visuais e tema |
| `local_auth` | Solicitação de autenticação biométrica ao sistema |
| `shared_preferences` | Persistência local das notas em JSON |
| `ChangeNotifier` e `AnimatedBuilder` | Comunicação de mudanças de estado para a interface |
| `flutter_localizations` | Componentes e formatação em português do Brasil |

### Fala sugerida

“A interface e a lógica foram desenvolvidas com Flutter e Dart. O pacote local_auth faz a comunicação com a autenticação nativa do aparelho. Já o shared_preferences armazena as notas localmente, convertidas para JSON.

O gerenciamento de estado utiliza ChangeNotifier. Quando o controlador altera os dados ou o estado de uma operação, ele notifica a interface, que é reconstruída por meio do AnimatedBuilder.

Embora Flutter permita desenvolver para diferentes plataformas, este repositório contém a estrutura nativa de iOS. A demonstração está preparada para esse ambiente.”

**Arquivo para mostrar:** `pubspec.yaml`.

## 5. Organização do código — 1 minuto e 30 segundos

### No slide

```text
lib/
├── main.dart                         Inicialização e ciclo de vida
├── models/
│   └── note.dart                     Modelo de uma nota
├── screens/
│   ├── notes_screen.dart             Listagem e acesso à área privada
│   └── note_editor.dart              Criação, edição e exclusão
├── controllers/
│   └── notes_controller.dart         Estado, operações e sessão privada
└── services/
    ├── biometric_service.dart        Autenticação biométrica
    └── note_repository.dart          Leitura e gravação local
```

### Fala sugerida

“O código foi organizado por responsabilidades. O modelo Note representa uma anotação com identificador, título, conteúdo e data de atualização. As telas apresentam os dados e recebem as ações do usuário.

O NotesController coordena as operações e controla se a área privada está desbloqueada. Os serviços ficam responsáveis pela comunicação com a biometria e com o armazenamento.

No main.dart, as implementações desses serviços são passadas ao controlador. Essa organização permite substituir os serviços reais por versões simuladas nos testes.”

**Arquivos para mostrar:** `lib/main.dart`, `lib/models/note.dart` e o início de `lib/controllers/notes_controller.dart`.

## 6. Como a autenticação funciona — 1 minuto e 30 segundos

### No slide

```text
Usuário toca em “Notas privadas”
                  ↓
App verifica a disponibilidade e o cadastro de biometria
                  ↓
Sistema operacional solicita a autenticação
                  ↓
         Autenticação aceita?
           ↙             ↘
         Não             Sim
          ↓               ↓
Mantém bloqueado    Carrega as notas privadas
e informa o erro   e abre a área privada
```

### Fala sugerida

“Quando o usuário toca em Notas privadas, o aplicativo verifica se existe biometria disponível e cadastrada. Em seguida, solicita a autenticação ao sistema operacional.

O aplicativo não captura nem armazena rostos ou impressões digitais. Ele recebe o resultado da autenticação realizada pelo sistema. Somente depois do sucesso o controlador carrega as notas privadas e libera a navegação.

Se a autenticação for cancelada, recusada ou ocorrer um erro, o acesso permanece bloqueado. A configuração biometricOnly exige biometria nessa solicitação, sem alternativa de senha oferecida pelo aplicativo.”

**Trecho para mostrar — `lib/services/biometric_service.dart`:**

```dart
return await _auth.authenticate(
  localizedReason: 'Autentique-se para acessar suas notas privadas.',
  biometricOnly: true,
  persistAcrossBackgrounding: false,
);
```

**Detalhe de integração:** `ios/Runner/Info.plist` contém `NSFaceIDUsageDescription`, com a descrição do motivo de uso do Face ID.

## 7. Armazenamento e limite da proteção — 1 minuto

### No slide

- Notas convertidas em JSON.
- Chaves separadas: `notes_v1` e `private_notes_v1`.
- Dados persistem após fechar e abrir o aplicativo.
- A implementação atual não possui criptografia.
- A biometria controla o acesso pela interface.

### Fala sugerida

“As notas são convertidas para JSON e armazenadas localmente com shared_preferences. As comuns e as privadas usam chaves diferentes, mantendo as duas listas separadas.

Um limite importante do projeto é que os dados não são criptografados. Portanto, o termo ‘privada’ indica uma área cujo acesso pela interface exige biometria. Isso não impede que alguém com acesso aos dados armazenados pelo aplicativo consiga ler seu conteúdo.

Uma evolução seria adicionar armazenamento criptografado e gerenciamento adequado de chaves. Na demonstração, vou utilizar apenas anotações fictícias.”

**Arquivo para mostrar:** `lib/services/note_repository.dart`.

## 8. Bloqueio e ciclo de vida — 1 minuto

### No slide

- Sair da área privada encerra a sessão.
- Ir para segundo plano bloqueia o acesso.
- A lista privada é esvaziada em memória ao bloquear.
- Rascunhos privados não salvos são descartados ao bloquear.
- Respostas assíncronas antigas não reabrem uma sessão bloqueada.

### Fala sugerida

“A autenticação vale para a sessão atual da área privada. Quando o usuário sai dessa área ou coloca o aplicativo em segundo plano, o controlador bloqueia a sessão, esvazia a lista privada em memória e exige uma nova autenticação.

O aplicativo também cobre o conteúdo quando deixa de estar ativo. Existe um cuidado específico: o diálogo do Face ID pode deixar o app temporariamente inativo. Por isso, o estado inactive apenas oculta o conteúdo; o bloqueio ocorre nos estados hidden, paused ou detached.

Outro cuidado é o contador de sessão. Se uma autenticação ou leitura terminar depois de um bloqueio, seu resultado é desconsiderado, evitando reabrir uma sessão antiga.”

**Arquivos para mostrar:** `didChangeAppLifecycleState` em `lib/main.dart` e os métodos `unlock()` e `lock()` em `lib/controllers/notes_controller.dart`.

## 9. Demonstração prática — 3 minutos

### Preparação antes da apresentação

- Deixe o aplicativo aberto no simulador ou iPhone e confira a execução antecipadamente.
- No simulador com Face ID, habilite **Features > Face ID > Enrolled**. Conforme a versão, o menu pode aparecer em **Hardware**.
- Use dados fictícios, como “Lista de estudos” e “Planejamento da apresentação”.
- No simulador, utilize as opções de correspondência de rosto com o diálogo de autenticação aberto.

### Sequência principal

| Passo | Ação | O que explicar ou observar |
| --- | --- | --- |
| 1 | Criar uma nota comum chamada “Lista de estudos” | A área comum funciona sem autenticação. |
| 2 | Abrir a nota, alterar o conteúdo e salvar | O mesmo editor permite criar e atualizar. |
| 3 | Tocar em **Notas privadas** | O app solicita a autenticação nativa. |
| 4 | No simulador, escolher **Matching Face** | Após o sucesso, a área privada é aberta. |
| 5 | Criar “Planejamento da apresentação” e salvar | A nota fica na lista privada. |
| 6 | Tocar no cadeado para sair | A sessão é bloqueada e a nota privada não aparece na lista comum. |
| 7 | Tentar entrar novamente e cancelar a autenticação | O cancelamento mantém o acesso bloqueado. |
| 8 | Autenticar, abrir a nota privada e digitar sem salvar | Preparar um rascunho para demonstrar o bloqueio. |
| 9 | Ir à tela inicial do iPhone e voltar ao app | O app retorna à tela inicial de notas; o rascunho privado é descartado. |
| 10 | Autenticar novamente e abrir a nota | O conteúdo salvo anteriormente continua disponível. |

### Se houver tempo

- Excluir uma nota e mostrar a confirmação.
- Tentar salvar uma nota totalmente vazia e mostrar a validação.
- Encerrar e reabrir o aplicativo para demonstrar a persistência local.
- Desabilitar **Enrolled** no simulador e tentar acessar a área privada para mostrar o aviso de biometria não cadastrada. Reabilitar depois.

### Fala de apoio

“No simulador, estou controlando o resultado da autenticação pelo menu do ambiente de desenvolvimento. Isso demonstra o fluxo do aplicativo. O reconhecimento de um rosto real precisa ser demonstrado em um aparelho físico compatível.”

**Se a biometria falhar na apresentação:** mostre a mensagem exibida e explique que o acesso permanece bloqueado. Confira o cadastro de biometria antes de tentar novamente.

## 10. Testes e validação — 45 segundos

### No slide

- Testes do controlador: autenticação, CRUD, separação das listas e falhas.
- Testes da interface: edição, exclusão, validação e navegação.
- Teste de bloqueio ao entrar em segundo plano.
- Serviços simulados para execução sem biometria real.

### Fala sugerida

“O projeto possui testes automatizados para a lógica e para a interface. Eles verificam, por exemplo, que as notas privadas só são lidas após autenticação aceita, que uma resposta atrasada não reabre a sessão e que uma falha de gravação preserva a lista anterior em memória.

Nos testes, a biometria e o repositório são simulados. Por isso, os diálogos nativos e a persistência real dos plugins também precisam ser conferidos no simulador ou no aparelho.”

**Arquivos para mostrar:** `test/notes_controller_test.dart`, `test/widget_test.dart` e `test/fakes.dart`.

**Comandos disponíveis para validação antes da apresentação:**

```sh
flutter analyze
flutter test
```

> Execute os comandos antes de afirmar que a análise e os testes passaram. A existência dos testes não comprova, por si só, o resultado da execução atual.

## 11. Encerramento — 30 segundos

### No slide

- Integração entre Flutter e um recurso nativo do aparelho.
- Separação entre interface, controle, autenticação e persistência.
- Controle de sessão associado ao ciclo de vida.
- Evolução proposta: criptografia dos dados locais.

### Fala sugerida

“O projeto demonstra como integrar autenticação biométrica a um aplicativo Flutter, combinando operações de notas, persistência local e controle de sessão.

O principal aprendizado foi que a integração não termina no reconhecimento biométrico: também é necessário tratar cancelamentos, erros, navegação e mudanças no ciclo de vida. Como próximo passo, eu destacaria a criptografia das notas para ampliar a proteção dos dados armazenados. Obrigado.”

## Perguntas que podem surgir

### O aplicativo armazena a impressão digital ou o rosto?

Não. O serviço utiliza a autenticação do sistema operacional e recebe seu resultado. O código do app não captura nem armazena esses dados biométricos.

### As notas privadas estão criptografadas?

Não. Elas são armazenadas em JSON, com controle de acesso pela interface. Criptografia é uma melhoria proposta, ainda não implementada.

### Por que usar `shared_preferences`?

Ele permite implementar uma persistência simples de chave e valor para o escopo do protótipo. Neste projeto, a lista inteira é serializada em uma string JSON. Para ampliar o volume de dados e os recursos de consulta, seria necessário avaliar outra solução de armazenamento.

### O aplicativo funciona sem internet?

Sim. As operações de notas, o armazenamento e a autenticação utilizada pelo aplicativo são locais.

### Qualquer pessoa com biometria cadastrada no aparelho pode entrar?

O app aceita o resultado da autenticação do sistema e não distingue pessoas por conta própria. Ele não possui cadastro de usuários nem associa notas a uma identidade biométrica específica.

### Existe alternativa de senha no aplicativo?

Não. A solicitação usa `biometricOnly: true`. Se a biometria estiver indisponível, o app informa o problema e mantém a área bloqueada.

### O que acontece com alterações não salvas?

O app não possui salvamento automático. No editor privado, o bloqueio encerra a tela e descarta o rascunho. Notas que já haviam sido salvas continuam no armazenamento.

### Por que separar serviços e controlador?

Para manter responsabilidades definidas e permitir testes com implementações simuladas. O controlador depende das interfaces `BiometricService` e `NoteRepository`, sem precisar executar os plugins nativos nos testes.

### O projeto já está configurado para Android?

Este repositório contém a estrutura nativa de iOS. Uma versão Android exigiria adicionar e configurar essa plataforma, além de validar o comportamento dos plugins e da autenticação nela.

## Cola rápida para revisar antes de falar

1. **Proposta:** notas comuns e privadas em um app local.
2. **Tecnologias:** Flutter, Dart, `local_auth` e `shared_preferences`.
3. **Organização:** telas → controlador → serviços; modelo representa a nota.
4. **Biometria:** sistema autentica; app recebe o resultado.
5. **Acesso:** notas privadas são carregadas somente após sucesso.
6. **Sessão:** sair ou ir para segundo plano exige nova autenticação.
7. **Persistência:** JSON em chaves separadas; sem criptografia.
8. **Demonstração:** criar → autenticar → salvar privada → bloquear → cancelar → testar segundo plano.
9. **Qualidade:** testes com serviços simulados; integração nativa conferida na demonstração.
10. **Evolução:** criptografia e armazenamento adequado a uma versão mais completa.
