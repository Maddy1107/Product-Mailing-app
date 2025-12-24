import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum MailType { received, required }

class MailPreviewDialog extends StatefulWidget {
  final List<String> selectedProducts;
  final String userName;

  const MailPreviewDialog({
    super.key,
    required this.selectedProducts,
    required this.userName,
  });

  @override
  State<MailPreviewDialog> createState() => _MailPreviewDialogState();
}

class _MailPreviewDialogState extends State<MailPreviewDialog> {
  MailType selectedType = MailType.received;

  Color modeColor(BuildContext context) {
    return selectedType == MailType.received ? Colors.green : Colors.orange;
  }

  String buildEmailBody() {
    final buffer = StringBuffer();

    buffer.writeln('Dear team,\n');
    buffer.writeln(
      'Below are the products '
      '${selectedType == MailType.received ? 'received' : 'required'}:\n',
    );

    for (int i = 0; i < widget.selectedProducts.length; i++) {
      buffer.writeln('${i + 1}. ${widget.selectedProducts[i]}');
    }

    buffer.writeln('\nThank you');
    buffer.writeln(widget.userName);

    return buffer.toString();
  }

  Future<void> sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {'subject': 'Product update', 'body': buildEmailBody()},
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Mail preview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SegmentedButton<MailType>(
              segments: const [
                ButtonSegment(
                  value: MailType.received,
                  label: Text('Received'),
                ),
                ButtonSegment(
                  value: MailType.required,
                  label: Text('Required'),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged: (value) {
                setState(() {
                  selectedType = value.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // ✉️ Mail preview
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: modeColor(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: modeColor(context)),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'monospace', height: 1.4),
                child: Text(buildEmailBody()),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: sendEmail,
          icon: const Icon(Icons.send),
          label: const Text('Send Email'),
        ),
      ],
    );
  }
}
