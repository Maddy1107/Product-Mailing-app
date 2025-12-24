import 'dart:convert';
import 'package:flutter/services.dart';

class ProductController {
  List<String> allProducts = [];
  List<String> filteredProducts = [];
  List<String> selectedProducts = [];

  final Map<String, int> originalIndexes = {};

  Future<void> loadProducts() async {
    final jsonString = await rootBundle.loadString('assets/product_list.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    allProducts = jsonData.cast<String>();
    filteredProducts = List.from(allProducts);
  }

  void filter(String query) {
    filteredProducts = allProducts
        .where((p) => p.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void select(String product) {
    originalIndexes[product] = allProducts.indexOf(product);
    allProducts.remove(product);
    selectedProducts.add(product);
    filter('');
  }

  void unselect(String product) {
    final index = originalIndexes[product] ?? allProducts.length;
    selectedProducts.remove(product);
    allProducts.insert(index, product);
    filter('');
  }

  void clearSelected() {
    for (final product in selectedProducts) {
      final index = originalIndexes[product] ?? allProducts.length;
      allProducts.insert(index, product);
    }
    selectedProducts.clear();
    filter('');
  }
}
