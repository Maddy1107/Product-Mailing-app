import 'package:flutter/material.dart';
import 'product_list_item.dart';

class AvailableProductsList extends StatelessWidget {
  final List<String> products;
  final ValueChanged<String> onTap;

  const AvailableProductsList({
    super.key,
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return ProductListItem(
          productName: product,
          trailingIcon: Icons.add,
          isSelected: false,
          density: ProductItemDensity.compact,
          onTap: () => onTap(product),
        );
      },
    );
  }
}
