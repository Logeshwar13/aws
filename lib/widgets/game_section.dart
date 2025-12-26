// lib/widgets/game_section.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';

class GameSection extends StatefulWidget {
  const GameSection({super.key});

  @override
  State<GameSection> createState() => _GameSectionState();
}

class _GameSectionState extends State<GameSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: 50,
          child: FadeInAnimation(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bg2.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1A1F2E), // Fallback color
                        );
                      },
                    ),
                  ),
                  // Blur Overlay
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                  // Animated Border Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AnimatedGradientBorderPainter(
                        animation: _controller,
                        strokeWidth: 2,
                        radius: isMobile ? 16 : 20,
                      ),
                    ),
                  ),
                  // Content
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 24 : (isSmall ? 32 : 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Left align
                      children: [
                        GradientText(
                          'Defend the AWS Cloud in Space!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 22 : null,
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFD700), // Gold
                              Color(0xFFFFE0B2), // Light Orange/White-ish
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Text(
                          'Aliens are trying to breach the AWS cloud, and it’s your mission to stop them. Answer each question correctly to attack the invaders and earn points. A wrong answer will cost you one of your three hearts.Click Play Now to begin your mission!',
                          textAlign: TextAlign.left, // Left align
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.6,
                            fontSize: isMobile ? 14 : null,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        _GradientButton(
                          onPressed: () async {
                            const url = 'https://space-nine-puce.vercel.app/';
                            final uri = Uri.parse(url);
                            try {
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                debugPrint('Could not launch $url');
                              }
                            } catch (e) {
                              debugPrint('Error launching URL: $e');
                            }
                          },
                          icon: Icons.sports_esports,
                          label: 'Play Now',
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double strokeWidth;
  final double radius;

  _AnimatedGradientBorderPainter({
    required this.animation,
    required this.strokeWidth,
    required this.radius,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF071A3A),
          Color(0xFF1A4BA0),
          Color(0xFF00C9FF),
          Color(0xFFFF9900),
          Color(0xFF071A3A), // Close loop
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: GradientRotation(animation.value * 2 * math.pi),
      ).createShader(rect);

    // Draw Shadow (Glow)
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4 // Slightly wider for glow
      ..shader = paint.shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Blur for glow

    canvas.drawRRect(rRect, shadowPaint);
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientBorderPainter oldDelegate) {
    return true;
  }
}

class _GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isMobile;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isMobile,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 24 : 32,
                  vertical: widget.isMobile ? 14 : 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D47A1), // Dark Blue
                      Color(0xFF42A5F5), // Lighter Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(_isHovered ? 0.6 : 0.3),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
