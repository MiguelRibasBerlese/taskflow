# TaskFlow — Controle de Tarefas

Aplicativo mobile/web de controle de tarefas desenvolvido com Flutter e Dart.
**Parte 2:** migração para Firebase (Auth + Cloud Firestore), consumo de API REST
(IBGE) e redesign de UI com design system (Material 3 + Google Fonts).

## Disciplina
AC622 — Programação Mobile II
UNAERP — Campus Ribeirão Preto
Professor: Prof. Dr. Samuel Oliva

## Integrantes
- Miguel Ribas Berlese — 839938
- Enzo Shimada Daun — 840552

## Modo seguro x Modo Firebase

O app roda em dois modos, controlados por `lib/firebase_config.dart`:

| `kFirebaseEnabled` | Comportamento |
|--------------------|---------------|
| `false` (padrão)   | **Modo seguro** — dados mockados em memória (Parte 1). Roda sem nenhuma configuração de Firebase. A tela de Estados (IBGE) já funciona aqui. |
| `true`             | **Modo Firebase** — autenticação real, persistência no Firestore, listagens em tempo real (StreamBuilder) e perfil do usuário. |

> O modo seguro existe porque `firebase_options.dart` só é gerado por
> `flutterfire configure` (que exige credenciais Google + um projeto Firebase).
> Assim o app **compila e roda** mesmo antes do Firebase ser configurado.

## Como executar (modo seguro)
1. Instale o Flutter SDK (https://flutter.dev)
2. `flutter pub get`
3. `flutter run -d chrome`

Credencial de demonstração (modo seguro):
- E-mail: `aluno@unaerp.br`
- Senha: `123456`

## Habilitar o Firebase (modo Firebase)

1. Acesse https://console.firebase.google.com e crie o projeto `taskflow-ac622`.
2. Ative **Authentication → Email/Senha**.
3. Ative **Cloud Firestore → Production mode → us-east1**.
4. Em **Firestore → Rules**, cole o conteúdo de [`firestore.rules`](firestore.rules) e publique.
5. No terminal, na raiz do projeto:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=taskflow-ac622   # gera lib/firebase_options.dart
   ```
6. Em `lib/main.dart`: descomente os imports de `firebase_core`/`firebase_options`
   e a chamada a `Firebase.initializeApp(...)`.
7. No `web/index.html`: descomente os scripts do Firebase JS SDK.
8. Em `lib/firebase_config.dart`: mude `kFirebaseEnabled` para `true`.
9. `flutter run -d chrome`

> As consultas de `streamTarefas`/`pesquisarTarefas` usam `where(uid) + orderBy/range`.
> Na primeira execução o Firestore pode pedir a criação de um **índice composto** —
> basta seguir o link exibido no console de erro.

## Requisitos atendidos (Parte 2)

- **RF001** — Login + recuperação de senha via Firebase Auth com tradução de erros.
- **RF002** — Cadastro via Firebase + 5 campos na coleção `usuarios` + validação
  robusta de senha (8+ caracteres, maiúscula, número, especial).
- **RF003** — Inserção em 4 coleções: `usuarios`, `tarefas`, `categorias`,
  `registros_atividade` (cada uma com 5+ campos) + SnackBar de confirmação.
- **RF004** — Atualização em `tarefas`, `usuarios` (perfil) e `categorias`.
- **RF005** — `StreamBuilder + ListView` (tarefas) e `StreamBuilder + GridView`
  (categorias), em tempo real e filtrados por `uid`.
- **RF006** — Tela **exclusiva** de pesquisa, busca case-insensitive (`tituloLower`)
  e ordenação por 4 critérios.
- **RF007** — API IBGE consumida com `http`, model `Estado.fromJson`, `IbgeService`,
  `FutureBuilder + GridView`, integrada no cadastro (UF) **e** em tela dedicada.

## Estrutura (Parte 2)

```
lib/
  firebase_config.dart          # flag kFirebaseEnabled
  app/auth_gate.dart            # gate: modo seguro x modo Firebase
  models/estado.dart            # model da API IBGE (RF007)
  services/                     # auth, task, category, user (Firebase) + ibge (HTTP)
  screens/ibge/                 # EstadosScreen (FutureBuilder) — funciona em modo seguro
  screens/tasks/                # SearchTasksScreen (RF006)
  screens/firebase/             # telas do modo Firebase (login, home, add/edit, etc.)
  widgets/firebase_task_card.dart
firestore.rules                 # regras de segurança por uid
```

## Tecnologias
Flutter · Dart · Firebase Auth · Cloud Firestore · API IBGE · Provider ·
Material Design 3 · Google Fonts
