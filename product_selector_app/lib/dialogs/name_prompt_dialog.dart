import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NamePromptDialog extends StatefulWidget {
  const NamePromptDialog({super.key});

  @override
  State<NamePromptDialog> createState() => _NamePromptDialogState();
}

class _NamePromptDialogState extends State<NamePromptDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();

  late final AnimationController _buttonController;
  late final Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buttonScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  bool get isValidName => controller.text.trim().isNotEmpty;

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _onTextChanged(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), ' ');
    final capitalized = capitalize(cleaned);

    if (controller.text != capitalized) {
      controller.value = controller.value.copyWith(
        text: capitalized,
        selection: TextSelection.collapsed(offset: capitalized.length),
      );
    }

    if (isValidName) {
      _buttonController.forward();
    } else {
      _buttonController.reverse();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String name = controller.text.trim();

    return AlertDialog(
      title: const Text(
        'Welcome 👋',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🧑 Avatar preview
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // ✏️ Name input
          TextField(
            controller: controller,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            decoration: const InputDecoration(hintText: 'Enter your name'),
            onChanged: _onTextChanged,
          ),
        ],
      ),
      actions: [
        ScaleTransition(
          scale: _buttonScale,
          child: ElevatedButton(
            onPressed: isValidName
                ? () {
                    Navigator.pop(context, name);
                  }
                : null,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
