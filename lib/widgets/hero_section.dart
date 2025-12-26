import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';

class HeroSectionWithThreads extends StatelessWidget {
  final String headline;
  final String sub;
  final bool useThreads;

  const HeroSectionWithThreads({
    super.key,
    this.headline = 'AWS Cloud Club',
    this.sub = 'Learn • Build • Share',
    this.useThreads = true,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 900;
    final isMobile = w < 600;

    // Increased height for stats card
    final heroHeight = isMobile ? 650.0 : (isSmall ? 700.0 : 650.0);

    final content = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 20 : 40, vertical: isSmall ? 30 : 40),
      child: isSmall ? _mobileLayout(context) : _desktopLayout(context),
    );

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: content,
    );
  }

  Widget _desktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 80),
        AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF00FFFF), // Neon Cyan
                        Color(0xFF2979FF), // Electric Blue
                      ],
                    ).createShader(bounds),
                    child: Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 64,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SMVEC',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puducherry, India',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.50),
                          offset: const Offset(0, 6),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Text(
                      'An official Amazon Web Services (AWS) initiative',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Text(
                      'The first AWS Cloud Club in Puducherry, dedicated to providing hands-on cloud computing education, practical upskilling,\nand networking opportunities.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      GradientHoverButton(
                        label: 'Explore Events',
                        icon: Icons.explore,
                        onPressed: () => GoRouter.of(context).go('/events'),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF0E2A56), Color(0xFF1A4BA0)]),
                      ),
                      GradientHoverButton(
                        label: 'Join the Community',
                        icon: Icons.people,
                        onPressed: () async {
                          const url =
                              'https://www.meetup.com/aws-cloud-club-at-sri-manakula-vinayagar-engineering-college/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        outlined: true,
                        gradient: const LinearGradient(
                            colors: [Color(0xFF0E2A56), Color(0xFF1A4BA0)]),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFF2979FF)],
                ).createShader(bounds),
                child: Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SMVEC',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 26,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Puducherry, India',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.06), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(0, 6),
                        blurRadius: 18),
                  ],
                ),
                child: Text(
                  'An official Amazon Web Services (AWS) initiative',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'The first AWS Cloud Club in Puducherry, dedicated to providing hands-on cloud computing education and networking opportunities.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  GradientHoverButton(
                    label: 'Explore Events',
                    icon: Icons.explore,
                    onPressed: () => GoRouter.of(context).go('/events'),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0E2A56), Color(0xFF1A4BA0)]),
                    isSmall: true,
                  ),
                  GradientHoverButton(
                    label: 'Join Community',
                    icon: Icons.people,
                    onPressed: () async {
                      const url =
                          'https://www.meetup.com/aws-cloud-club-at-sri-manakula-vinayagar-engineering-college/';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    outlined: true,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0E2A56), Color(0xFF1A4BA0)]),
                    isSmall: true,
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class GradientHoverButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;
  final LinearGradient gradient;
  final bool isSmall;

  const GradientHoverButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    required this.gradient,
    this.isSmall = false,
  });

  @override
  State<GradientHoverButton> createState() => _GradientHoverButtonState();
}

class _GradientHoverButtonState extends State<GradientHoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: widget.gradient.colors,
      begin: widget.gradient.begin,
      end: widget.gradient.end,
    );

    final decoration = BoxDecoration(
      gradient: widget.outlined ? null : gradient,
      color: widget.outlined
          ? Colors.white.withOpacity(_hover ? 0.14 : 0.06)
          : null,
      borderRadius: BorderRadius.circular(14),
      border: widget.outlined
          ? Border.all(
              color: Colors.white.withOpacity(_hover ? 0.4 : 0.18),
              width: 1.4,
            )
          : null,
      boxShadow: _hover
          ? (widget.outlined
              ? [
                  BoxShadow(
                    color: widget.gradient.colors.last.withOpacity(0.45),
                    offset: const Offset(0, 10),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF071A3A).withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(-5, -5),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1A4BA0).withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(5, -5),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00C9FF).withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(5, 5),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF9900).withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(-5, 5),
                  ),
                ])
          : [
              if (!widget.outlined)
                BoxShadow(
                  color: widget.gradient.colors.last.withOpacity(0.35),
                  offset: const Offset(0, 6),
                  blurRadius: 16,
                ),
            ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 14 : 18,
          vertical: widget.isSmall ? 8 : 10,
        ),
        decoration: decoration,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  color: Colors.white, size: widget.isSmall ? 16 : 18),
              SizedBox(width: widget.isSmall ? 8 : 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isSmall ? 13 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final String headline;
  final String sub;
  final bool useThreads;

  const HeroSection({
    super.key,
    this.headline = 'AWS Cloud Club',
    this.sub = 'Learn • Build • Share',
    this.useThreads = true,
  });

  @override
  Widget build(BuildContext context) {
    return HeroSectionWithThreads(
      headline: headline,
      sub: sub,
      useThreads: useThreads,
    );
  }
}

class CommunityStatsCard extends StatelessWidget {
  final bool isSmall;

  const CommunityStatsCard({
    super.key,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirebaseService.fetchCommunityStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'members': 0, 'certified': 0, 'projects': 0};
        
        return Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: isSmall ? 400 : 600),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F36).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4BA0), // Blue
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A4BA0).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.link,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cloud Learning Community',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Members', stats['members']?.toString() ?? '0'),
                  _buildStatItem('Certified', stats['certified']?.toString() ?? '0'),
                  _buildStatItem('Projects', stats['projects']?.toString() ?? '0'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF232942).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF00FFFF), // Neon Cyan
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}