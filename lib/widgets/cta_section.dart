// lib/widgets/cta_section.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'gradient_text.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF146EB4).withValues(alpha: 0.1),
            const Color(0xFF00A1C9).withValues(alpha: 0.05),
          ],
        ),
      ),
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: 50,
          child: FadeInAnimation(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 24 : (isSmall ? 32 : 40)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                    color: Colors.black.withOpacity(0.50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GradientText(
                        'Ready to Start Your Cloud Journey?',
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
                        'Join AWS Cloud Club today and be part of an exciting community where you can learn, grow, and explore the world of cloud computing!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.6,
                          fontSize: isMobile ? 14 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                      Wrap(
                        spacing: isMobile ? 12 : 16,
                        runSpacing: isMobile ? 12 : 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _HoverCtaButton(
                            onPressed: () => context.go('/events'),
                            icon: const Icon(Icons.explore),
                            label: const Text('Explore Events'),
                            isPrimary: true,
                            isMobile: isMobile,
                          ),
                          _HoverCtaButton(
                            onPressed: () => context.go('/contact'),
                            icon: const Icon(Icons.contact_mail),
                            label: const Text('Contact Us'),
                            isPrimary: false,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ],
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

class _HoverCtaButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Widget label;
  final bool isPrimary;
  final bool isMobile;

  const _HoverCtaButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.isMobile,
  });

  @override
  State<_HoverCtaButton> createState() => _HoverCtaButtonState();
}

class _HoverCtaButtonState extends State<_HoverCtaButton> {
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
                    horizontal: widget.isMobile ? 24 : 32,
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
                    horizontal: widget.isMobile ? 24 : 32,
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
