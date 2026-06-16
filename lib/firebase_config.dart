// lib/firebase_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// Controla se o Firebase está ativo nesta build.
//
// MODO SEGURO (kFirebaseEnabled = false):
//   O app roda 100% com os dados mockados da Parte 1 (Provider em memória).
//   Nenhum código que toca o Firebase é executado, então o app compila e
//   funciona mesmo sem o `firebase_options.dart` (gerado pelo flutterfire).
//
// PARA HABILITAR O FIREBASE:
//   1. flutter pub global activate flutterfire_cli
//   2. flutterfire configure --project=taskflow-ac622
//      (isso gera lib/firebase_options.dart)
//   3. Em lib/main.dart: descomente o import de firebase_options e a chamada
//      a Firebase.initializeApp(...)
//   4. Mude a constante abaixo para true.
//   5. git add . && git commit -m "feat: habilita Firebase" && git push
// ─────────────────────────────────────────────────────────────────────────────

const bool kFirebaseEnabled = false;
