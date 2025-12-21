import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'selected_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> availableProducts = [];
  List<String> selectedProducts = [];
  bool showList = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final String jsonString = await rootBundle.loadString(
      'assets/product_list.json',
    );

    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      availableProducts = jsonData.cast<String>();
    });
  }

  void selectProduct(String product) {
    setState(() {
      availableProducts.remove(product);
      selectedProducts.add(product);
    });
  }

  void goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectedPage(products: selectedProducts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => showList = true),
              child: const Text('Show Products'),
            ),
            const SizedBox(height: 16),

            if (showList)
              Expanded(
                child: ListView.builder(
                  itemCount: availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = availableProducts[index];
                    return Card(
                      child: ListTile(
                        title: Text(product),
                        trailing: const Icon(Icons.add),
                        onTap: () => selectProduct(product),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: selectedProducts.isEmpty ? null : goToNextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
