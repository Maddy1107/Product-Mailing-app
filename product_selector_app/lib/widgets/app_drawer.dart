import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userName;
  final VoidCallback onChangeName;
  final VoidCallback onAddProduct;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.onChangeName,
    required this.onAddProduct,
  });

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(userName);

    return Drawer(
      child: Column(
        children: [
          // 🟣 TOP INITIALS SECTION (PR style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName ?? 'User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ✏️ Change name
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Change name'),
            splashColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            hoverColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            onTap: () {
              Navigator.pop(context);
              onChangeName();
            },
          ),

          // ➕ Add product
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Add product'),
            splashColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            hoverColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            onTap: () {
              Navigator.pop(context);
              onAddProduct();
            },
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Product Mail', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
