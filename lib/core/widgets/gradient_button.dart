import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.colors = const [Color(0xFF1F4E79), Color(0xFF00B4D8)],
    this.isLoading = false,
    this.loadingLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final List<Color> colors;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.78,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: borderRadius,
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? Row(
                        key: const ValueKey('loading'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.96)),
                            ),
                          ),
                          if (loadingLabel != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              loadingLabel!,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ],
                      )
                    : DefaultTextStyle(
                        key: const ValueKey('content'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ) ??
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        child: child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}