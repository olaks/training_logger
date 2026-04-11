import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(allPlansProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: plans.isEmpty
          ? Center(
              child: Text(
                'No plans yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              ),
            )
          : ListView.builder(
              itemCount: plans.length,
              itemBuilder: (_, i) {
                final plan = plans[i];
                return ListTile(
                  title: Text(plan.name),
                  trailing: PopupMenuButton<_PlanAction>(
                    icon: Icon(Icons.more_vert,
                        color: Colors.white.withValues(alpha: 0.35), size: 20),
                    onSelected: (action) {
                      if (action == _PlanAction.rename) {
                        _showRenameDialog(context, ref, plan.id, plan.name);
                      } else {
                        _showDeleteDialog(context, ref, plan.id, plan.name);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: _PlanAction.rename, child: Text('Rename')),
                      PopupMenuItem(value: _PlanAction.delete, child: Text('Delete')),
                    ],
                  ),
                  onTap: () => context.push('/plans/${plan.id}'),
                );
              },
            ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Plan'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Plan name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _create(context, ref, ctrl.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
              onPressed: () => _create(context, ref, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
  }

  void _create(BuildContext context, WidgetRef ref, String name) {
    if (name.trim().isEmpty) return;
    ref.insertPlan(name.trim());
    Navigator.pop(context);
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, int id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Plan'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Plan name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _rename(context, ref, id, ctrl.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
              onPressed: () => _rename(context, ref, id, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _rename(BuildContext context, WidgetRef ref, int id, String name) {
    if (name.trim().isEmpty) return;
    ref.renamePlan(id, name.trim());
    Navigator.pop(context);
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text('All exercises and schedules in this plan will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.deletePlan(id);
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

enum _PlanAction { rename, delete }
