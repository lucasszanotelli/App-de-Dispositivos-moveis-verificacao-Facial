import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/notes_controller.dart';
import 'screens/notes_screen.dart';
import 'services/biometric_service.dart';
import 'services/note_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    NotesApp(
      controller: NotesController(
        repository: LocalNoteRepository(),
        biometrics: LocalBiometricService(),
      ),
    ),
  );
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key, required this.controller});
  final NotesController controller;

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Face ID can make the app inactive. Hide content, but only revoke
    // authentication when the app actually leaves the foreground.
    setState(() => _obscured = state != AppLifecycleState.resumed);
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.controller.lock();
      _navigator.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigator,
    title: 'Notas biométricas',
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF41644A)),
      scaffoldBackgroundColor: const Color(0xFFF8FAF7),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF8FAF7)),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    builder: (context, child) => Stack(
      children: [
        child!,
        if (_obscured)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0xFFF8FAF7),
              child: Center(child: Icon(Icons.lock_outline, size: 48)),
            ),
          ),
      ],
    ),
    home: NotesScreen(controller: widget.controller),
  );
}
