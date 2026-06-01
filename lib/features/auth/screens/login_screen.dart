import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _logoFloatController;
  late final AnimationController _cardFloatController;
  late final AnimationController _shimmerController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _logoFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _cardFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _logoFloatController.dispose();
    _cardFloatController.dispose();
    _shimmerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authServiceProvider).signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      if (!mounted) return;
      GoRouter.of(context).go('/home');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      GoRouter.of(context).go('/home');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBuilder(animation: Listenable.merge([_logoFloatController, _shimmerController]), builder: (_, __) => CustomPaint(painter: _AuroraPainter(_logoFloatController.value)))),
          Positioned.fill(child: CustomPaint(painter: _ParticlePainter())),
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        // Logo
                        AnimatedBuilder(
                          animation: _logoFloatController,
                          builder: (context, child) {
                            final t = sin(_logoFloatController.value * 2 * pi) * -8;
                            return Transform.translate(offset: Offset(0, t), child: child);
                          },
                          child: Column(
                            children: [
                              _ThreeDIcon(),
                              const SizedBox(height: 12),
                              ShaderMask(
                                shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFFF006E)]).createShader(r),
                                child: Text('Price Tracker', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                              const SizedBox(height: 6),
                              Text('Track prices. Save money.', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Glass card
                        AnimatedBuilder(
                          animation: _cardFloatController,
                          builder: (context, child) {
                            final y = sin(_cardFloatController.value * 2 * pi) * -6;
                            return Transform.translate(offset: Offset(0, y), child: child);
                          },
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Stack(
                                children: [
                                  // Gradient rotating border
                                  Positioned.fill(child: CustomPaint(painter: _RotatingBorderPainter())),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _NeonTextField(controller: _emailController, focusNode: _emailFocus, hint: 'Email', keyboardType: TextInputType.emailAddress),
                                            const SizedBox(height: 12),
                                            _NeonTextField(controller: _passwordController, focusNode: _passwordFocus, hint: 'Password', obscureText: true),
                                            const SizedBox(height: 18),
                                            _ShimmerButton(shimmer: _shimmerController, onTap: _submit, label: 'Login', loading: _loading),
                                            const SizedBox(height: 12),
                                            _GoogleGlassButton(onTap: _signInWithGoogle),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () => GoRouter.of(context).go('/auth/register'),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ShaderMask(
                              shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFFF006E)]).createShader(r),
                              child: Text('Don\'t have an account? Register', style: GoogleFonts.inter(color: Colors.white, decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 4; i >= 1; i--)
            Transform.translate(
              offset: Offset(0, i.toDouble()),
              child: Container(width: 74 + i * 4, height: 74 + i * 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.12 * i), borderRadius: BorderRadius.circular(18))),
            ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)]),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 12))],
            ),
            child: const Center(child: Icon(Icons.show_chart_rounded, color: Colors.white, size: 40)),
          ),
        ],
      ),
    );
  }
}

class _NeonTextField extends StatefulWidget {
  const _NeonTextField({required this.controller, required this.focusNode, required this.hint, this.obscureText = false, this.keyboardType});
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  @override
  State<_NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<_NeonTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        boxShadow: focused
            ? [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.12), blurRadius: 20, spreadRadius: 2), BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.06), blurRadius: 36, spreadRadius: 6)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 8, offset: const Offset(0, 6))],
      ),
      height: 54,
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(border: InputBorder.none, hintText: widget.hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45))),
        ),
      ),
    );
  }
}

class _ShimmerButton extends StatefulWidget {
  const _ShimmerButton({required this.shimmer, required this.onTap, required this.label, required this.loading});
  final AnimationController shimmer;
  final VoidCallback onTap;
  final String label;
  final bool loading;
  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF2563EB), Color(0xFF06B6D4)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 10))],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: widget.shimmer,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment(-1 + widget.shimmer.value * 2, 0),
                    widthFactor: 0.28,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.01)]))),
                    ),
                  );
                },
              ),
              Center(child: widget.loading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleGlassButton extends StatelessWidget {
  const _GoogleGlassButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white), child: const Center(child: Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)))),
            const SizedBox(width: 12),
            Text('Continue with Google', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

// Painters
class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.progress);
  final double progress;
  final Random _rnd = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF080818);
    canvas.drawRect(Offset.zero & size, bg);

    final colors = [const Color(0xFF7C3AED), const Color(0xFF2563EB), const Color(0xFF06B6D4)];
    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.18) % 1.0;
      final x = size.width * (0.2 + i * 0.25) + sin(t * 2 * pi) * 40;
      final y = size.height * (0.35 + i * 0.12) + cos(t * 2 * pi) * 60;
      final radius = size.width * 0.45 * (0.2 + i * 0.08);
      final rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
      final gradient = RadialGradient(colors: [colors[i].withValues(alpha: 0.14), colors[i].withValues(alpha: 0.0)]);
      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}

class _ParticlePainter extends CustomPainter {
  final Random _rnd = Random(123);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    for (int i = 0; i < 120; i++) {
      final x = _rnd.nextDouble() * size.width;
      final y = _rnd.nextDouble() * size.height;
      final r = 0.6 + _rnd.nextDouble() * 1.6;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RotatingBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(20));
    final gradient = SweepGradient(colors: [const Color(0xFF7C3AED), const Color(0xFF06B6D4), const Color(0xFFFF006E), const Color(0xFF7C3AED)], stops: const [0, 0.45, 0.75, 1]);
    final paint = Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
