import 'package:flutter/material.dart';

class SetAlertBottomSheet extends StatefulWidget {
  const SetAlertBottomSheet({
    super.key,
    required this.productId,
    required this.currentPrice,
    required this.lowestPrice,
  });

  final String productId;
  final double currentPrice;
  final double lowestPrice;

  @override
  State<SetAlertBottomSheet> createState() => _SetAlertBottomSheetState();
}

class _SetAlertBottomSheetState extends State<SetAlertBottomSheet> {
  late final TextEditingController _controller;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentPrice;
    _controller = TextEditingController(text: widget.currentPrice.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -8)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Set Price Alert', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'We’ll notify you when the price drops below your target.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(controller: _controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target price')),
              const SizedBox(height: 16),
              Slider(
                min: widget.lowestPrice,
                max: widget.currentPrice == widget.lowestPrice ? widget.lowestPrice + 1 : widget.currentPrice,
                value: _sliderValue.clamp(widget.lowestPrice, widget.currentPrice == widget.lowestPrice ? widget.lowestPrice + 1 : widget.currentPrice),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                    _controller.text = value.toStringAsFixed(0);
                  });
                },
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save Alert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}