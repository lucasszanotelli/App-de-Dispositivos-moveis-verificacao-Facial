import 'package:flutter/material.dart';

import '../controllers/notes_controller.dart';
import '../models/note.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({
    super.key,
    required this.controller,
    required this.private,
    this.note,
  });
  final NotesController controller;
  final bool private;
  final Note? note;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final _title = TextEditingController(text: widget.note?.title);
  late final _content = TextEditingController(text: widget.note?.content);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty && _content.text.trim().isEmpty) {
      setState(() => _error = 'Escreva um título ou conteúdo para salvar.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final now = DateTime.now();
    final success = await widget.controller.put(
      Note(
        id: widget.note?.id ?? now.microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        content: _content.text.trim(),
        updatedAt: now,
      ),
      private: widget.private,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _error =
            widget.controller.error ?? 'Área bloqueada. Abra a nota novamente.';
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir nota?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    final success = await widget.controller.delete(
      widget.note!,
      private: widget.private,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _error = widget.controller.error ?? 'Não foi possível excluir.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.note == null ? 'Nova nota' : 'Editar nota'),
      actions: [
        if (widget.note != null)
          IconButton(
            tooltip: 'Excluir nota',
            onPressed: _busy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.private)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Nota privada • alterações não salvas serão descartadas ao bloquear.',
                ),
              ),
            TextField(
              controller: _title,
              enabled: !_busy,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _content,
                enabled: !_busy,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_busy ? 'Salvando…' : 'Salvar'),
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );
}
