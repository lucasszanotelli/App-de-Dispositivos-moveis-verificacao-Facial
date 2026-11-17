import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:notas_biometricas/controllers/notes_controller.dart';
import 'package:notas_biometricas/models/note.dart';
import 'package:notas_biometricas/services/biometric_service.dart';

import 'fakes.dart';

void main() {
  late MemoryRepository repository;
  late FakeBiometrics biometrics;
  late NotesController controller;
  setUp(() {
    repository = MemoryRepository();
    biometrics = FakeBiometrics();
    controller = NotesController(
      repository: repository,
      biometrics: biometrics,
    );
  });

  test('private notes are read only after successful authentication', () async {
    repository.data[true] = [sample('Segredo')];
    await controller.initialize();
    expect(repository.privateReads, 0);
    biometrics.success = false;
    expect(await controller.unlock(), false);
    expect(repository.privateReads, 0);
    expect(controller.notes(private: true), isEmpty);
    biometrics.success = true;
    expect(await controller.unlock(), true);
    expect(controller.notes(private: true).single.title, 'Segredo');
    controller.lock();
    expect(controller.unlocked, false);
    expect(controller.notes(private: true), isEmpty);
    expect(await controller.put(sample('Blocked'), private: true), false);
  });

  test('late authentication cannot reopen a locked session', () async {
    biometrics.pending = Completer<bool>();
    final result = controller.unlock();
    expect(await controller.unlock(), false);
    expect(biometrics.calls, 1);
    controller.lock();
    biometrics.pending!.complete(true);
    expect(await result, false);
    expect(repository.privateReads, 0);
    expect(controller.unlocked, false);
  });

  test('late private load is discarded after background lock', () async {
    repository.pendingRead = Completer<List<Note>>();
    final result = controller.unlock();
    await Future<void>.delayed(Duration.zero);
    controller.lock();
    repository.pendingRead!.complete([sample('Segredo')]);
    expect(await result, false);
    expect(controller.notes(private: true), isEmpty);
  });

  test(
    'unavailable biometrics leaves area locked with helpful error',
    () async {
      biometrics.failure = const AuthenticationFailure(
        'Cadastre uma biometria.',
      );
      expect(await controller.unlock(), false);
      expect(controller.error, 'Cadastre uma biometria.');
      expect(controller.unlocked, false);
    },
  );

  test(
    'CRUD persists separately, and a new controller reloads notes',
    () async {
      await controller.initialize();
      await controller.put(sample('Pública'), private: false);
      await controller.unlock();
      await controller.put(sample('Privada'), private: true);
      final second = NotesController(
        repository: repository,
        biometrics: biometrics,
      );
      await second.initialize();
      expect(second.notes(private: false).single.title, 'Pública');
      expect(second.notes(private: true), isEmpty);
      await second.unlock();
      final note = second.notes(private: true).single;
      await second.put(
        Note(
          id: note.id,
          title: 'Editada',
          content: note.content,
          updatedAt: DateTime.now(),
        ),
        private: true,
      );
      expect(repository.data[true]!.single.title, 'Editada');
      await second.delete(note, private: true);
      expect(repository.data[true], isEmpty);
      expect(repository.data[false]!.single.title, 'Pública');
    },
  );

  test('failed write preserves original notes', () async {
    await controller.initialize();
    await controller.put(sample('Original'), private: false);
    repository.failSave = true;
    expect(await controller.delete(sample('Original'), private: false), false);
    expect(controller.notes(private: false).single.title, 'Original');
    expect(controller.error, isNotNull);
    expect(controller.saving, false);
  });
}
