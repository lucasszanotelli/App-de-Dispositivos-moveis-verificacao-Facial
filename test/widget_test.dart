import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notas_biometricas/controllers/notes_controller.dart';
import 'package:notas_biometricas/main.dart';

import 'fakes.dart';

void main() {
  testWidgets('create, edit and delete a public note through the UI', (
    tester,
  ) async {
    final controller = NotesController(
      repository: MemoryRepository(),
      biometrics: FakeBiometrics(),
    );
    await tester.pumpWidget(NotesApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Escreva um título ou conteúdo para salvar.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).first, 'Seminário');
    await tester.enterText(find.byType(TextField).last, 'Biometria em Flutter');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Seminário'), findsOneWidget);
    await tester.tap(find.text('Seminário'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Apresentação');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apresentação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Excluir nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Suas ideias começam aqui'), findsOneWidget);
  });

  testWidgets('private navigation locks and background discards draft', (
    tester,
  ) async {
    final repository = MemoryRepository();
    repository.data[true] = [sample('Segredo')];
    final biometrics = FakeBiometrics();
    final controller = NotesController(
      repository: repository,
      biometrics: biometrics,
    );
    await tester.pumpWidget(NotesApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Segredo'), findsNothing);
    await tester.tap(find.text('Notas privadas'));
    await tester.pumpAndSettle();
    expect(find.text('Segredo'), findsOneWidget);
    await tester.tap(find.byTooltip('Bloquear notas'));
    await tester.pumpAndSettle();
    expect(controller.unlocked, false);
    await tester.tap(find.text('Notas privadas'));
    await tester.pumpAndSettle();
    expect(biometrics.calls, 2);
    await tester.tap(find.text('Segredo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Rascunho não salvo');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(controller.unlocked, true);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(controller.unlocked, false);
    expect(find.text('Minhas notas'), findsOneWidget);
    expect(find.text('Rascunho não salvo'), findsNothing);
    expect(repository.data[true]!.single.content, 'Conteúdo de Segredo');
  });
}
