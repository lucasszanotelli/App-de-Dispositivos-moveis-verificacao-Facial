import 'package:flutter/material.dart';

import '../controllers/notes_controller.dart';
import '../models/note.dart';
import 'note_editor.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({
    super.key,
    required this.controller,
    this.private = false,
  });
  final NotesController controller;
  final bool private;

  Future<void> _openPrivate(BuildContext context) async {
    if (await controller.unlock() && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NotesScreen(controller: controller, private: true),
        ),
      );
      controller.lock();
    }
  }

  void _edit(BuildContext context, [Note? note]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NoteEditor(controller: controller, private: private, note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    onPopInvokedWithResult: (didPop, result) {
      if (didPop && private) controller.lock();
    },
    child: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final notes = controller.notes(private: private);
        final accessible = !private || controller.unlocked;
        return Scaffold(
          appBar: AppBar(
            title: Text(private ? 'Notas privadas' : 'Minhas notas'),
            actions: [
              if (private)
                IconButton(
                  tooltip: 'Bloquear notas',
                  icon: const Icon(Icons.lock_outline),
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
          floatingActionButton:
              accessible && !controller.loading && controller.error == null
              ? FloatingActionButton.extended(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova nota'),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                if (!private)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card.filled(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.fingerprint, size: 36),
                        title: const Text('Notas privadas'),
                        subtitle: const Text('Acesse com Face ID ou Touch ID'),
                        trailing: controller.authenticating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: controller.authenticating || controller.loading
                            ? null
                            : () => _openPrivate(context),
                      ),
                    ),
                  ),
                if (private && accessible)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Icon(Icons.lock_open, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Área desbloqueada. Ao sair, a biometria será solicitada novamente.',
                          ),
                        ),
                      ],
                    ),
                  ),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(controller.error!),
                            if (!private)
                              TextButton(
                                onPressed: controller.loading
                                    ? null
                                    : controller.initialize,
                                child: const Text('Recarregar notas'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : !accessible
                      ? const Center(child: Text('Área bloqueada.'))
                      : notes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  private
                                      ? Icons.lock_outline
                                      : Icons.note_alt_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  private
                                      ? 'Suas notas privadas ficam aqui'
                                      : 'Suas ideias começam aqui',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Toque em “Nova nota” para começar.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            final date = MaterialLocalizations.of(context)
                                .formatCompactDate(note.updatedAt.toLocal());
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  note.displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${note.content.isEmpty ? "Sem conteúdo" : note.content}\n$date',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _edit(context, note),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
