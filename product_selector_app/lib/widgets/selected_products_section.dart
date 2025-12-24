import 'package:flutter/material.dart';
import 'product_list_item.dart';

class SelectedProductsSection extends StatelessWidget {
  final List<String> products;
  final VoidCallback onClearAll;
  final ValueChanged<String> onRemove;

  const SelectedProductsSection({
    super.key,
    required this.products,
    required this.onClearAll,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Selected products (${products.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              return ProductListItem(
                productName: product,
                trailingIcon: Icons.remove,
                isSelected: true,
                density: ProductItemDensity.comfortable,
                onTap: () => onRemove(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
