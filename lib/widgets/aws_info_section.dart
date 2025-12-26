// lib/widgets/aws_info_section.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'gradient_text.dart';

class AwsInfoSection extends StatefulWidget {
  const AwsInfoSection({super.key});

  @override
  State<AwsInfoSection> createState() => _AwsInfoSectionState();
}

class _AwsInfoSectionState extends State<AwsInfoSection>
    with SingleTickerProviderStateMixin {
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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isSmall ? 20 : 40),
        vertical: isMobile ? 40 : 60,
      ),
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
                  // Background with Blur
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: Colors.black.withOpacity(0.50),
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
                    padding:
                        EdgeInsets.all(isMobile ? 20 : (isSmall ? 32 : 36)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: isMobile ? 32 : 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF146EB4),
                                    Color(0xFF00A1C9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: GradientText(
                                'Learn About AWS',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 20 : null,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700), // Gold
                                    Color(0xFFFFE0B2), // Light Orange/White-ish
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 16 : 24),
                        Text(
                          'Amazon Web Services (AWS) is the world\'s most comprehensive and broadly adopted cloud platform, offering over 200 fully featured services from data centers globally. AWS enables you to build, deploy, and scale applications with unmatched flexibility, security, and reliability.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.8),
                            fontSize: isMobile ? 14 : null,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Text(
                          'Whether you\'re a startup, enterprise, or government agency, AWS provides the tools and infrastructure to innovate faster, reduce costs, and scale your business. Join millions of customers who trust AWS to power their cloud journey.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.8),
                            fontSize: isMobile ? 14 : null,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        Wrap(
                          spacing: isMobile ? 12 : 16,
                          runSpacing: isMobile ? 12 : 16,
                          children: [
                            _HoverAwsButton(
                              onPressed: () async {
                                final uri = Uri.parse(
                                    'https://aws.amazon.com/what-is-aws/');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Learn More About AWS'),
                              isPrimary: true,
                              isMobile: isMobile,
                            ),
                            _HoverAwsButton(
                              onPressed: () async {
                                final uri =
                                    Uri.parse('https://aws.amazon.com/');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.explore),
                              label: const Text('Visit AWS'),
                              isPrimary: false,
                              isMobile: isMobile,
                            ),
                          ],
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
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 8); // Blur for glow

    canvas.drawRRect(rRect, shadowPaint);
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientBorderPainter oldDelegate) {
    return true;
  }
}

class _HoverAwsButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Widget label;
  final bool isPrimary;
  final bool isMobile;

  const _HoverAwsButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.isMobile,
  });

  @override
  State<_HoverAwsButton> createState() => _HoverAwsButtonState();
}

class _HoverAwsButtonState extends State<_HoverAwsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: widget.isPrimary
            ? ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon,
                label: widget.label,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered
                      ? const Color(0xFF00D4FF) // Vibrant Cyan
                      : const Color(0xFF146EB4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 20 : 24,
                    vertical: widget.isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isHovered ? 8 : 2,
                ),
              )
            : OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: widget.icon,
                label: widget.label,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isHovered
                      ? const Color(0xFF00FF88) // Vibrant Green
                      : const Color(0xFF146EB4),
                  side: BorderSide(
                    color: _isHovered
                        ? const Color(0xFF00FF88)
                        : const Color(0xFF146EB4),
                    width: 2,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 20 : 24,
                    vertical: widget.isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
      ),
    );
  }
}
