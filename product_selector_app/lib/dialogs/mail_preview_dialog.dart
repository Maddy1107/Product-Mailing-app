import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum MailType { received, required }

class MailPreviewDialog extends StatefulWidget {
  final List<String> selectedProducts;

  const MailPreviewDialog({super.key, required this.selectedProducts});

  @override
  State<MailPreviewDialog> createState() => _MailPreviewDialogState();
}

class _MailPreviewDialogState extends State<MailPreviewDialog> {
  MailType selectedType = MailType.received;

  String get mailTypeText =>
      selectedType == MailType.received ? 'received' : 'required';

  String buildEmailBody() {
    final buffer = StringBuffer();

    buffer.writeln('Dear team,\n');
    buffer.writeln('Below are the products $mailTypeText:\n');

    for (int i = 0; i < widget.selectedProducts.length; i++) {
      buffer.writeln('${i + 1}. ${widget.selectedProducts[i]}');
    }

    buffer.writeln('\nThank you');
    buffer.writeln('Priyanka Roy');

    return buffer.toString();
  }

  Future<void> sendEmail() async {
    final subject = 'Product $mailTypeText update';
    final body = buildEmailBody();

    final Uri emailUri = Uri(
      scheme: 'mailto',
      queryParameters: {'subject': subject, 'body': body},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication, // ✅ SHOW APP CHOOSER
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No email app found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      title: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Mail preview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),

      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SegmentedButton<MailType>(
                  segments: const [
                    ButtonSegment(
                      value: MailType.received,
                      label: Text('Received'),
                      icon: Icon(Icons.inbox),
                    ),
                    ButtonSegment(
                      value: MailType.required,
                      label: Text('Required'),
                      icon: Icon(Icons.outbox),
                    ),
                  ],
                  selected: <MailType>{selectedType},
                  onSelectionChanged: (value) {
                    setState(() {
                      selectedType = value.first;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🟦 Mail preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dear team,\n\n'
                        'Below are the products $mailTypeText:\n',
                      ),
                      ...List.generate(
                        widget.selectedProducts.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${index + 1}. ${widget.selectedProducts[index]}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Thank you\n'
                        'Priyanka Roy',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton.icon(
          onPressed: widget.selectedProducts.isEmpty ? null : sendEmail,
          icon: const Icon(Icons.send),
          label: const Text('Send Email'),
        ),
      ],
    );
  }
}
