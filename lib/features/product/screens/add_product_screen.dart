import 'package:flutter/material.dart';

import '../../../core/widgets/fancy_background.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Add Product')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Track a new product', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Paste a Daraz product link and let the app watch the price for you.'),
                        const SizedBox(height: 18),
                        const TextField(decoration: InputDecoration(labelText: 'Product URL')),
                        const SizedBox(height: 14),
                        const TextField(decoration: InputDecoration(labelText: 'Product name')),
                        const SizedBox(height: 14),
                        FilledButton(onPressed: null, child: const Text('Add product')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}