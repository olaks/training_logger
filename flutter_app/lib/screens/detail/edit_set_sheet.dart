import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/grades.dart';
import 'widgets/set_inputs.dart';

/// Opens the editor for an already-logged [set], using the same steppers that
/// logged it. Returns once the sheet closes.
///
/// [gradeScale] is the scale the calling screen already detected for this
/// exercise; it only matters for climbing sets.
Future<void> showEditSetSheet(
  BuildContext context,
  WorkoutSet set, {
  List<String>? gradeScale,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => EditSetSheet(set: set, gradeScale: gradeScale),
  );
}

class EditSetSheet extends ConsumerStatefulWidget {
  final WorkoutSet set;
  final List<String>? gradeScale;
  const EditSetSheet({super.key, required this.set, this.gradeScale});

  @override
  ConsumerState<EditSetSheet> createState() => _EditSetSheetState();
}

class _EditSetSheetState extends ConsumerState<EditSetSheet> {
  late double _weightKg;
  late int _reps;
  late int _timeSecs;
  late int _rpe;
  late int _wallAngle;
  late String _climbName;

  /// Held as a string so the set keeps its grade even if the detected scale
  /// changes underneath the sheet.
  String? _grade;

  bool get _isClimbing => widget.set.grade != null;

  @override
  void initState() {
    super.initState();
    final s = widget.set;
    _weightKg  = s.weightKg ?? 0;
    _reps      = s.reps ?? 0;
    _timeSecs  = s.timeSecs ?? 0;
    _rpe       = s.rpe ?? 0;
    _wallAngle = s.wallAngle ?? 0;
    _climbName = s.climbName ?? '';
    _grade     = s.grade;
  }

  /// Falls back to the scale implied by the set's own grade, so the sheet
  /// still works if a caller has none to hand.
  List<String> _scale() =>
      widget.gradeScale ??
      detectGradeScale([if (widget.set.grade != null) widget.set.grade!]);

  /// True once the set says something — an empty set can't be saved, since
  /// there would be nothing left to show in the history.
  bool get _isValid => _isClimbing
      ? _grade != null
      : _weightKg != 0 || _reps > 0 || _timeSecs > 0;

  Future<void> _save() async {
    final name = _climbName.trim();
    await ref.editSet(
      widget.set.id,
      weightKg:  _isClimbing || _weightKg == 0 ? null : _weightKg,
      reps:      _isClimbing || _reps == 0 ? null : _reps,
      timeSecs:  _isClimbing || _timeSecs == 0 ? null : _timeSecs,
      rpe:       _rpe == 0 ? null : _rpe,
      grade:     _grade,
      wallAngle: _isClimbing && _wallAngle > 0 ? _wallAngle : null,
      climbName: _isClimbing && name.isNotEmpty ? name : null,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final grades  = _isClimbing ? _scale() : const <String>[];
    final loggedOn =
        DateFormat('EEE, MMM d').format(dateFromStr(widget.set.dateStr));

    return Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          // Keep the fields above the keyboard while typing.
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('EDIT SET',
                    style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: primary,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(loggedOn,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
            const SizedBox(height: 20),
            if (_isClimbing)
              ..._climbingFields(grades, primary)
            else
              ..._standardFields(),
            const Divider(height: 32),
            RpeRow(
              rpe: _rpe,
              label: rpeLabel(_rpe),
              onDecrement: () => setState(() => _rpe = (_rpe - 1).clamp(0, 10)),
              onIncrement: () => setState(() => _rpe = (_rpe + 1).clamp(0, 10)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isValid ? _save : null,
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _standardFields() => [
        StepperRow(
          label:        'WEIGHT (KG)',
          value:        _weightKg == 0 ? '—' : formatWeight(_weightKg),
          editValue:    _weightKg == 0 ? '' : formatWeight(_weightKg),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onDecrement:  () => setState(
              () => _weightKg = (_weightKg - 1).clamp(-500, 999).toDouble()),
          onIncrement:  () => setState(
              () => _weightKg = (_weightKg + 1).clamp(-500, 999).toDouble()),
          onTyped: (t) => setState(() =>
              _weightKg = (double.tryParse(t.replaceAll(',', '.')) ?? 0)
                  .clamp(-500.0, 999.0)),
        ),
        const Divider(height: 32),
        StepperRow(
          label:        'REPS',
          value:        _reps == 0 ? '—' : '$_reps',
          editValue:    _reps == 0 ? '' : '$_reps',
          keyboardType: TextInputType.number,
          onDecrement:  () => setState(() => _reps = (_reps - 1).clamp(0, 999)),
          onIncrement:  () => setState(() => _reps = (_reps + 1).clamp(0, 999)),
          onTyped: (t) =>
              setState(() => _reps = (int.tryParse(t) ?? 0).clamp(0, 999)),
        ),
        const Divider(height: 32),
        StepperRow(
          label:        'TIME',
          value:        _timeSecs == 0 ? '—' : formatTime(_timeSecs),
          editValue:    _timeSecs == 0 ? '' : '$_timeSecs',
          keyboardType: TextInputType.number,
          onDecrement:  () =>
              setState(() => _timeSecs = (_timeSecs - 5).clamp(0, 36000)),
          onIncrement:  () =>
              setState(() => _timeSecs = (_timeSecs + 5).clamp(0, 36000)),
          onTyped: (t) => setState(
              () => _timeSecs = (int.tryParse(t) ?? 0).clamp(0, 36000)),
        ),
      ];

  List<Widget> _climbingFields(List<String> grades, Color primary) {
    final index = _grade == null ? -1 : gradeToIndex(_grade!, grades);
    return [
      Text('GRADE',
          style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: primary,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Row(
        children: [
          StepBtn(
            label: '−',
            onTap: () => setState(() {
              final next = (index - 1).clamp(0, grades.length - 1);
              _grade = grades[next];
            }),
          ),
          Expanded(
            child: Text(
              _grade ?? '—',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
          StepBtn(
            label: '+',
            onTap: () => setState(() {
              final next = (index + 1).clamp(0, grades.length - 1);
              _grade = grades[next];
            }),
          ),
        ],
      ),
      const Divider(height: 32),
      StepperRow(
        label:        'WALL ANGLE (°)',
        value:        _wallAngle == 0 ? '—' : '$_wallAngle°',
        editValue:    _wallAngle == 0 ? '' : '$_wallAngle',
        keyboardType: TextInputType.number,
        onDecrement:  () =>
            setState(() => _wallAngle = (_wallAngle - 5).clamp(0, 90)),
        onIncrement:  () =>
            setState(() => _wallAngle = (_wallAngle + 5).clamp(0, 90)),
        onTyped: (t) =>
            setState(() => _wallAngle = (int.tryParse(t) ?? 0).clamp(0, 90)),
      ),
      const Divider(height: 32),
      ClimbNameField(
        value: _climbName,
        onChanged: (v) => _climbName = v,
      ),
    ];
  }
}
