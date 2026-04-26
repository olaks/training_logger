import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/youtube.dart';

class InspirationScreen extends ConsumerStatefulWidget {
  const InspirationScreen({super.key});

  @override
  ConsumerState<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends ConsumerState<InspirationScreen> {
  int? _filterCategoryId; // null = show all

  @override
  Widget build(BuildContext context) {
    final inspirations =
        ref.watch(inspirationsProvider(_filterCategoryId)).value ?? [];
    final categories = ref.watch(categoriesProvider).value ?? [];
    final byId = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspiration',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditSheet(context, categories, null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: _ExerciseFilter(
              categories: categories,
              selectedId: _filterCategoryId,
              onChanged: (id) => setState(() => _filterCategoryId = id),
            ),
          ),
          Expanded(
            child: inspirations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _filterCategoryId == null
                            ? 'No inspirations yet.\nTap + to add a YouTube link.'
                            : 'No inspirations for this exercise.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35)),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                    itemCount: inspirations.length,
                    itemBuilder: (_, i) => _InspirationCard(
                      inspiration: inspirations[i],
                      linkedExerciseName:
                          byId[inspirations[i].categoryId]?.name,
                      onTap: () => _open(inspirations[i].url),
                      onEdit: () => _showEditSheet(
                          context, categories, inspirations[i]),
                      onDelete: () =>
                          _confirmDelete(context, inspirations[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _confirmDelete(BuildContext context, Inspiration item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.removeInspiration(item.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, List<ExerciseCategory> categories,
      Inspiration? existing) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _InspirationForm(
          categories: categories,
          existing: existing,
          defaultCategoryId: _filterCategoryId,
        ),
      ),
    );
  }
}

// ── Filter chip row ──────────────────────────────────────────────────────────

class _ExerciseFilter extends StatelessWidget {
  final List<ExerciseCategory> categories;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  const _ExerciseFilter({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedName = selectedId == null
        ? null
        : categories.firstWhere((c) => c.id == selectedId,
            orElse: () => ExerciseCategory(
                id: selectedId!, name: '?', exerciseType: 0)).name;
    return Row(
      children: [
        const Icon(Icons.filter_list, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            selectedName == null
                ? 'All inspirations'
                : 'Filter: $selectedName',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showModalBottomSheet<int?>(
              context: context,
              useRootNavigator: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              builder: (_) => _CategoryPickerSheet(
                categories: categories,
                selectedId: selectedId,
                allowClear: true,
              ),
            );
            // Distinguish "user picked clear" from "dismissed without picking".
            // Sheet returns -1 for clear, an int id for a selection, null for dismiss.
            if (picked == null) return;
            onChanged(picked == -1 ? null : picked);
          },
          child: Text(selectedId == null ? 'Filter' : 'Change'),
        ),
      ],
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final List<ExerciseCategory> categories;
  final int? selectedId;
  final bool allowClear;
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedId,
    this.allowClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...categories]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (allowClear)
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Show all'),
              onTap: () => Navigator.pop(context, -1),
            ),
          ...sorted.map((c) => ListTile(
                title: Text(c.name),
                subtitle: c.groupName != null
                    ? Text(c.groupName!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4)))
                    : null,
                trailing: c.id == selectedId
                    ? const Icon(Icons.check, color: Colors.amber)
                    : null,
                onTap: () => Navigator.pop(context, c.id),
              )),
        ],
      ),
    );
  }
}

// ── Single inspiration card ──────────────────────────────────────────────────

class _InspirationCard extends StatelessWidget {
  final Inspiration inspiration;
  final String? linkedExerciseName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InspirationCard({
    required this.inspiration,
    required this.linkedExerciseName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = youtubeThumbnail(inspiration.url);
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 120,
                  height: 68,
                  child: thumb != null
                      ? Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _Placeholder(),
                        )
                      : _Placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspiration.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (inspiration.notes != null &&
                        inspiration.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        inspiration.notes!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.55)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (linkedExerciseName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.link, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              linkedExerciseName!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: primary,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_RowAction>(
                icon: Icon(Icons.more_vert,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.4)),
                onSelected: (a) =>
                    a == _RowAction.edit ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _RowAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                      value: _RowAction.delete, child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.play_circle_outline,
            color: Colors.white.withValues(alpha: 0.3), size: 28),
      );
}

enum _RowAction { edit, delete }

// ── Add / edit form ──────────────────────────────────────────────────────────

class _InspirationForm extends ConsumerStatefulWidget {
  final List<ExerciseCategory> categories;
  final Inspiration? existing;
  final int? defaultCategoryId;

  const _InspirationForm({
    required this.categories,
    required this.existing,
    required this.defaultCategoryId,
  });

  @override
  ConsumerState<_InspirationForm> createState() => _InspirationFormState();
}

class _InspirationFormState extends ConsumerState<_InspirationForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _notesCtrl;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _urlCtrl = TextEditingController(text: widget.existing?.url ?? '');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
    _categoryId =
        widget.existing?.categoryId ?? widget.defaultCategoryId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) return;
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    if (widget.existing != null) {
      await ref.editInspiration(
        widget.existing!.id,
        title: title,
        url: url,
        notes: notes,
        categoryId: _categoryId,
      );
    } else {
      await ref.addInspiration(
        title: title,
        url: url,
        notes: notes,
        categoryId: _categoryId,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCat = _categoryId == null
        ? null
        : widget.categories.firstWhere(
            (c) => c.id == _categoryId,
            orElse: () => ExerciseCategory(
                id: _categoryId!, name: '?', exerciseType: 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'New inspiration' : 'Edit inspiration',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'YouTube URL',
              hintText: 'https://www.youtube.com/watch?v=…',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.fitness_center,
                  size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedCat == null
                      ? 'Not linked to an exercise'
                      : 'Linked: ${selectedCat.name}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (selectedCat != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.white54,
                  onPressed: () => setState(() => _categoryId = null),
                ),
              TextButton(
                onPressed: () async {
                  final picked = await showModalBottomSheet<int?>(
                    context: context,
                    useRootNavigator: false,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16))),
                    builder: (_) => _CategoryPickerSheet(
                      categories: widget.categories,
                      selectedId: _categoryId,
                    ),
                  );
                  if (picked != null) {
                    setState(() => _categoryId = picked);
                  }
                },
                child: Text(selectedCat == null ? 'Link' : 'Change'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                      widget.existing == null ? 'Add' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
