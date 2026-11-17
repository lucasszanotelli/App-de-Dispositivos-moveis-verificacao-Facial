import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> load({required bool private});
  Future<void> save(List<Note> notes, {required bool private});
}

class LocalNoteRepository implements NoteRepository {
  final _preferences = SharedPreferencesAsync();
  String _key(bool private) => private ? 'private_notes_v1' : 'notes_v1';

  @override
  Future<List<Note>> load({required bool private}) async {
    final data = await _preferences.getString(_key(private));
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<Note> notes, {required bool private}) =>
      _preferences.setString(
        _key(private),
        jsonEncode(notes.map((note) => note.toJson()).toList()),
      );
}
