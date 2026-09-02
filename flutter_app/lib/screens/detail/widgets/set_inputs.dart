import 'package:flutter/material.dart';

// Shared number/text inputs for logging a set. Used by the Track tab and by
// the edit-set sheet, so a set is corrected with the same controls that
// entered it.

// ── Stepper row with tap-to-type ──────────────────────────────────────────────

class StepperRow extends StatefulWidget {
  final String label;
  final String value;
  final String editValue;
  final TextInputType keyboardType;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final void Function(String) onTyped;

  const StepperRow({
    super.key,
    required this.label,
    required this.value,
    required this.editValue,
    required this.keyboardType,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTyped,
  });

  @override
  State<StepperRow> createState() => StepperRowState();
}

class StepperRowState extends State<StepperRow> {
  bool _editing = false;
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController();
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _startEdit() {
    _ctrl.text = widget.editValue;
    _ctrl.selection =
        TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _commit() {
    if (!_editing) return;
    setState(() => _editing = false);
    widget.onTyped(_ctrl.text);
  }

  void _stepAndCommit(VoidCallback step) {
    if (_editing) _commit();
    step();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              StepBtn(
                  label: '−',
                  onTap: () => _stepAndCommit(widget.onDecrement)),
              Expanded(
                child: _editing
                    ? TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        keyboardType: widget.keyboardType,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _commit(),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _startEdit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(widget.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
              ),
              StepBtn(
                  label: '+',
                  onTap: () => _stepAndCommit(widget.onIncrement)),
            ],
          ),
        ],
      );
}

// ── Step button ───────────────────────────────────────────────────────────────

class StepBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const StepBtn({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 52,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w300)),
            ),
          ),
        ),
      );
}

// ── RPE row ───────────────────────────────────────────────────────────────────

/// Words for an RPE value, so the number has a meaning attached to it.
String rpeLabel(int rpe) => switch (rpe) {
      0           => '—',
      1 || 2 || 3 => 'Easy',
      4 || 5      => 'Moderate',
      6 || 7      => 'Hard',
      8 || 9      => 'Very Hard',
      _           => 'Max',
    };

class RpeRow extends StatelessWidget {
  final int rpe;
  final String label;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const RpeRow({
    super.key,
    required this.rpe,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RPE (EFFORT)',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              StepBtn(label: '−', onTap: onDecrement),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      rpe == 0 ? '—' : '$rpe',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      rpe == 0 ? 'not set' : label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              StepBtn(label: '+', onTap: onIncrement),
            ],
          ),
        ],
      );
}


// ── Climb name text field ────────────────────────────────────────────────────

class ClimbNameField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const ClimbNameField({super.key, required this.value, required this.onChanged});

  @override
  State<ClimbNameField> createState() => ClimbNameFieldState();
}

class ClimbNameFieldState extends State<ClimbNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ClimbNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _ctrl.text) {
      _ctrl.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CLIMB NAME',
            style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: primary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'optional',
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
