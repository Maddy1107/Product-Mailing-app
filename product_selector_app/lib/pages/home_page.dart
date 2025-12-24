import 'package:flutter/material.dart';
import 'package:product_selector_app/dialogs/mail_preview_dialog.dart';
import 'package:product_selector_app/dialogs/name_prompt_dialog.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/available_products_list.dart';
import '../widgets/selected_products_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _ProfileAction { changeName, addProduct }

class _HomePageState extends State<HomePage> {
  final controller = ProductController();
  final searchController = TextEditingController();
  String? userName;

  @override
  void initState() {
    super.initState();

    controller.loadProducts().then((_) {
      if (mounted) setState(() {});
    });

    searchController.addListener(() {
      setState(() {
        controller.filter(searchController.text);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserNameOnStartup();
    });
  }

  void showNextPopup() {
    if (controller.selectedProducts.isEmpty) {
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
        selectedProducts: controller.selectedProducts,
        userName: userName ?? 'User',
      ),
    );
  }

  Future<void> _changeName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const NamePromptDialog(),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', result);

      if (!mounted) return;

      setState(() {
        userName = result;
      });
    }
  }

  Future<void> _addProduct() async {
    return;
    // final controllerText = TextEditingController();

    // final result = await showDialog<String>(
    //   context: context,
    //   builder: (_) {
    //     return AlertDialog(
    //       title: const Text('Add product'),
    //       content: TextField(
    //         controller: controllerText,
    //         autofocus: true,
    //         decoration: const InputDecoration(hintText: 'Product name'),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: const Text('Cancel'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             final value = controllerText.text.trim();
    //             if (value.isNotEmpty) {
    //               Navigator.pop(context, value);
    //             }
    //           },
    //           child: const Text('Add'),
    //         ),
    //       ],
    //     );
    //   },
    // );

    // if (!mounted) return;

    // if (result != null && result.isNotEmpty) {
    //   setState(() {
    //     controller.allProducts.add(result);
    //     controller.filter(searchController.text);
    //   });
    // }
  }

  Future<void> _checkUserNameOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedName = prefs.getString('user_name');

    if (savedName == null || savedName.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false, // ❌ must enter name
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),

            // 👤 PROFILE AVATAR (LEFT)
            PopupMenuButton<_ProfileAction>(
              tooltip: 'Profile options',
              onSelected: (value) {
                switch (value) {
                  case _ProfileAction.changeName:
                    _changeName();
                    break;

                  // case _ProfileAction.addProduct:
                  //   _addProduct();
                  //   break;

                  default:
                    // No action for now
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ProfileAction.changeName,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Change name'),
                  ),
                ),

                // PopupMenuItem(
                //   value: _ProfileAction.addProduct,
                //   child: ListTile(
                //     leading: Icon(Icons.add_box),
                //     title: Text('Add product'),
                //   ),
                // ),
              ],

              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _getInitials(userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 🏷️ TITLE + SUBTITLE
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Product Mail',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (userName != null)
                  Text(
                    'Hi, ${userName!.trim().split(' ').first}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: showNextPopup,
          ),
        ],
      ),
      body: Column(
        children: [
          ProductSearchBar(
            controller: searchController,
            onClear: () {
              searchController.clear();
              controller.filter('');
              setState(() {});
            },
          ),
          Expanded(
            child: AvailableProductsList(
              products: controller.filteredProducts,
              onTap: (p) => setState(() => controller.select(p)),
            ),
          ),
          SelectedProductsSection(
            products: controller.selectedProducts,
            onClearAll: () => setState(controller.clearSelected),
            onRemove: (p) => setState(() => controller.unselect(p)),
          ),
        ],
      ),
    );
  }
}
