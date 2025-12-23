import 'package:flutter/material.dart';

class ProductListItem extends StatelessWidget {
  final String productName;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const ProductListItem({
    super.key,
    required this.productName,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(productName),
        trailing: Icon(trailingIcon),
        onTap: onTap,
      ),
    );
  }
}
