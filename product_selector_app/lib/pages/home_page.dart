import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/product_list_item.dart';
import '../dialogs/mail_preview_dialog.dart';
import '../dialogs/name_prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> allProducts = [];
  List<String> filteredProducts = [];
  List<String> selectedProducts = [];
  String? userName;

  final Map<String, int> originalIndexes = {};
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserName();
    });
  }

  Future<void> loadProducts() async {
    final jsonString = await rootBundle.loadString('assets/product_list.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      allProducts = jsonData.cast<String>();
      filteredProducts = List.from(allProducts);
    });
  }

  Future<void> checkUserName() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final savedName = prefs.getString('user_name');

    if (savedName == null || savedName.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const NamePromptDialog(),
      );

      if (!mounted) return;

      if (result != null && result.isNotEmpty) {
        await prefs.setString('user_name', result);

        if (!mounted) return;

        setState(() {
          userName = result;
        });
      }
    } else {
      setState(() {
        userName = savedName;
      });
    }
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
    originalIndexes[product] = allProducts.indexOf(product);

    setState(() {
      allProducts.remove(product);
      selectedProducts.add(product);
      onSearchChanged();
    });
  }

  void moveToAvailable(String product) {
    final index = originalIndexes[product] ?? allProducts.length;

    setState(() {
      selectedProducts.remove(product);
      allProducts.insert(index, product);
      onSearchChanged();
    });
  }

  void clearAllSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all selected products?'),
        content: const Text(
          'This will move all selected products back to available.',
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

    if (confirmed != true) return;

    setState(() {
      for (final product in selectedProducts) {
        final index = originalIndexes[product] ?? allProducts.length;
        allProducts.insert(index, product);
      }
      selectedProducts.clear();
      onSearchChanged();
    });
  }

  void showNextPopup() {
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => MailPreviewDialog(
        selectedProducts: selectedProducts,
        userName: userName ?? 'User',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Mail',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (userName != null)
              Text(
                'Hi, ${userName?.trim().split(' ').first}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Next',
            onPressed: showNextPopup,
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 🔼 AVAILABLE PRODUCTS
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: ListView.builder(
                key: ValueKey(filteredProducts.length),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductListItem(
                    productName: product,
                    trailingIcon: Icons.add,
                    isSelected: false,
                    density: ProductItemDensity.compact,
                    onTap: () => moveToSelected(product),
                  );
                },
              ),
            ),
          ),

          // 🔽 SELECTED SECTION
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selectedProducts.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),

                      // 🔢 Header with count + clear all
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          key: ValueKey(selectedProducts.length),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Selected products (${selectedProducts.length})',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: selectedProducts.isEmpty
                                    ? null
                                    : clearAllSelected,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Clear all'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: selectedProducts.length,
                          itemBuilder: (context, index) {
                            final product = selectedProducts[index];
                            return ProductListItem(
                              productName: product,
                              trailingIcon: Icons.remove,
                              isSelected: true,
                              density: ProductItemDensity.comfortable,
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
    );
  }
}
