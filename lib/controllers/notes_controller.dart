import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/biometric_service.dart';
import '../services/note_repository.dart';

class NotesController extends ChangeNotifier {
  NotesController({required this.repository, required this.biometrics});
  final NoteRepository repository;
  final BiometricService biometrics;
  List<Note> _publicNotes = [];
  List<Note> _privateNotes = [];
  bool unlocked = false;
  bool authenticating = false;
  bool loading = true;
  bool saving = false;
  String? error;
  int _session = 0;

  List<Note> notes({required bool private}) {
    final result = List<Note>.of(private ? _privateNotes : _publicNotes);
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(result);
  }

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _publicNotes = await repository.load(private: false);
    } catch (_) {
      error = 'Não foi possível carregar as notas. Tente novamente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> unlock() async {
    if (authenticating) return false;
    final session = ++_session;
    authenticating = true;
    error = null;
    notifyListeners();
    try {
      final success = await biometrics.authenticate();
      if (session != _session) return false;
      if (!success) {
        error = 'Autenticação cancelada ou não reconhecida.';
        return false;
      }
      final notes = await repository.load(private: true);
      if (session != _session) return false;
      _privateNotes = notes;
      unlocked = true;
      return true;
    } on AuthenticationFailure catch (failure) {
      if (session == _session) error = failure.message;
      return false;
    } catch (_) {
      if (session == _session) {
        error = 'Não foi possível abrir as notas privadas. Tente novamente.';
      }
      return false;
    } finally {
      authenticating = false;
      notifyListeners();
    }
  }

  void lock() {
    _session++;
    unlocked = false;
    _privateNotes = [];
    error = null;
    notifyListeners();
  }

  Future<bool> put(Note note, {required bool private}) => _change([
    ...notes(private: private).where((item) => item.id != note.id),
    note,
  ], private: private);

  Future<bool> delete(Note note, {required bool private}) => _change(
    notes(private: private).where((item) => item.id != note.id).toList(),
    private: private,
  );

  Future<bool> _change(List<Note> next, {required bool private}) async {
    if (saving || loading || (private && !unlocked)) return false;
    final session = _session;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await repository.save(next, private: private);
      if (private) {
        if (session != _session || !unlocked) return false;
        _privateNotes = next;
      } else {
        _publicNotes = next;
      }
      return true;
    } catch (_) {
      if (!private || session == _session) {
        error =
            'Não foi possível salvar. Suas alterações não foram confirmadas.';
      }
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
