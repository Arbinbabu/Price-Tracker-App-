import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:price_tracker_app/features/product/providers/product_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _urlController = TextEditingController();

  Future<void> _submit() async {
    final productId = await ref.read(addProductControllerProvider.notifier).addProduct(_urlController.text.trim());
    if (mounted) context.go('/product/$productId');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addProductControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Daraz product URL',
                hintText: 'https://www.daraz.com.np/products/...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state is AsyncLoading ? null : _submit,
              child: state is AsyncLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Track Product'),
            ),
          ],
        ),
      ),
    );
  }
}
