import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/youtube.dart';
import '../inspiration/inspiration_screen.dart';

class EditExerciseScreen extends ConsumerStatefulWidget {
  final int categoryId;
  const EditExerciseScreen({super.key, required this.categoryId});

  @override
  ConsumerState<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends ConsumerState<EditExerciseScreen> {
  final _nameCtrl  = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  bool _hydrated = false;
  String? _initialName;
  String? _initialGroup;
  String? _initialDesc;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _hydrate(ExerciseCategory cat) {
    if (_hydrated) return;
    _hydrated = true;
    _nameCtrl.text  = cat.name;
    _groupCtrl.text = cat.groupName ?? '';
    _descCtrl.text  = cat.description ?? '';
    _initialName    = cat.name;
    _initialGroup   = cat.groupName ?? '';
    _initialDesc    = cat.description ?? '';
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    final allCats = ref.read(categoriesProvider).value ?? [];
    final clash = allCats.any((c) =>
        c.id != widget.categoryId &&
        c.name.toLowerCase() == name.toLowerCase());
    if (clash) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" already exists')));
      return;
    }

    final group = _groupCtrl.text.trim();
    final desc  = _descCtrl.text.trim();

    if (name != _initialName) {
      await ref.renameCategory(widget.categoryId, name);
    }
    final newGroup = group.isEmpty ? null : group;
    if (newGroup != (_initialGroup?.isEmpty == true ? null : _initialGroup)) {
      await ref.updateCategoryGroup(widget.categoryId, newGroup);
    }
    final newDesc = desc.isEmpty ? null : desc;
    if (newDesc != (_initialDesc?.isEmpty == true ? null : _initialDesc)) {
      await ref.updateCategoryDescription(widget.categoryId, newDesc);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final catAsync   = ref.watch(categoryByIdProvider(widget.categoryId));
    final allCats    = ref.watch(categoriesProvider).value ?? [];
    final groups     = allCats
        .map((c) => c.groupName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final cat        = catAsync.value;

    if (cat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit exercise')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    _hydrate(cat);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit exercise',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Center(
            child: _ImagePicker(
              data: cat.imageData,
              onPicked: (bytes) =>
                  ref.saveCategoryImage(widget.categoryId, bytes),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _groupCtrl.text),
            optionsBuilder: (v) => v.text.isEmpty
                ? groups
                : groups.where((g) =>
                    g.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (g) {
              _groupCtrl.text = g;
              setState(() {});
            },
            fieldViewBuilder: (_, ctrl, focus, __) {
              // Keep the autocomplete's controller in sync with ours.
              ctrl.text = _groupCtrl.text;
              return TextField(
                controller: ctrl,
                focusNode: focus,
                decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. Fingers, Back… (leave empty to clear)'),
                textCapitalization: TextCapitalization.words,
                onChanged: (v) {
                  _groupCtrl.text = v;
                  setState(() {});
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Cues, setup, notes…'),
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),
          _VideosSection(categoryId: widget.categoryId, categories: allCats),
        ],
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final Uint8List? data;
  final void Function(Uint8List?) onPicked;
  const _ImagePicker({required this.data, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 96,
            height: 96,
            child: data != null
                ? Image.memory(data!, fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.fitness_center,
                        size: 36,
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pick(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Gallery'),
            ),
            TextButton.icon(
              onPressed: () => _pick(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Camera'),
            ),
            if (data != null)
              TextButton.icon(
                onPressed: () => onPicked(null),
                icon: Icon(Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.error),
                label: Text('Remove',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final xFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    onPicked(bytes);
  }
}

class _VideosSection extends ConsumerWidget {
  final int categoryId;
  final List<ExerciseCategory> categories;
  const _VideosSection({required this.categoryId, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(inspirationsProvider(categoryId)).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Videos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showInspirationFormSheet(
                context,
                categories: categories,
                defaultCategoryId: categoryId,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add video'),
            ),
          ],
        ),
        if (videos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No videos linked.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
            ),
          )
        else
          ...videos.map((v) => _VideoRow(
                inspiration: v,
                categories: categories,
                onTap: () => _open(context, v.url),
                onDelete: () => _confirmDelete(context, ref, v),
              )),
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Inspiration item) {
    showDialog(
      context: context,
      useRootNavigator: false,
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
}

class _VideoRow extends StatelessWidget {
  final Inspiration inspiration;
  final List<ExerciseCategory> categories;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VideoRow({
    required this.inspiration,
    required this.categories,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = youtubeThumbnail(inspiration.url);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 72,
                height: 44,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    inspiration.title,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    inspiration.url,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => showInspirationFormSheet(
                context,
                categories: categories,
                existing: inspiration,
                defaultCategoryId: inspiration.categoryId,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.error),
              onPressed: onDelete,
            ),
          ],
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
            color: Colors.white.withValues(alpha: 0.3), size: 22),
      );
}
