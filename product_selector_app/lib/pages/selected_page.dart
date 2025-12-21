import 'package:flutter/material.dart';

class SelectedPage extends StatelessWidget {
  final List<String> products;

  const SelectedPage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selected Products')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(products[index]),
            ),
          );
        },
      ),
    );
  }
}
