// lib/screens/admin/admin_login_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

import '../../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good night';
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      await auth.signInWithEmail(_email.text.trim(), _pass.text);
      if (!mounted) return;
      context.go('/admin/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width <= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ===== Animated mesh background (from hero_section) =====
            Positioned.fill(
              child: AnimatedMeshGradient(
                colors: const [
                  Color(0xFF071A3A),
                  Color(0xFF1A4BA0),
                  Color(0xFF00C9FF),
                  Color(0xFFFFD700),
                ],
                options:  AnimatedMeshGradientOptions(
                  frequency: 2,
                  amplitude: 30,
                  speed: 4,
                  grain: 0.05,
                ),
              ),
            ),

            // ===== Grid overlay =====
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GridPainter(
                    lineColor: Colors.white.withOpacity(0.15),
                    majorLineColor: Colors.white.withOpacity(0.25),
                    spacing: 48,
                    majorSpacing: 240,
                  ),
                ),
              ),
            ),

            // ===== Dark gradient overlay (top -> bottom) =====
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF071A3A).withOpacity(0.45),
                      const Color(0xFF071A3A).withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // ===== Foreground content: left logo panel + right login card =====
            Positioned.fill(
              child: Row(
                children: [
                  // LEFT PANEL with big logo (hidden on narrow screens)
                  if (!isNarrow)
                      Expanded(
  flex: 2,
  child: Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Image.asset(
        'assets/images/logo2.png',
        height: 2000,   // <-- set BIGGER logo here
        fit: BoxFit.contain,
      ),
    ),
  ),
),

                    // Expanded(
                    //   flex: 2,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(24.0),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(32),
                    //         color: Colors.black.withOpacity(0.5),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.4),
                    //             offset: const Offset(0, 20),
                    //             blurRadius: 40,
                    //           ),
                    //         ],
                    //         image: const DecorationImage(
                    //           image: AssetImage(
                    //               'assets/images/logo2.png'), // your logo
                    //           fit: BoxFit.contain,
                    //           alignment: Alignment.center,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                  // RIGHT LOGIN CARD
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          elevation: 16,
                          color: theme.colorScheme.surface.withOpacity(0.96),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Container(
                            width: 420,
                            padding: const EdgeInsets.all(40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ===== Greeting header (text only) =====
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$greeting, Admin!',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Welcome back to the AWS Cloud Club.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSecondaryContainer
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 28),
                                  Text(
                                    'Admin Login',
                                    textAlign: TextAlign.left,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sign in to manage events',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // EMAIL
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Invalid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // PASSWORD
                                  TextFormField(
                                    controller: _pass,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (v.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  // ERROR MESSAGE
                                  if (_error != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _error!,
                                              style: TextStyle(
                                                color: theme.colorScheme
                                                    .onErrorContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 28),

                                  // LOGIN BUTTON
                                  ElevatedButton(
                                    onPressed: _loading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text('Login'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid painter reused from hero background
class _GridPainter extends CustomPainter {
  final Color lineColor;
  final Color majorLineColor;
  final double spacing;
  final double majorSpacing;

  _GridPainter({
    this.lineColor = const Color(0xFFFFFFFF),
    this.majorLineColor = const Color(0xFFFFFFFF),
    this.spacing = 48.0,
    this.majorSpacing = 240.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = lineColor
      ..isAntiAlias = true;

    final Paint majorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = majorLineColor
      ..isAntiAlias = true;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (x % majorSpacing == 0) ? majorPaint : paint,
      );
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (y % majorSpacing == 0) ? majorPaint : paint,
      );
    }

    final rect = Offset.zero & size;
    final shader = ui.Gradient.radial(
      size.center(Offset.zero),
      (size.width > size.height ? size.width : size.height) * 0.7,
      [Colors.transparent, Colors.black.withOpacity(0.50)],
      [0.6, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = shader..blendMode = BlendMode.darken);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.majorLineColor != majorLineColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.majorSpacing != majorSpacing;
  }
}
