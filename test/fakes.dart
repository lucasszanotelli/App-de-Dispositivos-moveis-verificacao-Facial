import 'dart:async';

import 'package:notas_biometricas/models/note.dart';
import 'package:notas_biometricas/services/biometric_service.dart';
import 'package:notas_biometricas/services/note_repository.dart';

class MemoryRepository implements NoteRepository {
  final data = <bool, List<Note>>{false: [], true: []};
  int privateReads = 0;
  bool failSave = false;
  Completer<List<Note>>? pendingRead;

  @override
  Future<List<Note>> load({required bool private}) async {
    if (private) {
      privateReads++;
      if (pendingRead != null) return pendingRead!.future;
    }
    return List.of(data[private]!);
  }

  @override
  Future<void> save(List<Note> notes, {required bool private}) async {
    if (failSave) throw Exception('Storage failure');
    data[private] = List.of(notes);
  }
}

class FakeBiometrics implements BiometricService {
  bool success = true;
  int calls = 0;
  Completer<bool>? pending;
  AuthenticationFailure? failure;

  @override
  Future<bool> authenticate() async {
    calls++;
    if (failure != null) throw failure!;
    return pending == null ? success : pending!.future;
  }
}

Note sample(String id) => Note(
  id: id,
  title: id,
  content: 'Conteúdo de $id',
  updatedAt: DateTime(2026, 11, 17),
);
