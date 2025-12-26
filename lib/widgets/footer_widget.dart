// lib/widgets/footer_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F2E).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 20 : 40,
        vertical: isSmall ? 20 : 24,
      ),
      child: isSmall
          ? _buildMobileLayout(context, theme, isDark)
          : _buildDesktopLayout(context, theme, isDark),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Club info
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Image.asset(
                'assets/images/aws_logo.jpg',
                height: 36,
                width: 36,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF00FFFF), // Neon Cyan
                        Color(0xFF2979FF), // Electric Blue
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'AWS Cloud Club',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '© ${DateTime.now().year} All rights reserved',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Center: Quick Links
        Expanded(
          flex: 2,
          child: Wrap(
            spacing: 20,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink(context, 'Code of Conduct', '/code-of-conduct',
                  theme, isDark),
              _buildFooterLink(context, 'About', '/about', theme, isDark),
              _buildFooterLink(context, 'Events', '/events', theme, isDark),
              _buildFooterLink(context, 'Contact', '/contact', theme, isDark),
            ],
          ),
        ),

        // Right: Social Links
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSocialIcon(
                assetPath: 'assets/icons/instagram.png',
                url: 'https://www.instagram.com/aws_cloudclub_smvec?igsh=MWs2MzRueHFkcGs1Ng==',
                color: const Color(0xFFE4405F),
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildSocialIcon(
                assetPath: 'assets/icons/whatsapp.png',
                url: 'https://wa.me/919345671593',
                color: const Color(0xFF25D366),
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildSocialIcon(
                assetPath: 'assets/icons/linkedin.png',
                url: 'https://www.linkedin.com/company/aws-cloud-club-smvec1/',
                color: const Color(0xFF0077B5),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Club info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/aws_logo.jpg',
              height: 32,
              width: 32,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF00FFFF), // Neon Cyan
                  Color(0xFF2979FF), // Electric Blue
                ],
              ).createShader(bounds),
              child: Text(
                'AWS Cloud Club',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Links
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildFooterLink(
                context, 'Code of Conduct', '/code-of-conduct', theme, isDark),
            _buildFooterLink(context, 'About', '/about', theme, isDark),
            _buildFooterLink(context, 'Events', '/events', theme, isDark),
            _buildFooterLink(context, 'Contact', '/contact', theme, isDark),
          ],
        ),

        const SizedBox(height: 12),

        // Social Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              assetPath: 'assets/icons/instagram.png',
              url: 'https://www.instagram.com/aws_cloudclub_smvec?igsh=MWs2MzRueHFkcGs1Ng==',
              color: const Color(0xFFE4405F),
              theme: theme,
            ),
            const SizedBox(width: 12),
            _buildSocialIcon(
              assetPath: 'assets/icons/whatsapp.png',
              url: 'https://wa.me/919345671593',
              color: const Color(0xFF25D366),
              theme: theme,
            ),
            const SizedBox(width: 12),
            _buildSocialIcon(
              assetPath: 'assets/icons/linkedin.png',
              url: 'https://www.linkedin.com/company/aws-cloud-club-smvec1/',
              color: const Color(0xFF0077B5),
              theme: theme,
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          '© ${DateTime.now().year} AWS Cloud Club. All rights reserved.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route,
      ThemeData theme, bool isDark) {
    return _HoverLink(
      text: text,
      onTap: () => context.go(route),
      theme: theme,
    );
  }

  Widget _buildSocialIcon({
    required String assetPath,
    required String url,
    required Color color,
    required ThemeData theme,
  }) {
    return _HoverSocialIcon(
      assetPath: assetPath,
      color: color,
      onTap: () => _launchURL(url),
    );
  }
}

class _HoverLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final ThemeData theme;

  const _HoverLink({
    required this.text,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isHovered
                ? widget.theme.colorScheme.primary
                : widget.theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            decoration: _isHovered ? TextDecoration.underline : null,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}

class _HoverSocialIcon extends StatefulWidget {
  final String assetPath;
  final Color color;
  final VoidCallback onTap;

  const _HoverSocialIcon({
    required this.assetPath,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverSocialIcon> createState() => _HoverSocialIconState();
}

class _HoverSocialIconState extends State<_HoverSocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _isHovered ? widget.color : widget.color.withOpacity(0.3),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Image.asset(
            widget.assetPath,
            width: 20,
            height: 20,
            // No color filter to keep original asset colors
          ),
        ),
      ),
    );
  }
}