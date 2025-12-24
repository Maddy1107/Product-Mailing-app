import 'package:flutter/material.dart';

enum ProductItemDensity { compact, comfortable }

class ProductListItem extends StatelessWidget {
  final String productName;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final bool isSelected;
  final ProductItemDensity density;

  const ProductListItem({
    super.key,
    required this.productName,
    required this.trailingIcon,
    required this.onTap,
    required this.isSelected,
    this.density = ProductItemDensity.comfortable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 🎨 Background based on state
    final Color backgroundColor = isSelected
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;

    // 📏 Density control
    final EdgeInsets padding = density == ProductItemDensity.compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    final double iconSize = density == ProductItemDensity.compact ? 18 : 22;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.2, 0),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Padding(
        key: ValueKey(productName),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              // ✨ Subtle color flash on tap
              splashColor: colorScheme.primary.withValues(alpha: 0.15),
              highlightColor: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: padding,
                child: Row(
                  children: [
                    // 🟦 Leading avatar/icon
                    Container(
                      width: density == ProductItemDensity.compact ? 32 : 36,
                      height: density == ProductItemDensity.compact ? 32 : 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: iconSize,
                        color: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 📦 Product name
                    Expanded(
                      child: Text(
                        productName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ),

                    // ➕ / ➖ Action icon
                    Icon(
                      trailingIcon,
                      size: iconSize + 2,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
