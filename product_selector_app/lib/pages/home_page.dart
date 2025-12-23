import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/product_list_item.dart';
import '../dialogs/mail_preview_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> allProducts = [];
  List<String> filteredProducts = [];
  List<String> selectedProducts = [];

  // Store original index for restoring position
  final Map<String, int> originalIndexMap = {};

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    final jsonString = await rootBundle.loadString('assets/products.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      allProducts = jsonData.cast<String>();
      filteredProducts = List.from(allProducts);
    });
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = allProducts
          .where((p) => p.toLowerCase().contains(query))
          .toList();
    });
  }

  void moveToSelected(String product) {
    setState(() {
      final index = allProducts.indexOf(product);
      if (index != -1) {
        originalIndexMap[product] = index;
        allProducts.removeAt(index);
        selectedProducts.add(product);
        onSearchChanged();
      }
    });
  }

  void moveToAvailable(String product) {
    setState(() {
      selectedProducts.remove(product);

      final originalIndex = originalIndexMap[product];
      if (originalIndex != null && originalIndex <= allProducts.length) {
        allProducts.insert(originalIndex, product);
      } else {
        allProducts.add(product);
      }

      originalIndexMap.remove(product);
      onSearchChanged();
    });
  }

  void clearAllSelected() {
    setState(() {
      for (final product in selectedProducts) {
        final originalIndex = originalIndexMap[product];
        if (originalIndex != null && originalIndex <= allProducts.length) {
          allProducts.insert(originalIndex, product);
        } else {
          allProducts.add(product);
        }
        originalIndexMap.remove(product);
      }
      selectedProducts.clear();
      onSearchChanged();
    });
  }

  Future<void> confirmClearAll() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all selected products?'),
        content: const Text(
          'This will remove all selected products and return them to the available list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      clearAllSelected();
    }
  }

  void showNextPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return MailPreviewDialog(selectedProducts: selectedProducts);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = searchController.text.isNotEmpty
        ? filteredProducts
        : filteredProducts.take(50).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Mail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),

      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔼 Available products
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: visibleProducts.length,
              itemBuilder: (context, index) {
                final product = visibleProducts[index];
                return ProductListItem(
                  productName: product,
                  trailingIcon: Icons.add,
                  onTap: () => moveToSelected(product),
                );
              },
            ),
          ),

          // 🔽 Selected products
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selectedProducts.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(thickness: 1),

                      // Header with count + clear all
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Row(
                          children: [
                            Text(
                              'Selected products (${selectedProducts.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: selectedProducts.isEmpty
                                  ? null
                                  : confirmClearAll,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Clear all'),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 350,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: selectedProducts.length,
                          itemBuilder: (context, index) {
                            final product = selectedProducts[index];
                            return ProductListItem(
                              productName: product,
                              trailingIcon: Icons.remove,
                              onTap: () => moveToAvailable(product),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showNextPopup,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
      ),
    );
  }
}
